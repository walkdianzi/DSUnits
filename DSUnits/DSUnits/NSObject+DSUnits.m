//
//  NSObject+DSUnits.m
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import "NSObject+DSUnits.h"
#import <UIKit/UIKit.h>
#import "DSUnitsApplicationContext.h"
#import <objc/runtime.h>

@implementation NSObject (DSUnits)

- (NSString *)getValuePropertyName:(NSString *)propertyName propertyValue:(NSString *)propertyValue{
    
    DSUnitsApplicationContext *context = [DSUnitsApplicationContext shareInstance];
    id serv = [context getInstanceByClassName:NSStringFromClass([self class])];
    NSMutableDictionary *mutableDic = [serv valueForKey:@"dsUnitsAnnotationMapper"];
    
    NSString *unitsType;
    if (mutableDic) {
        unitsType = [mutableDic objectForKey:propertyName];
    }
    if (!unitsType) {
        return propertyValue;
    }
    
    //价格的转换
    NSString *priceUnits = [self priceUnitsConvertWithType:unitsType propertyValue:propertyValue isServer:NO];
    if (priceUnits){
        return priceUnits;
    }
    
    return propertyValue;
}

- (void)setDsUnitsAnnotationMapper:(NSMutableDictionary *)mutableDic{
    
    objc_setAssociatedObject(self, @"DSUNITSANNOTATIONDICTIONARY", mutableDic, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableDictionary *)dsUnitsAnnotationMapper{
    
    return objc_getAssociatedObject(self, @"DSUNITSANNOTATIONDICTIONARY");
}

#pragma mark- Private Methon

- (NSString *)priceUnitsConvertWithType:(NSString *)unitsType propertyValue:(NSString *)propertyValue isServer:(BOOL)isServer{
    
    if ([unitsType isEqualToString:@"PRICE_UNIT_F"]) {
        if ([propertyValue hasSuffix:@"_$wy"]) {
            
            NSString *n = [self decimalNumberMutiplyWithString:[[propertyValue componentsSeparatedByString:@"_$wy"] objectAtIndex:0] multiplierNumber:@"1000000"];
            NSString *price = [self changeFloat:n];
            return isServer?[NSString stringWithFormat:@"%@_$f",price]:price;
            
        }else if ([propertyValue hasSuffix:@"_$y"]){
            
            NSString *n = [self decimalNumberMutiplyWithString:[[propertyValue componentsSeparatedByString:@"_$y"] objectAtIndex:0] multiplierNumber:@"100"];
            NSString *price = [self changeFloat:n];
            return isServer?[NSString stringWithFormat:@"%@_$f",price]:price;
            
        }else if ([propertyValue hasSuffix:@"_$f"]){
            CGFloat n = [[[propertyValue componentsSeparatedByString:@"_$f"] objectAtIndex:0] floatValue];
            NSString *price = [self changeFloat:[NSString stringWithFormat:@"%f",n]];
            return isServer?[NSString stringWithFormat:@"%@_$f",price]:price;
        }
    }else if ([unitsType isEqualToString:@"PRICE_UNIT_Y"]){
        
        if ([propertyValue hasSuffix:@"_$wy"]) {
            
            NSString *n = [self decimalNumberMutiplyWithString:[[propertyValue componentsSeparatedByString:@"_$wy"] objectAtIndex:0] multiplierNumber:@"10000"];
            NSString *price = [self changeFloat:n];
            return isServer?[NSString stringWithFormat:@"%@_$y",price]:price;
            
        }else if ([propertyValue hasSuffix:@"_$y"]){
            
            CGFloat n = [[[propertyValue componentsSeparatedByString:@"_$y"] objectAtIndex:0] floatValue];
            NSString *price = [self changeFloat:[NSString stringWithFormat:@"%f",n]];
            return isServer?[NSString stringWithFormat:@"%@_$y",price]:price;
            
        }else if ([propertyValue hasSuffix:@"_$f"]){
            
            NSString *n = [self decimalNumberDividWithString:[[propertyValue componentsSeparatedByString:@"_$f"] objectAtIndex:0] divisorNumber:@"100"];
            NSString *price = [self changeFloat:n];
            return isServer?[NSString stringWithFormat:@"%@_$y",price]:price;
        }
    }else if ([unitsType isEqualToString:@"PRICE_UNIT_WY"]){
        
        if ([propertyValue hasSuffix:@"_$wy"]) {
            CGFloat n = [[[propertyValue componentsSeparatedByString:@"_$wy"] objectAtIndex:0] floatValue];
            NSString *price = [self changeFloat:[NSString stringWithFormat:@"%f",n]];
            return isServer?[NSString stringWithFormat:@"%@_$wy",price]:price;
        }else if ([propertyValue hasSuffix:@"_$y"]){
            
            NSString *n = [self decimalNumberDividWithString:[[propertyValue componentsSeparatedByString:@"_$y"] objectAtIndex:0] divisorNumber:@"10000"];
            NSString *price = [self changeFloat:n];
            return isServer?[NSString stringWithFormat:@"%@_$wy",price]:price;
            
        }else if ([propertyValue hasSuffix:@"_$f"]){
          
            NSString *n = [self decimalNumberDividWithString:[[propertyValue componentsSeparatedByString:@"_$f"] objectAtIndex:0] divisorNumber:@"1000000"];
            NSString *price = [self changeFloat:n];
            return isServer?[NSString stringWithFormat:@"%@_$wy",price]:price;
        }
    }
    
    return nil;
}

-(NSString *)changeFloat:(NSString *)stringFloat
{
    if (![stringFloat containsString:@"."]) {
        return stringFloat;
    }
    const char *floatChars = [stringFloat UTF8String];
    NSUInteger length = [stringFloat length];
    NSUInteger zeroLength = 0;
    int i = (int)length-1;
    for(; i>=0; i--)
    {
        if(floatChars[i] == '0'/*0x30*/) {
            zeroLength++;
        } else {
            if(floatChars[i] == '.')
                i--;
            break;
        }
    }
    NSString *returnString;
    if(i == -1) {
        returnString = @"0";
    } else {
        returnString = [stringFloat substringToIndex:i+1];
    }
    return returnString;
}

- (NSString *)decimalNumberDividWithString:(NSString *)dividendValue divisorNumber:(NSString *)divisorValue{
    
    NSDecimalNumber *dividendNumber = [NSDecimalNumber decimalNumberWithString:dividendValue];
    NSDecimalNumber *divisorNumber = [NSDecimalNumber decimalNumberWithString:divisorValue];
    NSDecimalNumber *product = [dividendNumber decimalNumberByDividingBy:divisorNumber];
    return [product stringValue];
}

- (NSString *)decimalNumberMutiplyWithString:(NSString *)multiplicandValue multiplierNumber:(NSString *)multiplierValue{

    NSDecimalNumber *multiplicandNumber = [NSDecimalNumber decimalNumberWithString:multiplicandValue];
    NSDecimalNumber *multiplierNumber = [NSDecimalNumber decimalNumberWithString:multiplierValue];
    NSDecimalNumber *product = [multiplicandNumber decimalNumberByMultiplyingBy:multiplierNumber];
    return [product stringValue];
}
@end
