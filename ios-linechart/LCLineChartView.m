//
//  LCLineChartView.m
//  
//
//  Created by Marcel Ruegenberg on 02.08.13.
//
//

#import "LCLineChartView.h"
#import "LCLegendView.h"
#import "LCInfoView.h"

@interface LCLineChartDataItem ()

@property (readwrite) float x; // should be within the x range
@property (readwrite) float y; // should be within the y range
@property (readwrite) NSString *xLabel; // label to be shown on the x axis
@property (readwrite) NSString *dataLabel; // label to be shown directly at the data item

@property (readwrite) NSNumber *dataValue; //

- (id)initWithhX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel;

@end

@implementation LCLineChartDataItem

- (id)initWithhX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel {
    if((self = [super init])) {
        self.x = x;
        self.y = y;
        self.xLabel = xLabel;
        self.dataLabel = dataLabel;
		self.dataValue = nil;
    }
    return self;
}

+ (LCLineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel {
    return [[LCLineChartDataItem alloc] initWithhX:x y:y xLabel:xLabel dataLabel:dataLabel];
}

+ (LCLineChartDataItem *)dataItemWithX:(float)x y:(float)y xLabel:(NSString *)xLabel dataLabel:(NSString *)dataLabel andValue:(NSNumber*)value {
	LCLineChartDataItem* newItem = [[LCLineChartDataItem alloc] initWithhX:x y:y xLabel:xLabel dataLabel:dataLabel];
	newItem.dataValue = value;
    return newItem;
}

@end



@implementation LCLineChartData

@end



@implementation LCTouchInfo

@end

@implementation LCTouchSelection

-(id)init
{
	self = [super initWithFrame:CGRectZero];
	if (self)
	{
		self.alpha = 0.0f;
		
		self.deltaLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 86, 28)];
		_deltaLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
		_deltaLabel.textColor = [UIColor whiteColor];
		_deltaLabel.textAlignment = NSTextAlignmentCenter;
		_deltaLabel.font = [UIFont systemFontOfSize:14.0f];
		_deltaLabel.text = @"";
		_deltaLabel.layer.cornerRadius = 7;
		
		self.positivePerformanceColor = [UIColor colorWithRed:0.663 green:0.788 blue:0.455 alpha:1.000];
		self.negativePerformanceColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
		
		[self addSubview:_deltaLabel];
	}
	return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _deltaLabel.layer.cornerRadius = cornerRadius;
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	if (_firstTouchInfo.closestDataItem && _lastTouchInfo.closestDataItem)
	{
		CGRect rectSelection = CGRectMake(0, 0, 0, 0);
		rectSelection.origin.x = self.firstTouchInfo.currentPosView.frame.origin.x;
		rectSelection.origin.y = self.firstTouchInfo.currentPosView.frame.origin.y;
		rectSelection.size.width = self.lastTouchInfo.currentPosView.frame.origin.x - self.firstTouchInfo.currentPosView.frame.origin.x;
		rectSelection.size.height = self.firstTouchInfo.currentPosView.frame.size.height;
	
		self.frame = rectSelection;
		
		if ([_firstTouchInfo.closestDataItem.dataValue isEqual:_lastTouchInfo.closestDataItem.dataValue])
		{
			_deltaLabel.text = @"";
			_deltaLabel.alpha = 0.0f;
		}
		else
		{
			// delta
			CGRect rectDeltaLabel = _deltaLabel.frame;
			rectDeltaLabel.origin.x = (self.bounds.size.width*0.5f) - (rectDeltaLabel.size.width*0.5f);
			_deltaLabel.frame = rectDeltaLabel;
			_deltaLabel.alpha = 1.0f;
		
			if (_delegate && [_delegate respondsToSelector:@selector(formattedValueForSelection:)])
			{
				_deltaLabel.text = [_delegate formattedValueForSelection:self];
			}
			else
			{
				CGFloat first = [_firstTouchInfo.closestDataItem.dataValue floatValue];
				CGFloat last = [_lastTouchInfo.closestDataItem.dataValue floatValue];

				CGFloat performance = (last - first)/ABS(first);

				_deltaLabel.text = [NSString stringWithFormat:@"%.2f %%", performance*100];
				_deltaLabel.backgroundColor = (performance > 0.0f) ? _positivePerformanceColor : _negativePerformanceColor;
			}
		}
	}
}

@end



@interface LCLineChartView ()

@property LCLegendView *legendView;
@property NSMutableDictionary* infoForTouch;
@property LCTouchSelection* selection;
@property NSMutableSet* activeTouches;

- (BOOL)drawsAnyData;

@end




@implementation LCLineChartView
@synthesize data=_data;

- (void)setDefaultValues {
    self.padding = 10.f;
    self.xAxisSpacing = 15.f;

    self.legendView = [[LCLegendView alloc] init];
    self.legendView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.legendView];
    
    self.axisLabelColor = [UIColor grayColor];
    
    self.backgroundColor = [UIColor whiteColor];
    self.scaleFont = [UIFont systemFontOfSize:10.0];
	
	self.infoForTouch = [[NSMutableDictionary alloc] initWithCapacity:5];
	self.selection = [[LCTouchSelection alloc] init];
	[self addSubview:self.selection];
	self.activeTouches = [[NSMutableSet alloc] initWithCapacity:5];
	
    self.autoresizesSubviews = YES;
    self.contentMode = UIViewContentModeRedraw;
    
	self.drawsLegend = YES;
    self.drawsDataPoints = YES;
    self.drawsDataLines  = YES;
	self.drawsDataBorder = YES;
    self.smoothXAxisOnly = NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self setDefaultValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setDrawsLegend:(BOOL)drawsLegend
{
	_drawsLegend = drawsLegend;
	self.legendView.hidden = !_drawsLegend;
}

- (void)setAxisLabelColor:(UIColor *)axisLabelColor {
    if(axisLabelColor != _axisLabelColor) {
        [self willChangeValueForKey:@"axisLabelColor"];
        _axisLabelColor = axisLabelColor;
		
		for (LCTouchInfo* touchInfo in [_infoForTouch allValues])
			touchInfo.xAxisLabel.textColor = axisLabelColor;
		
        [self didChangeValueForKey:@"axisLabelColor"];
    }
}

- (void)showLegend:(BOOL)show animated:(BOOL)animated {
    if(! animated) {
        self.legendView.alpha = show ? 1.0 : 0.0;
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.legendView.alpha = show ? 1.0 : 0.0;
    }];
}
                           
- (void)layoutSubviews {
    [self.legendView sizeToFit];
    CGRect r = self.legendView.frame;
    r.origin.x = self.frame.size.width - self.legendView.frame.size.width - 3 - self.padding;
    r.origin.y = 3 + self.padding;
    self.legendView.frame = r;

    for (LCTouchInfo* touchInfo in [_infoForTouch allValues])
	{
		r = touchInfo.currentPosView.frame;
		CGFloat h = self.frame.size.height;
		r.size.height = h - 2 * self.padding - self.xAxisSpacing;
		r.origin.y = self.padding;
		touchInfo.currentPosView.frame = r;
		
		[touchInfo.xAxisLabel sizeToFit];
		r = touchInfo.xAxisLabel.frame;
		r.origin.y = self.frame.size.height - self.xAxisSpacing - self.padding + 2;
		touchInfo.xAxisLabel.frame = r;
	}
    
    [self bringSubviewToFront:self.legendView];
}

- (void)setData:(NSArray *)data {
    if(data != _data) {
        NSMutableArray *titles = [NSMutableArray arrayWithCapacity:[data count]];
        NSMutableDictionary *colors = [NSMutableDictionary dictionaryWithCapacity:[data count]];
        for(LCLineChartData *dat in data) {
            NSString *key = dat.title;
            if(key == nil) key = @"";
            [titles addObject:key];
            [colors setObject:dat.color forKey:key];
        }
        self.legendView.titles = titles;
        self.legendView.colors = colors;
        
        _data = data;
		
		[self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat availableHeight = self.bounds.size.height - 2 * self.padding - self.xAxisSpacing;
    
    CGFloat availableWidth = self.bounds.size.width - 2 * self.padding - self.yAxisLabelsWidth;
    CGFloat xStart = self.padding + self.yAxisLabelsWidth;
    CGFloat yStart = self.padding;
	
	static CGFloat dashedPattern[] = {4,2};
    
    // draw scale and horizontal lines
    CGFloat heightPerStep = self.ySteps == nil || [self.ySteps count] == 0 ? availableHeight : (availableHeight / ([self.ySteps count] - 1));
    
    NSUInteger i = 0;
    CGContextSaveGState(c);
    CGContextSetLineWidth(c, 1.0);
    NSUInteger yCnt = [self.ySteps count];
    for(NSString *step in self.ySteps) {
        [self.axisLabelColor set];
        CGFloat h = [self.scaleFont lineHeight];
        CGFloat y = yStart + heightPerStep * (yCnt - 1 - i);
        // TODO: replace with new text APIs in iOS 7 only version
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [step drawInRect:CGRectMake(yStart, y - h / 2, self.yAxisLabelsWidth - 6, h) withFont:self.scaleFont lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentRight];
#pragma clagn diagnostic pop
        
        [[UIColor colorWithWhite:0.9 alpha:1.0] set];
        CGContextSetLineDash(c, 0, dashedPattern, 2);
        CGContextMoveToPoint(c, xStart, round(y) + 0.5);
        CGContextAddLineToPoint(c, self.bounds.size.width - self.padding, round(y) + 0.5);
        CGContextStrokePath(c);
        
        i++;
    }
    
    NSUInteger xCnt = self.xStepsCount;
    if(xCnt > 1) {
        CGFloat widthPerStep = availableWidth / (xCnt - 1);
        
        [[UIColor grayColor] set];
        for(NSUInteger i = 0; i < xCnt; ++i) {
            CGFloat x = xStart + widthPerStep * (xCnt - 1 - i);
            
            [[UIColor colorWithWhite:0.9 alpha:1.0] set];
            CGContextMoveToPoint(c, round(x) + 0.5, self.padding);
            CGContextAddLineToPoint(c, round(x) + 0.5, yStart + availableHeight);
            CGContextStrokePath(c);
        }
    }
    
    CGContextRestoreGState(c);

	
	CGContextClipToRect(c, CGRectMake(xStart, yStart, availableWidth, availableHeight));
    

    if (!self.drawsAnyData) {
        NSLog(@"You configured LineChartView to draw neither lines nor data points. No data will be visible. This is most likely not what you wanted. (But we aren't judging you, so here's your chart background.)");
    } // warn if no data will be drawn
    
    CGFloat yRangeLen = self.yMax - self.yMin;
    if(yRangeLen == 0) yRangeLen = 1;
    for(LCLineChartData *data in self.data) {
        if (self.drawsDataLines) {
            float xRangeLen = data.xMax - data.xMin;
            if(xRangeLen == 0) xRangeLen = 1;
			if(data.itemCount >= 2) {
                LCLineChartDataItem *datItem = data.getData(0);
                CGMutablePathRef path = CGPathCreateMutable();
                CGFloat prevX = xStart + round(((datItem.x - data.xMin) / xRangeLen) * availableWidth);
                CGFloat prevY = yStart + round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
                CGPathMoveToPoint(path, NULL, prevX, prevY);
                for(NSUInteger i = 1; i < data.itemCount; ++i) {
                    LCLineChartDataItem *datItem = data.getData(i);
                    CGFloat x = xStart + round(((datItem.x - data.xMin) / xRangeLen) * availableWidth);
                    CGFloat y = yStart + round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
                    CGFloat xDiff = x - prevX;
                    CGFloat yDiff = y - prevY;

                    if(xDiff != 0) {
                        CGPoint controlPt1; CGPoint controlPt2;

                        if (self.smoothXAxisOnly) {
                            // limit the smoothing to the x-axis only
                            CGFloat strength = 0.5f;
                            controlPt1 = CGPointMake(prevX + (strength * xDiff), prevY);
                            controlPt2 = CGPointMake(x - (strength * xDiff), y);
                        }
                        else {
                            // the original smoothing.
                            CGFloat xSmoothing = self.smoothPlot ? MIN(30,xDiff) : 0;
                            CGFloat ySmoothing = 0.5;
                            CGFloat slope = yDiff / xDiff;
                            controlPt1 = CGPointMake(prevX + xSmoothing, prevY + ySmoothing * slope * xSmoothing);
                            controlPt2 = CGPointMake(x - xSmoothing, y - ySmoothing * slope * xSmoothing);
                        }

                        CGPathAddCurveToPoint(path, NULL, controlPt1.x, controlPt1.y, controlPt2.x, controlPt2.y, x, y);
                    }
                    else {
                        CGPathAddLineToPoint(path, NULL, x, y);
                    }
                    prevX = x;
                    prevY = y;
                }
                
				if (_drawsDataBorder)
				{
					CGContextAddPath(c, path);
					CGContextSetStrokeColorWithColor(c, [self.backgroundColor CGColor]);
					CGContextSetLineWidth(c, 5);
					CGContextStrokePath(c);
				}
                
                CGContextAddPath(c, path);
                CGContextSetStrokeColorWithColor(c, [data.color CGColor]);
                CGContextSetLineWidth(c, 2);

				// make a mutable copy of the current path to fill it afterwards
				CGMutablePathRef filledPath = CGPathCreateMutableCopy(path);
				
				// stroke the path
				CGContextDrawPath(c, kCGPathStroke);
				
				// add additional points to fill/close the curve
                if (self.fillPlot) {
					CGRect boundingBox = CGPathGetBoundingBox(filledPath);
					CGPathAddLineToPoint(filledPath, NULL, boundingBox.origin.x + boundingBox.size.width, yStart + availableHeight);
                    CGPathAddLineToPoint(filledPath, NULL, boundingBox.origin.x, yStart + availableHeight);
                    CGContextSetFillColorWithColor(c, [[data.color colorWithAlphaComponent:0.2f] CGColor]);
					CGContextAddPath(c, filledPath);
					CGContextDrawPath(c, kCGPathFill);
                }
				
                CGPathRelease(path);
            }
        } // draw actual chart data
        if (self.drawsDataPoints) {
            float xRangeLen = data.xMax - data.xMin;
            if(xRangeLen == 0) xRangeLen = 1;
            for(NSUInteger i = 0; i < data.itemCount; ++i) {
                LCLineChartDataItem *datItem = data.getData(i);
                CGFloat xVal = xStart + round((xRangeLen == 0 ? 0.5 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
                CGFloat yVal = yStart + round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);

				if (_drawsDataBorder)
				{
					[self.backgroundColor setFill];
					CGContextFillEllipseInRect(c, CGRectMake(xVal - 5.5, yVal - 5.5, 11, 11));
				}
				
                [data.color setFill];
                CGContextFillEllipseInRect(c, CGRectMake(xVal - 4, yVal - 4, 8, 8));
                {
                    CGFloat h,s,b,a;
                    if(CGColorGetNumberOfComponents([data.color CGColor]) < 3)
                        [data.color getWhite:&b alpha:&a];
                    else
                        [data.color getHue:&h saturation:&s brightness:&b alpha:&a];
                    if(b <= 0.5)
                        [[UIColor whiteColor] setFill];
                    else
                        [[UIColor blackColor] setFill];
                }
				if (_drawsDataBorder)
					CGContextFillEllipseInRect(c, CGRectMake(xVal - 2, yVal - 2, 4, 4));
				
				
				//
				if (datItem.showPositiveTrend)
				{
					[[UIColor colorWithRed:0.000 green:0.502 blue:0.251 alpha:1.000] setFill];
					CGContextMoveToPoint(c, xVal, yVal - 12);
					CGContextAddLineToPoint(c, xVal - 4, yVal - 6);
					CGContextAddLineToPoint(c, xVal + 4, yVal - 6);
					CGContextAddLineToPoint(c, xVal, yVal - 12);
					CGContextDrawPath(c, kCGPathFill);
				}
				
				if (datItem.showNegativeTrend)
				{
					[[UIColor colorWithRed:0.502 green:0.000 blue:0.000 alpha:1.000] setFill];
					CGContextMoveToPoint(c, xVal, yVal + 12);
					CGContextAddLineToPoint(c, xVal - 4, yVal + 6);
					CGContextAddLineToPoint(c, xVal + 4, yVal + 6);
					CGContextAddLineToPoint(c, xVal, yVal + 12);
					CGContextDrawPath(c, kCGPathFill);
				}
				
            } // for
        } // draw data points
    }
}

- (void)showIndicatorForTouch:(UITouch *)touch {
    
    CGPoint pos = [touch locationInView:self];
    CGFloat xStart = self.padding + self.yAxisLabelsWidth;
    CGFloat yStart = self.padding;
    CGFloat yRangeLen = self.yMax - self.yMin;
    if(yRangeLen == 0) yRangeLen = 1;
    CGFloat xPos = pos.x - xStart;
    CGFloat yPos = pos.y - yStart;
    CGFloat availableWidth = self.bounds.size.width - 2 * self.padding - self.yAxisLabelsWidth;
    CGFloat availableHeight = self.bounds.size.height - 2 * self.padding - self.xAxisSpacing;
    
    LCLineChartDataItem *closest = nil;
    float minDist = FLT_MAX;
    float minDistY = FLT_MAX;
    CGPoint closestPos = CGPointZero;
    
    for(LCLineChartData *data in self.data) {
        float xRangeLen = data.xMax - data.xMin;
       
        int iCount = _respectBeforeIntervall;
        int maxCount = (_respectAfterIntervall) ?  data.itemCount - 1: data.itemCount;
        
        for(iCount; iCount < maxCount; ++iCount) {
            LCLineChartDataItem *datItem = data.getData(iCount);
            
            CGFloat xVal = round((xRangeLen == 0 ? 0.0 : ((datItem.x - data.xMin) / xRangeLen)) * availableWidth);
            CGFloat yVal = round((1.0 - (datItem.y - self.yMin) / yRangeLen) * availableHeight);
            
            float dist = fabsf(xVal - xPos);
            float distY = fabsf(yVal - yPos);
            if(dist < minDist || (dist == minDist && distY < minDistY)) {
                minDist = dist;
                minDistY = distY;
                closest = datItem;
                closestPos = CGPointMake(xStart + xVal - 3, yStart + yVal - 7);
            }
        }
    }
	
	NSString* keyForTouch = [NSString stringWithFormat:@"%p", touch];
	LCTouchInfo* touchInfo = [_infoForTouch objectForKey:keyForTouch];
	
	if (!touchInfo)
	{
		touchInfo = [[LCTouchInfo alloc] init];
		
		// InfoView
		touchInfo.infoView = [[LCInfoView alloc] init];
		[self addSubview:touchInfo.infoView];
		
		// CurrentPosView
		touchInfo.currentPosView = [[UIView alloc] initWithFrame:CGRectMake(self.padding, self.padding, 2 / self.contentScaleFactor, 50)];
		touchInfo.currentPosView.backgroundColor = ([[LCInfoView appearance] lineColor]) ? [[LCInfoView appearance] lineColor] : [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];;
		touchInfo.currentPosView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		touchInfo.currentPosView.alpha = 0.0;
		[self addSubview:touchInfo.currentPosView];
		
		// xAxisLabel
		touchInfo.xAxisLabel = [[UILabel alloc] initWithFrame:CGRectMake(closestPos.x, yStart + availableHeight, 20, 20)];
		touchInfo.xAxisLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		touchInfo.xAxisLabel.font = [UIFont boldSystemFontOfSize:10];
		touchInfo.xAxisLabel.textColor = self.axisLabelColor;
		touchInfo.xAxisLabel.textAlignment = NSTextAlignmentCenter;
		touchInfo.xAxisLabel.alpha = 0.0;
		touchInfo.xAxisLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:touchInfo.xAxisLabel];
		
		[_infoForTouch setObject:touchInfo forKey:keyForTouch];
	}

	touchInfo.closestDataItem = closest;
    touchInfo.infoView.infoLabel.text = closest.dataLabel;
    touchInfo.infoView.tapPoint = closestPos;
    [touchInfo.infoView sizeToFit];
    [touchInfo.infoView setNeedsLayout];
    [touchInfo.infoView setNeedsDisplay];
	
    if(touchInfo.currentPosView.alpha == 0.0) {
        CGRect r = touchInfo.currentPosView.frame;
        r.origin.x = closestPos.x + 3 - 1;
        touchInfo.currentPosView.frame = r;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        touchInfo.infoView.alpha = 1.0;
        touchInfo.currentPosView.alpha = 1.0;
        touchInfo.xAxisLabel.alpha = 1.0;
		
        CGRect r = touchInfo.currentPosView.frame;
        r.origin.x = closestPos.x + 3 - 1;
        touchInfo.currentPosView.frame = r;
		[self bringSubviewToFront:touchInfo.infoView];
		
		[self.selection bringSubviewToFront:self.selection.deltaLabel];
		[self bringSubviewToFront:self.selection];
		[self.selection layoutSubviews];
		
        touchInfo.xAxisLabel.text = closest.xLabel;
        if(touchInfo.xAxisLabel.text != nil) {
            [touchInfo.xAxisLabel sizeToFit];
            r = touchInfo.xAxisLabel.frame;
            r.origin.x = round(closestPos.x - r.size.width / 2);
            touchInfo.xAxisLabel.frame = r;
        }
    }];
}

- (void)hideIndicatorForTouches:(NSSet*)touches {
    [UIView animateWithDuration:0.1 animations:^{
		//for (LCTouchInfo* touchInfo in [_infoForTouch allValues]) {
		for (UITouch* touch in touches) {
			LCTouchInfo* touchInfo = [_infoForTouch objectForKey:[NSString stringWithFormat:@"%p", touch]];
			touchInfo.infoView.alpha = 0.0f;
			touchInfo.currentPosView.alpha = 0.0f;
			touchInfo.xAxisLabel.alpha = 0.0f;
		}
		self.selection.alpha = 0.0f;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for (UITouch* touch in touches)
	{
		[self showIndicatorForTouch:touch];
	}
	
	[_activeTouches unionSet:touches];
	[self refreshSelection:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for (UITouch* touch in touches)
	{
		[self showIndicatorForTouch:touch];
	}
	[self refreshSelection:touches];
}

- (void)refreshSelection:(NSSet*)touches
{
	if (_activeTouches.count > 1)
	{
		NSArray* sortedTouches = [[_activeTouches allObjects] sortedArrayUsingComparator: ^(id touch1, id touch2) {
			
			CGPoint pos1 = [touch1 locationInView:self];
			CGPoint pos2 = [touch2 locationInView:self];
			
			if (pos1.x > pos2.x) {
				return (NSComparisonResult)NSOrderedDescending;
			}
			return (NSComparisonResult)NSOrderedSame;
		}];
		
		NSString* firstTouchKey = [NSString stringWithFormat:@"%p", [sortedTouches firstObject]];
		self.selection.firstTouchInfo = [_infoForTouch objectForKey:firstTouchKey];
		NSString* lastTouchKey = [NSString stringWithFormat:@"%p", [sortedTouches lastObject]];
		self.selection.lastTouchInfo = [_infoForTouch objectForKey:lastTouchKey];
		
		self.selection.alpha = 1.0;
		[self.selection layoutSubviews];
	}
	else
		self.selection.alpha = 0.0f;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideIndicatorForTouches:touches];
	[_activeTouches minusSet:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideIndicatorForTouches:touches];
	[_activeTouches minusSet:touches];
}


#pragma mark Helper methods

- (BOOL)drawsAnyData {
    return self.drawsDataPoints || self.drawsDataLines;
}

// TODO: This should really be a cached value. Invalidated iff ySteps changes.
- (CGFloat)yAxisLabelsWidth {
    float maxV = 0;
    for(NSString *label in self.ySteps) {
        CGSize labelSize = [label sizeWithFont:self.scaleFont];
        if(labelSize.width > maxV) maxV = labelSize.width;
    }
    return maxV + self.padding;
}

@end
