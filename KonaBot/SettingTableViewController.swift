//
//  SettingTableViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 3/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController{
	
	var canAdjustViewMode : Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.canAdjustViewMode = CGSize.screenSize().width >= 375 && UIDevice.currentDevice().model.hasPrefix("iPhone")
		
        self.tableView.tableFooterView = UIView()
		self.tableView.separatorStyle = .None
		self.title = "More".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		return self.canAdjustViewMode ? 4 : 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return section == tableView.numberOfSections - 2 ? 2 : 1
    }

	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if section == 0 {
			let view = UIView(frame: CGRectMake(0, 0, CGSize.screenSize().width, 100))
			
			let label = UILabel(frame: CGRectMake(10, 10, CGSize.screenSize().width - 20, 90))
			label.textColor = UIColor.konaColor()
			label.numberOfLines = 0
			label.lineBreakMode = .ByWordWrapping
			label.font = UIFont.systemFontOfSize(13)
			label.text = "When enabled, image cache will be deleted after the app's termination. Cache of images in your favorite list won't be affected.".localized
			label.alpha = 0.5
			label.sizeToFit()
			view.addSubview(label)
			
			return view
		}
		
		return nil
	}
	
	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == 0 {
			return 50
		}
		
		return 0
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView()
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let section = indexPath.section
		let row = indexPath.row
		
		if section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("textSwitchCell") as! TextSwitchCell
			
			cell.label.text = "Optimize Storage".localized
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
		
		if self.canAdjustViewMode && section == 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("viewModeCell") as! ViewModeCell
			
			cell.label.textColor = UIColor.konaColor()
			cell.segmentControl.tintColor = UIColor.konaColor()
			
			return cell
		}
		
		if section == tableView.numberOfSections - 2 {
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
		
		if section == tableView.numberOfSections - 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("textCell") as! TextCell
			
			cell.label.text = "Visit Support Site".localized
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
		
		return UITableViewCell()
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.section == tableView.numberOfSections - 2 {
			if indexPath.row == 0{
				self.loadAboutVC()
			}
			else{
				self.navigationController!.pushViewController(IAPViewController(), animated: true)
			}
		}
		if indexPath.section == tableView.numberOfSections - 1 {
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
