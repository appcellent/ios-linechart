//
//  LCInfoView.h
//  Classes
//
//  Created by Marcel Ruegenberg on 19.11.09.
//  Copyright 2009-2011 Dustlab. All rights reserved.
//

@interface LCInfoView : UIView <UIAppearance>
@property (strong) UIColor* lineColor;
@property CGPoint tapPoint;

@property (strong) UILabel *infoLabel;

- (void)setCornerRadius:(CGFloat)cornerRadius UI_APPEARANCE_SELECTOR;
- (void)setShowGloss:(NSNumber*)showGloss UI_APPEARANCE_SELECTOR;
- (void)setLineColor:(UIColor*)lineColor UI_APPEARANCE_SELECTOR;

@end
