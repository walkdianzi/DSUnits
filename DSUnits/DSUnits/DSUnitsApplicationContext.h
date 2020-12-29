//
//  DSUnitsApplicationContext.h
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import <Foundation/Foundation.h>

#define DSUnits(propertyName,unitsType) @property (nonatomic, weak, readonly) unitsType * propertyName ##_units;

@class PRICE_UNIT_F;

@class PRICE_UNIT_Y;

@class PRICE_UNIT_WY;

@protocol IOCComponents <NSObject>

@end

@interface DSUnitsApplicationContext : NSObject

+ (instancetype)shareInstance;

- (void)scanClasses;

- (id)getInstanceByClassName:(NSString *)className;

@end

