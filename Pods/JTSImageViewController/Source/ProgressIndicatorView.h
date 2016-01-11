//
//  ProgressIndicatorView.h
//  KonaBot
//
//  Created by Alex Ling on 31/12/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressIndicatorView : UIImageView

@property UIColor *color;
@property UIColor *textColor;
@property UIColor *bgColor;

@property CGFloat width;
@property CGFloat radius;

@property UIFont *font;
@property BOOL showText;

- (void)updateProgress:(CGFloat) progress;
- (id) initWithColor: (UIColor*) color textColor:(UIColor*) textColor bgColor:(UIColor*) bgColor showText:(BOOL) showText width:(CGFloat) width font:(UIFont*) font radius:(CGFloat) radius;
- (void) startSpinWithSpeed: (CGFloat) spinSPeed;
- (void) stopSpin;

@end
