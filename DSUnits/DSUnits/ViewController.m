//
//  ViewController.m
//  DSUnits
//
//  Created by dasheng on 2020/12/29.
//

#import "ViewController.h"
#import "DSCarModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DSCarModel *model = [DSCarModel new];
    model.price_t1 = @"10_$wy";
    model.price_t2 = @"10_$wy";
    model.price_t3 = @"10_$wy";
    
    NSLog(@"%@ %@ %@",model.price_t1,model.price_t2,model.price_t3);
    // Do any additional setup after loading the view.
}


@end
