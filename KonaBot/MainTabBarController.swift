//
//  MainTabBarController.swift
//  KonaBot
//
//  Created by Alex Ling on 31/12/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.delegate = self
        // Do any additional setup after loading the view.
    }
	
	func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
		return !(tabBarController.viewControllers?.indexOf(viewController) == 0 && tabBarController.selectedIndex == 0) 
	}
}
