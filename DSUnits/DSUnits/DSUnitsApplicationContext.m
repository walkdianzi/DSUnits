//
//  DSUnitsApplicationContext.m
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import "DSUnitsApplicationContext.h"
#import <objc/runtime.h>
#import "NSObject+DSUnits.h"

@interface DSAnnotation : NSObject

@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, assign)NSUInteger index;

@end

@implementation DSAnnotation

@end

@interface DSProperty : NSObject

@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *type;

@end

@implementation DSProperty

@end


@interface DSUnitsApplicationContext()

@property(nonatomic, strong)NSMutableDictionary *instanceMap;
@property(nonatomic, strong)NSMutableArray      *DIClasses;

@end

@implementation DSUnitsApplicationContext

+ (instancetype)shareInstance{
    static DSUnitsApplicationContext *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DSUnitsApplicationContext alloc]init];
    });
    return instance;
}

//扫描所有遵守IOCComponents协议的类（即需要实现注解的类）存放入全局数组中
- (void)scanClasses {
    int classCount = objc_getClassList(NULL, 0);
    Class *classList = (Class *)malloc(classCount * sizeof(Class));
    classCount = objc_getClassList(classList, classCount);
    // 用于存放需要IoC容器处理的类的OC数组
    NSMutableArray *temp = @[].mutableCopy;
    // 获得IOCComponents协议，用于判断标记
    Protocol *protocol = objc_getProtocol("IOCComponents");
    for (int i = 0; i < classCount; i++) {
        Class clazz = classList[i];
        NSString *className = NSStringFromClass(clazz);
        
        //检查IOCComponents标记，有标记的类才被IoC容器处理
        if (class_conformsToProtocol(clazz, protocol)) {
            [temp addObject:className];
        }
    }
    // 将IoC需要处理的类存储起来
    self.DIClasses = temp;
    // 由于类列表是malloc创建的，需要手动释放
    free(classList);
    // 根据注解属性处理依赖注入
    [self scanAnnotation];
}

/// 遍历属性，根据运行时属性的属性得到属性对应的类型存入全局示例对象的sccUnitsAnnotationMapper中
- (void)scanAnnotation {
    // 对scanClasses中得到的需要IoC容器处理的类进行遍历
    for (NSUInteger i = 0; i < self.DIClasses.count; i++) {
        NSString *className = self.DIClasses[i];
        Class class = NSClassFromString(className);
        unsigned int outCount;
        // 反射出所有属性
        objc_property_t *props = class_copyPropertyList(class, &outCount);
        // 保存所有注解属性，注解属性包含了位置索引(index)、名称(name)和类型(type)，通过一个模型类SGAnnotation来存储
        NSMutableArray *annotations = @[].mutableCopy;
        // 保存所有的属性信息，每个属性包含了名称(name)和类型(type)，通过一个模型类SGProperty来存储
        NSMutableArray *properties = @[].mutableCopy;
        // 遍历所有属性
        for (NSUInteger i = 0; i < outCount; i++) {
            objc_property_t prop = props[i];
            NSString *propName = [[NSString alloc] initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
            // 这一段代码用于从描述属性的字符串中获取到类型，用到了正则和字串处理
            NSString *propAttrs = [[NSString alloc] initWithCString:property_getAttributes(prop) encoding:NSUTF8StringEncoding];
            NSRange range = [propAttrs rangeOfString:@"@\".*\"" options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                range.location += 2;
                range.length -= 3;
                NSString *typeName = [propAttrs substringWithRange:range];
                // 如果当前属性为注解属性，则记录进annotaions
                if ([self isPropertyAnnotationByType:typeName]) {
                    DSAnnotation *anno = [DSAnnotation new];
                    anno.index = i;
                    anno.name = propName;
                    anno.type = typeName;
                    [annotations addObject:anno];
                }
                
                // 记录每一条属性
                DSProperty *sp = [DSProperty new];
                sp.name = propName;
                sp.type = typeName;
                [properties addObject:sp];
            }
        } // scan class properties end
        // 从容器中得到类的实例
        id diInstance = [self getInstanceByClassName:className];
        
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
        // 遍历注解，得到所有被修饰的属性
        for (NSUInteger i = 0; i < annotations.count; i++){
            DSAnnotation *annotation = annotations[i];
            DSProperty *prop = properties[annotation.index + 1];
            
            [mutableDic setObject:annotation.type forKey:prop.name];
        }
        
        [diInstance setValue:mutableDic forKey:@"dsUnitsAnnotationMapper"];
        
    } // scan classes end
}

- (BOOL)isPropertyAnnotationByType:(NSString *)typeName{
    
    if ([typeName isEqualToString:@"PRICE_UNIT_F"] || [typeName isEqualToString:@"PRICE_UNIT_Y"] || [typeName isEqualToString:@"PRICE_UNIT_WY"]){
        
        return YES;
    }
    return NO;
}

- (id)getInstanceByClassName:(NSString *)className {
    if (self.instanceMap[className] == nil) {
        Class clazz = NSClassFromString(className);
        // 检查类是否已经装载，防止未定义的类实例化时出错
        if (!objc_getClass(className.UTF8String)) {
            return nil;
        }
        
        id instance = [clazz new];
        self.instanceMap[className] = instance;
    }
    return self.instanceMap[className];
}

- (NSMutableDictionary *)instanceMap{
    
    if (!_instanceMap) {
        
        _instanceMap = [NSMutableDictionary dictionary];
    }
    return _instanceMap;
}

- (NSMutableArray *)DIClasses{
    
    if (!_DIClasses) {
        
        _DIClasses = [NSMutableArray array];
    }
    return _DIClasses;
}
@end
