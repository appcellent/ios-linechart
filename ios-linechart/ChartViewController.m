//
//  ChartViewController.m
//  ios-linechart
//
//  Created by Marcel Ruegenberg on 02.08.13.
//  Copyright (c) 2013 Marcel Ruegenberg. All rights reserved.
//

#import "ChartViewController.h"

@interface ChartViewController ()

@property (strong) NSDateFormatter *formatter;

@end

@implementation ChartViewController

#define SECS_PER_DAY (86400)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyyMMMd" options:0 locale:[NSLocale currentLocale]]];
    }
    
    LCLineChartData *d1x = [LCLineChartData new];
    {
        LCLineChartData *d1 = d1x;
        // el-cheapo next/prev day. Don't use this in your Real Code (use NSDateComponents or objc-utils instead)
        NSDate *date1 = [[NSDate date] dateByAddingTimeInterval:((-3) * SECS_PER_DAY)];
        NSDate *date2 = [[NSDate date] dateByAddingTimeInterval:((2) * SECS_PER_DAY)];
        d1.xMin = [date1 timeIntervalSinceReferenceDate];
        d1.xMax = [date2 timeIntervalSinceReferenceDate];
        d1.title = @"Foobarbang";
        d1.color = [UIColor redColor];
        d1.itemCount = 6;
        NSMutableArray *arr = [NSMutableArray array];
        for(NSUInteger i = 0; i < 4; ++i) {
            [arr addObject:@(d1.xMin + (rand() / (float)RAND_MAX) * (d1.xMax - d1.xMin))];
        }
        [arr addObject:@(d1.xMin)];
        [arr addObject:@(d1.xMax)];
        [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        NSMutableArray *arr2 = [NSMutableArray array];
        for(NSUInteger i = 0; i < 6; ++i) {
            [arr2 addObject:@((rand() / (float)RAND_MAX) * 6)];
        }
        d1.getData = ^(NSUInteger item) {
            float x = [arr[item] floatValue];
            float y = [arr2[item] floatValue];
            NSString *label1 = [self.formatter stringFromDate:[date1 dateByAddingTimeInterval:x]];
            NSString *label2 = [NSString stringWithFormat:@"%f", y];
            return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
        };
    }
    
    LCLineChartData *d2x = [LCLineChartData new];
    {
        LCLineChartData *d1 = d2x;
        NSDate *date1 = [[NSDate date] dateByAddingTimeInterval:((-3) * SECS_PER_DAY)];
        NSDate *date2 = [[NSDate date] dateByAddingTimeInterval:((2) * SECS_PER_DAY)];
        d1.xMin = [date1 timeIntervalSinceReferenceDate];
        d1.xMax = [date2 timeIntervalSinceReferenceDate];
        d1.title = @"Bar";
        d1.color = [UIColor blueColor];
        d1.itemCount = 8;
        NSMutableArray *arr = [NSMutableArray array];
        for(NSUInteger i = 0; i < d1.itemCount - 2; ++i) {
            [arr addObject:@(d1.xMin + (rand() / (float)RAND_MAX) * (d1.xMax - d1.xMin))];
        }
        [arr addObject:@(d1.xMin)];
        [arr addObject:@(d1.xMax)];
        [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        NSMutableArray *arr2 = [NSMutableArray array];
        for(NSUInteger i = 0; i < d1.itemCount; ++i) {
            [arr2 addObject:@((rand() / (float)RAND_MAX) * 6)];
        }
        d1.getData = ^(NSUInteger item) {
            float x = [arr[item] floatValue];
            float y = [arr2[item] floatValue];
            NSString *label1 = [self.formatter stringFromDate:[date1 dateByAddingTimeInterval:x]];
            NSString *label2 = [NSString stringWithFormat:@"%f", y];
            return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
        };
    }
    
    _chartViewUpper.yMin = 0;
    _chartViewUpper.yMax = 6;
    _chartViewUpper.ySteps = @[@"1.0",@"2.0",@"3.0",@"4.0",@"5.0",@"A big label at 6.0"];
    _chartViewUpper.data = @[d1x,d2x];
	
	_chartViewUpper.fillPlot = YES;

//    chartView.drawsDataPoints = NO; // Uncomment to turn off circles at data points.
//    chartView.drawsDataLines = NO; // Uncomment to turn off lines connecting data points.
//    chartView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0]; // Uncomment for custom background color.

    {
        LCLineChartData *d = [LCLineChartData new];
        d.xMin = 1;
        d.xMax = 31;
        d.title = @"The title for the legend";
        d.color = [UIColor redColor];
        d.itemCount = 10;
        
        NSMutableArray *vals = [NSMutableArray new];
        for(NSUInteger i = 0; i < d.itemCount; ++i)
            [vals addObject:@((rand() / (float)RAND_MAX) * (31 - 1) + 1)];
        [vals sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        d.getData = ^(NSUInteger item) {
            float x = [vals[item] floatValue];
            float y = powf(2, x / 7);
            NSString *label1 = [NSString stringWithFormat:@"%d", item];
            NSString *label2 = [NSString stringWithFormat:@"%f", y];
            return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
        };
        
        _chartViewLower.yMin = 0;
        _chartViewLower.yMax = powf(2, 31 / 7) + 0.5;
        _chartViewLower.ySteps = @[@"0.0",
                             [NSString stringWithFormat:@"%.02f", _chartViewLower.yMax / 2],
                             [NSString stringWithFormat:@"%.02f", _chartViewLower.yMax]];
        _chartViewLower.xStepsCount = 5;
        _chartViewLower.data = @[d];
        
        _chartViewLower.axisLabelColor = [UIColor blueColor];
        
        [self.view addSubview:_chartViewLower];
    }
}

@end
