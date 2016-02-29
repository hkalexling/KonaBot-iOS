//
//  SteamLoadingView.swift
//  SteamLoadingView
//
//  Created by Alex Ling on 28/2/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class SteamLoadingView: UIView {

	private var barNumber = 3
	private var color = UIColor.blueColor()
	private var barMinHeight : CGFloat = 10
	private var barMaxHeight : CGFloat = 50
	private var barWidth : CGFloat = 10
	private var barSpacing : CGFloat = 5
	private var animationDuration : NSTimeInterval = 0.5
	private var deltaDuration : NSTimeInterval = 0.3
	private var delay : NSTimeInterval = 0.3
	private var animationOptions : UIViewAnimationOptions = [UIViewAnimationOptions.CurveEaseInOut]
	
	private var bars : [UIView] = []
	
	private let screenSize = UIScreen.mainScreen().bounds.size
	
	init(barNumber : Int?, color: UIColor?, minHeight : CGFloat?, maxHeight : CGFloat?, width : CGFloat?, spacing : CGFloat?, animationDuration : NSTimeInterval?, deltaDuration : NSTimeInterval?, delay : NSTimeInterval?, options : UIViewAnimationOptions?){
		super.init(frame: CGRectZero)
		
		if let barNumber_ = barNumber {
			self.barNumber = barNumber_
		}
		if let color_ = color {
			self.color = color_
		}
		if let barMinHeight_ = minHeight {
			self.barMinHeight = barMinHeight_
		}
		if let barMaxHeight_ = maxHeight {
			self.barMaxHeight = barMaxHeight_
		}
		if let barWidth_ = width {
			self.barWidth = barWidth_
		}
		if let barSpacing_ = spacing {
			self.barSpacing = barSpacing_
		}
		if let animationDuration_ = animationDuration {
			self.animationDuration = animationDuration_
		}
		if let deltaDuration_ = deltaDuration {
			self.deltaDuration = deltaDuration_
		}
		if let delay_ = delay {
			self.delay = delay_
		}
		if let options_ = options {
			self.animationOptions = options_
		}
		
		let viewWidth = CGFloat(self.barNumber) * self.barWidth + CGFloat(self.barNumber - 1) * self.barSpacing
		self.frame = CGRectMake((screenSize.width - viewWidth)/2, (screenSize.height - self.barMaxHeight)/2, viewWidth, self.barMaxHeight)
		self.addBars()
		
		for i in 0 ..< self.barNumber {
			animateBar(self.bars[i], delay: NSTimeInterval(i) * self.delay)
		}
	}
	init(){
		super.init(frame: CGRectZero)
		let viewWidth = CGFloat(self.barNumber) * self.barWidth + CGFloat(self.barNumber - 1) * self.barSpacing
		self.frame = CGRectMake((screenSize.width - viewWidth)/2, (screenSize.height - self.barMaxHeight)/2, viewWidth, self.barMaxHeight)
		self.addBars()
		
		for i in 0 ..< self.barNumber {
			animateBar(self.bars[i], delay: NSTimeInterval(i) * self.delay)
		}
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func addBars(){
		var x : CGFloat = 0
		for _ in 0 ..< self.barNumber {
			let bar = UIView(frame: CGRectMake(x, 0, self.barWidth, self.barMaxHeight))
			bar.backgroundColor = self.color
			bar.layer.cornerRadius = 5
			self.addSubview(bar)
			self.bars.append(bar)
			x += self.barWidth + self.barSpacing
		}
	}
	
	private func animateBar(bar : UIView, delay : NSTimeInterval) {
		UIView.animateWithDuration(self.randomInterval(), delay: delay, options: self.animationOptions, animations: {
			bar.frame = CGRectMake(bar.frame.minX, (self.barMaxHeight - self.barMinHeight)/2, self.barWidth, self.barMinHeight)
			}, completion: {(finished) in
				UIView.animateWithDuration(self.randomInterval(), delay: 0, options: self.animationOptions, animations: {
					bar.frame = CGRectMake(bar.frame.minX, 0, self.barWidth, self.barMaxHeight)
					}, completion: {(finished) in
						self.animateBar(bar, delay: 0)
				})
		})
	}
	
	private func randomInterval() -> NSTimeInterval {
		return NSTimeInterval(2 * Float(arc4random()) / Float(UINT32_MAX) - 1) * self.deltaDuration + self.animationDuration
	}
}
