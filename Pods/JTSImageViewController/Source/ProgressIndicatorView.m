//
//  ProgressIndicatorView.m
//  KonaBot
//
//  Created by Alex Ling on 31/12/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

#import "ProgressIndicatorView.h"

@interface ProgressIndicatorView()

@property UILabel *text;
@property NSTimer *spinTimer;
@property CGFloat angle;
@property CGFloat spinSpeed;

@end

@implementation ProgressIndicatorView

- (id) init{
	return [self initWithFrame:CGRectMake(0, 0, _radius * 2.0, _radius * 2.0)];
}

- (id) initWithColor: (UIColor*) color textColor:(UIColor*) textColor bgColor:(UIColor*) bgColor showText:(BOOL) showText width:(CGFloat) width font:(UIFont*) font radius:(CGFloat) radius{
	_color = color;
	_textColor = textColor;
	_bgColor = bgColor;
	_showText = showText;
	_width =  width;
	_font = font;
	_radius = radius;
	_text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2.0 * _radius, 2.0 * _radius)];
	_text.textAlignment = NSTextAlignmentCenter;
	_text.textColor = _textColor;
	_text.font = _font;
	_text.hidden = !_showText;
	self = [self init];
	[self addSubview:_text];
	return self;
}

- (void) updateProgress:(CGFloat)progress {
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0 * _radius + _width, 2.0 * _radius + _width), NO, 0);
	
	UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_radius + _width/2.0, _radius + _width/2.0) radius:_radius startAngle:0 endAngle:(CGFloat)(2.0 * M_PI) clockwise:YES];
	bgPath.lineWidth = _width;
	[_bgColor setStroke];
	[bgPath stroke];
	
	UIBezierPath *percentagePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_radius + _width/2.0, _radius + _width/2.0) radius:_radius startAngle:(CGFloat)(-0.5 * M_PI) endAngle:[self progressToRadian:progress] clockwise:YES];
	percentagePath.lineWidth = _width;
	[_color setStroke];
	[percentagePath stroke];
	
	self.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	_text.text = [NSString stringWithFormat:@"%u%@", (int)(progress * 100), @"%"];
}

- (void) startSpinWithSpeed: (CGFloat) spinSPeed {
	_angle = 0;
	_spinSpeed = spinSPeed;
	_spinTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSpin) userInfo:nil repeats:YES];
}

- (void) stopSpin {
	[_spinTimer invalidate];
}

- (void) updateSpin {
	_angle += _spinSpeed;
	[self spin];
}

- (void) spin {
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0 * _radius + _width, 2.0 * _radius + _width), NO, 0);
	
	UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_radius + _width/2.0, _radius + _width/2.0) radius:_radius startAngle:0 endAngle:(CGFloat)(2.0 * M_PI) clockwise:YES];
	bgPath.lineWidth = _width;
	[_bgColor setStroke];
	[bgPath stroke];
	
	UIBezierPath *percentagePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_radius + _width/2.0, _radius + _width/2.0) radius:_radius startAngle:_angle endAngle: _angle + (CGFloat)(M_PI / 3) clockwise:YES];
	percentagePath.lineWidth = _width;
	[_color setStroke];
	[percentagePath stroke];
	
	self.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	_text.text = @"";
}

- (CGFloat) progressToRadian: (CGFloat)progress {
	return (CGFloat)2.0 * M_PI * progress - (CGFloat)0.5 * M_PI;
}

@end
