//
//  ChartViewController.h
//  ios-linechart
//
//  Created by Marcel Ruegenberg on 02.08.13.
//  Copyright (c) 2013 Marcel Ruegenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCLineChartView.h"

@interface ChartViewController : UIViewController
@property (weak, nonatomic) IBOutlet LCLineChartView *chartViewUpper;
@property (weak, nonatomic) IBOutlet LCLineChartView *chartViewLower;
@end
