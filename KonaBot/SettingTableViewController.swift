//
//  SettingTableViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 3/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController{
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.tableView.tableFooterView = UIView()
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		self.title = "More".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if (section == 0 && CGSize.screenSize().width >= 375 && UIDevice.currentDevice().model.hasPrefix("iPhone") || section == 1){
			return 2
		}
		else{
			return 1
		}
    }
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == self.tableView.numberOfSections - 1 {
			return ""
		}
		else{
			return " "
		}
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let section = indexPath.section
		let row = indexPath.row
		
		if section == 0 {
			if row == 0 {
				let cell = tableView.dequeueReusableCellWithIdentifier("textSwitchCell") as! TextSwitchCell
				
				cell.label.text = "Optimize Storage".localized
				cell.label.textColor = UIColor.konaColor()
				
				return cell
			}
			else if row == 1 && CGSize.screenSize().width >= 375 && UIDevice.currentDevice().model.hasPrefix("iPhone"){
				let cell = tableView.dequeueReusableCellWithIdentifier("viewModeCell") as! ViewModeCell
				
				cell.label.textColor = UIColor.konaColor()
				cell.segmentControl.tintColor = UIColor.konaColor()
				
				return cell
			}
		}
		else if section == 1 {
			if row == 0{
				let cell = tableView.dequeueReusableCellWithIdentifier("textArrowCell") as! TextArrowCell
				
				cell.label.text = "About".localized
				cell.label.textColor = UIColor.konaColor()
				
				return cell
			}
			else{
				let cell = tableView.dequeueReusableCellWithIdentifier("textArrowCell") as! TextArrowCell
				
				cell.label.text = "Buy Me A Coffee :)".localized
				cell.label.textColor = UIColor.konaColor()
				
				return cell
			}
		}
		else{
			if row == 0 {
				let cell = tableView.dequeueReusableCellWithIdentifier("textCell") as! TextCell
				
				cell.label.text = "Visit Support Site".localized
				cell.label.textColor = UIColor.konaColor()
				
				return cell
			}
		}
		
		return UITableViewCell()
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == 1 {
			if indexPath.row == 0{
				self.loadAboutVC()
			}
			else{
				self.navigationController!.pushViewController(IAPViewController(), animated: true)
			}
		}
		if indexPath.section == 2 {
			let websiteAddress = NSURL(string: "http://hkalexling.com/2015/11/05/konabot-support-page/")
			UIApplication.sharedApplication().openURL(websiteAddress!)
		}
	}
	
	func loadAboutVC(){
		let aboutVC = UIViewController()
		
		aboutVC.view.backgroundColor = UIColor.themeColor()
		
		let webView = UIWebView(frame: aboutVC.view.frame)
		webView.opaque = false
		webView.backgroundColor = UIColor.themeColor()
		aboutVC.view.addSubview(webView)
		
		let htmlFile = NSBundle.mainBundle().pathForResource("about", ofType: "html")!
		var htmlString : NSString!
		do {
			htmlString = try NSString(contentsOfFile: htmlFile, encoding: NSUTF8StringEncoding)
		}catch{}
		webView.loadHTMLString(htmlString as String, baseURL: nil)
		
		self.navigationController!.pushViewController(aboutVC, animated: true)
	}
	
	@IBAction func switched(sender: UISwitch) {
		NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "optimize")
	}
	
	@IBAction func seguementChanged(sender: UISegmentedControl) {
		NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: "viewMode")
	}
}
