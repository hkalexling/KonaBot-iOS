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

	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		self.tapCounter += 1
		let hasTappedTwice = self.previousVC == viewController
		self.previousVC = viewController
		
		if self.tapCounter == 2 && hasTappedTwice {
			self.tapCounter = 0
			if selectedIndex == 0 {
				let topVC = (viewController as! UINavigationController).topViewController
				if let collectionVC = topVC as? CollectionViewController {
					collectionVC.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
				}
			}
			if selectedIndex == 2 {
				let topVC = (viewController as! UINavigationController).topViewController
				if let collectionVC = topVC as? FavoriteCollectionViewController {
					collectionVC.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
				}
			}
		}
		if self.tapCounter == 1 {
			let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
			DispatchQueue.main.asyncAfter(deadline: delayTime, execute: { 
				self.tapCounter = 0;
			})
		}
		
		return true
	}
}
