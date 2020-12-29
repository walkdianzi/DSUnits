//
//  DSCarModel.m
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import "DSCarModel.h"
#import "NSObject+DSUnits.h"

@implementation DSCarModel

- (NSString *)price_t1{
    
    return [self getValuePropertyName:@"price_t1" propertyValue:_price_t1];
}

- (NSString *)price_t2{
    
    return [self getValuePropertyName:@"price_t2" propertyValue:_price_t2];
}

- (NSString *)price_t3{
    
    return [self getValuePropertyName:@"price_t3" propertyValue:_price_t3];
}

@end
