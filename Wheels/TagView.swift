//
//  TagView.swift
//  tagView
//
//  Created by Alex Ling on 14/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

protocol TagViewDelegate {
	func tagViewDidSelecteTag(tag : String?)
}

class TagView: UIView {

	private var tagStrs : [String] = []
	private var textColor : UIColor!
	private var tagColor : UIColor!
	private var font : UIFont!
	
	var delegate : TagViewDelegate?
	var gap : CGFloat = 10
	var xExtension : CGFloat = 5
	var yExtension : CGFloat = 2.5
	var xEdge : CGFloat = 16
	var yEdge : CGFloat = 12
	var cornerRadius : CGFloat = 5
	
	var width : CGFloat = UIScreen.mainScreen().bounds.width
	
	init(tags : [String], textColor : UIColor, tagColor : UIColor, font : UIFont) {
		super.init(frame: CGRectMake(0, 0, 10, 10))
		
		self.tagStrs = tags
		self.textColor = textColor
		self.tagColor = tagColor
		self.font = font
		
		self.setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func setup(){
		var xCenter : CGFloat = 0
		var yCenter : CGFloat = 0
		var currentXMax : CGFloat = 0
		for tag in self.tagStrs {
			let label = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 10))
			label.font = self.font
			label.textAlignment = .Center
			label.text = tag
			label.sizeToFit()
			label.backgroundColor = self.tagColor
			label.textColor = self.textColor
			label.layer.cornerRadius = self.cornerRadius
			label.clipsToBounds = true
			label.frame = CGRectMake(0, 0, label.bounds.width + 2 * self.xExtension, label.bounds.height + 2 * self.yExtension)
			if label.frame.size.width > UIScreen.mainScreen().bounds.width - 2 * self.xEdge {
				label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, UIScreen.mainScreen().bounds.width - 2 * self.xEdge, label.frame.height)
			}
			
			if yCenter == 0 {
				yCenter = self.yEdge + label.bounds.height/2
				xCenter = self.xEdge + label.bounds.width/2
			}
			else{
				xCenter = currentXMax + self.gap + label.bounds.width/2
			}
			
			label.center = CGPointMake(xCenter, yCenter)
			
			if label.frame.maxX + self.xEdge > UIScreen.mainScreen().bounds.width {
				xCenter = label.bounds.width/2 + self.xEdge
				yCenter += label.bounds.height + gap
				label.center = CGPointMake(xCenter, yCenter)
			}
			
			currentXMax = label.frame.maxX
			
			label.userInteractionEnabled = true
			label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:))))
			
			self.addSubview(label)
		}
		self.resiztToFitSubViews()
	}
	
	private func resiztToFitSubViews() {
		var width : CGFloat = 0
		var height : CGFloat = 0
		
		for subView in self.subviews {
			let fw = subView.frame.origin.x + subView.frame.size.width
			let fh = subView.frame.origin.y + subView.frame.size.height
			
			width = max(width, fw)
			height = max(height, fh)
			
			self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width + self.xEdge, height + self.yEdge)
		}
	}
	
	func tapped(sender : UIGestureRecognizer) {
		let label = sender.view as! UILabel
		self.delegate?.tagViewDidSelecteTag(label.text)
	}
}
