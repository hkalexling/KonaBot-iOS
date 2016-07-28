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
	private var color = UIColor.blue()
	private var barMinHeight : CGFloat = 10
	private var barMaxHeight : CGFloat = 50
	private var barWidth : CGFloat = 10
	private var barSpacing : CGFloat = 5
	private var animationDuration : TimeInterval = 0.5
	private var deltaDuration : TimeInterval = 0.3
	private var delay : TimeInterval = 0.3
	private var animationOptions : UIViewAnimationOptions = UIViewAnimationOptions()
	
	private var bars : [UIView] = []
	
	private let screenSize = UIScreen.main().bounds.size
	
	init(barNumber : Int?, color: UIColor?, minHeight : CGFloat?, maxHeight : CGFloat?, width : CGFloat?, spacing : CGFloat?, animationDuration : TimeInterval?, deltaDuration : TimeInterval?, delay : TimeInterval?, options : UIViewAnimationOptions?){
		super.init(frame: CGRect.zero)
		
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
		self.frame = CGRect(x: (screenSize.width - viewWidth)/2, y: (screenSize.height - self.barMaxHeight)/2, width: viewWidth, height: self.barMaxHeight)
		self.addBars()
		
		for i in 0 ..< self.barNumber {
			animateBar(self.bars[i], delay: TimeInterval(i) * self.delay)
		}
	}
	init(){
		super.init(frame: CGRect.zero)
		let viewWidth = CGFloat(self.barNumber) * self.barWidth + CGFloat(self.barNumber - 1) * self.barSpacing
		self.frame = CGRect(x: (screenSize.width - viewWidth)/2, y: (screenSize.height - self.barMaxHeight)/2, width: viewWidth, height: self.barMaxHeight)
		self.addBars()
		
		for i in 0 ..< self.barNumber {
			animateBar(self.bars[i], delay: TimeInterval(i) * self.delay)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func addBars(){
		var x : CGFloat = 0
		for _ in 0 ..< self.barNumber {
			let bar = UIView(frame: CGRect(x: x, y: 0, width: self.barWidth, height: self.barMaxHeight))
			bar.backgroundColor = self.color
			bar.layer.cornerRadius = 5
			self.addSubview(bar)
			self.bars.append(bar)
			x += self.barWidth + self.barSpacing
		}
	}
	
	private func animateBar(_ bar : UIView, delay : TimeInterval) {
		UIView.animate(withDuration: self.randomInterval(), delay: delay, options: self.animationOptions, animations: {
			bar.frame = CGRect(x: bar.frame.minX, y: (self.barMaxHeight - self.barMinHeight)/2, width: self.barWidth, height: self.barMinHeight)
			}, completion: {(finished) in
				UIView.animate(withDuration: self.randomInterval(), delay: 0, options: self.animationOptions, animations: {
					bar.frame = CGRect(x: bar.frame.minX, y: 0, width: self.barWidth, height: self.barMaxHeight)
					}, completion: {(finished) in
						self.animateBar(bar, delay: 0)
				})
		})
	}
	
	private func randomInterval() -> TimeInterval {
		return TimeInterval(2 * Float(arc4random()) / Float(UINT32_MAX) - 1) * self.deltaDuration + self.animationDuration
	}
}
