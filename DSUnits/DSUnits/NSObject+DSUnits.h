//
//  NSObject+DSUnits.h
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DSUnits)

- (NSString *)getValuePropertyName:(NSString *)propertyName propertyValue:(NSString *)propertyValue;

- (void)setDsUnitsAnnotationMapper:(NSMutableDictionary *)mutableDic;

- (NSMutableDictionary *)dsUnitsAnnotationMapper;

@end

NS_ASSUME_NONNULL_END
