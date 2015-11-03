//
//  SettingTableViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 3/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
		self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
		self.title = "More"
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
		return 1
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
		//let row = indexPath.row
		
		if section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("textSwitchCell") as! TextSwitchCell
			
			cell.label.text = "Optimize Storage"
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
		else if section == 1 {

			let cell = tableView.dequeueReusableCellWithIdentifier("textArrowCell") as! TextArrowCell
			
			cell.label.text = "About"
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
		else{
			let cell = tableView.dequeueReusableCellWithIdentifier("textCell") as! TextCell
			
			cell.label.text = "Visit Support Site"
			cell.label.textColor = UIColor.konaColor()
			
			return cell
		}
    }
}
