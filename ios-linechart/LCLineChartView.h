//
//  LCLineChartView.h
//  
//
//  Created by Marcel Ruegenberg on 02.08.13.
//
//

#import <UIKit/UIKit.h>

#import "LCLegendView.h"
#import "LCInfoView.h"

@class LCLineChartDataItem;

typedef LCLineChartDataItem *(^LCLineChartDataGetter)(NSUInteger item);



@interface LCLineChartDataItem : NSObject

@property (readonly) float x; /// should be within the x range
@property (readonly) float y; /// should be within the y range
@property (readonly) NSString *xLabel; /// label to be shown on the x axis
@property (readonly) NSString *dataLabel; /// label to be shown directly at the data item

@property (readonly) NSNumber *dataValue; //

+ (LCLineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel;
+ (LCLineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel andValue:(NSNumber*)value;

@end



@interface LCLineChartData : NSObject

@property (strong) UIColor *color;
@property (copy) NSString *title;
@property NSUInteger itemCount;

@property float xMin;
@property float xMax;

@property (copy) LCLineChartDataGetter getData;

@end



@class LCInfoView;
@interface LCTouchInfo : NSObject

@property (strong) LCInfoView* infoView;
@property (strong) UIView *currentPosView;
@property (strong) UILabel *xAxisLabel;
@property (strong) LCLineChartDataItem* closestDataItem;

@end


@class LCTouchSelection;
@protocol LCTouchSelectionDelegate <NSObject>
-(NSString*)formattedValueForSelection:(LCTouchSelection*)selection;
@end

@interface LCTouchSelection : UIView
@property (strong) LCTouchInfo* firstTouchInfo;
@property (strong) LCTouchInfo* lastTouchInfo;
@property (strong) UILabel* deltaLabel;

@property (weak) id<LCTouchSelectionDelegate> delegate;

- (void)setCornerRadius:(CGFloat)cornerRadius UI_APPEARANCE_SELECTOR;
@end


@interface LCLineChartView : UIView

@property (nonatomic, strong) NSArray *data; /// Array of `LineChartData` objects, one for each line.

@property float yMin;
@property float yMax;
@property (strong) NSArray *ySteps; /// Array of step names (NSString). At each step, a scale line is shown.
@property NSUInteger xStepsCount; /// number of steps in x. At each x step, a vertical scale line is shown. if x < 2, nothing is done

@property BOOL smoothPlot; // draw a smoothed Bezier plot? Default: NO
@property BOOL smoothXAxisOnly; // limit the smoothing to horizontal only. Default NO.
@property BOOL drawsDataPoints; // Switch to turn off circles on data points. On by default.
@property BOOL drawsDataLines; // Switch to turn off lines connecting data points. On by default.
@property BOOL drawsDataBorder; // Switch to turn off border around data points and lines. On by default
@property BOOL fillPlot; // fill the area under the curve.

@property float padding; // padding for the chart data within the view.
@property float xAxisSpacing; // additional spacing for the x-axis labels.

@property (strong) UIFont *scaleFont; /// Font in which scale markings are drawn. Defaults to [UIFont systemFontOfSize:10].
@property (nonatomic,strong) UIColor *axisLabelColor;

- (void)showLegend:(BOOL)show animated:(BOOL)animated;

@end
