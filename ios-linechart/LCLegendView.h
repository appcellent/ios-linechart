//
//  LCLegendView.h
//  ios-linechart
//
//  Created by Marcel Ruegenberg on 02.08.13.
//  Copyright (c) 2013 Marcel Ruegenberg. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LCLegendView : UIView <UIAppearance>

@property (nonatomic, strong) UIFont *titlesFont;
@property (strong) NSArray *titles;
@property (strong) NSDictionary *colors; // maps titles to UIColors

- (void)setCornerRadius:(CGFloat)cornerRadius UI_APPEARANCE_SELECTOR;

@end
