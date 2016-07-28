//
//  SettingTableViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 3/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

extension SettingTableViewController: UIWebViewDelegate {
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		if navigationType == UIWebViewNavigationType.linkClicked {
			UIApplication.shared().openURL(request.url!)
			return false
		}
		return true
	}
}

class SettingTableViewController: UITableViewController {
	
	var canAdjustViewMode : Bool = false
	
    override func viewDidLoad() {
		super.viewDidLoad()
	
		self.canAdjustViewMode = CGSize.screenSize().width >= 375 && UIDevice.current().model.hasPrefix("iPhone")
		
		self.tableView.tableFooterView = UIView()
		self.tableView.separatorStyle = .none
		self.title = "More".localized
    }

    // MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.canAdjustViewMode ? 4 : 3
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == tableView.numberOfSections - 2 ? 2 : 1
    }

	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if section == 0 {
			let view = UIView(frame: CGRect(x: 0, y: 0, width: CGSize.screenSize().width, height: 100))
			
			let label = UILabel(frame: CGRect(x: 10, y: 10, width: CGSize.screenSize().width - 20, height: 90))
			label.textColor = UIColor.konaColor()
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.font = UIFont.systemFont(ofSize: 13)
			label.text = "When enabled, image cache will be deleted after the app's termination. Cache of images in your favorite list won't be affected.".localized
			label.alpha = 0.5
			label.sizeToFit()
			view.addSubview(label)
			
			return view
		}
		
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == 0 {
			return 50
		}
		
		return 0
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return UIView()
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = (indexPath as NSIndexPath).section
		let row = (indexPath as NSIndexPath).row
		
		if section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "textSwitchCell") as! TextSwitchCell
			
			cell.label.text = "Optimize Storage".localized
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
		
		if self.canAdjustViewMode && section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "viewModeCell") as! ViewModeCell
			
			cell.label.textColor = UIColor.konaColor()
			cell.segmentControl.tintColor = UIColor.konaColor()
			
			return cell
		}
		
		if section == tableView.numberOfSections - 2 {
			if row == 0{
				let cell = tableView.dequeueReusableCell(withIdentifier: "textArrowCell") as! TextArrowCell
				
				cell.label.text = "About".localized
				cell.label.textColor = UIColor.konaColor()
				
				return cell
			}
			else{
				let cell = tableView.dequeueReusableCell(withIdentifier: "textArrowCell") as! TextArrowCell
				
				cell.label.text = "Buy Me A Coffee :)".localized
				cell.label.textColor = UIColor.konaColor()
				
				return cell
			}
		}
		
		if section == tableView.numberOfSections - 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! TextCell
			
			cell.label.text = "Feedback".localized
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
		
		return UITableViewCell()
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (indexPath as NSIndexPath).section == tableView.numberOfSections - 2 {
			if (indexPath as NSIndexPath).row == 0{
				self.loadAboutVC()
			}
			else{
				self.navigationController!.pushViewController(IAPViewController(), animated: true)
			}
		}
		if (indexPath as NSIndexPath).section == tableView.numberOfSections - 1 {
			UserDefaults.standard.set(true, forKey: "feedbackFinished")
			
			_ = FeedbackManager(parentVC: self, backgroundVC: self.tabBarController!, baseColor: UIColor.themeColor(), secondaryColor: UIColor.konaColor(), dismissButtonColor: UIColor.konaColor())
		}
	}
	
	func loadAboutVC(){
		let aboutVC = UIViewController()
		
		aboutVC.view.backgroundColor = UIColor.themeColor()
		
		let webView = UIWebView(frame: aboutVC.view.frame)
		webView.isOpaque = false
		webView.backgroundColor = UIColor.themeColor()
		webView.delegate = self
		aboutVC.view.addSubview(webView)
		
		let htmlFile = Bundle.main.pathForResource("about", ofType: "html")!
		var htmlString : NSString!
		do {
			htmlString = try NSString(contentsOfFile: htmlFile, encoding: String.Encoding.utf8.rawValue)
		}catch{}
		webView.loadHTMLString(htmlString as String, baseURL: nil)
		
		self.navigationController!.pushViewController(aboutVC, animated: true)
	}
	
	@IBAction func switched(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: "optimize")
	}
	
	@IBAction func seguementChanged(_ sender: UISegmentedControl) {
		UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "viewMode")
		print("setted: \(sender.selectedSegmentIndex)")
		print("object stored: \(UserDefaults.standard.object(forKey: "viewMode"))")
		print("stored: \(UserDefaults.standard.integer(forKey: "viewMode"))")
	}
}
