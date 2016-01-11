//
//  TabBarController.swift
//  KonaBot
//
//  Created by Alex Ling on 11/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
	
	var tapCounter : Int = 0
	var previousVC = UIViewController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.delegate = self
    }

	func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
		
		self.tapCounter++
		let hasTappedTwice = self.previousVC == viewController
		self.previousVC = viewController
		
		if self.tapCounter == 2 && hasTappedTwice {
			self.tapCounter = 0
			if selectedIndex == 0 {
				let topVC = (viewController as! UINavigationController).topViewController
				if let collectionVC = topVC as? CollectionViewController {
					collectionVC.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: true)
				}
			}
			if selectedIndex == 3 {
				let topVC = (viewController as! UINavigationController).topViewController
				if let collectionVC = topVC as? FavoriteCollectionViewController {
					collectionVC.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: true)
				}
			}
		}
		if self.tapCounter == 1 {
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue(), {
				self.tapCounter = 0
			})
		}
		
		return true
	}
}
