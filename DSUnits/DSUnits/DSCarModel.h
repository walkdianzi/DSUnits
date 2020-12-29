//
//  DSCarModel.h
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import <Foundation/Foundation.h>
#import "DSUnitsApplicationContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSCarModel : NSObject<IOCComponents>

DSUnits(price_t1, PRICE_UNIT_F)
@property(nonatomic, copy)NSString *price_t1;

DSUnits(price_t2, PRICE_UNIT_Y)
@property(nonatomic, copy)NSString *price_t2;

DSUnits(price_t3, PRICE_UNIT_WY)
@property(nonatomic, copy)NSString *price_t3;

@end

NS_ASSUME_NONNULL_END
