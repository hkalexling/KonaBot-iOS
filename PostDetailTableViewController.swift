//
//  PostDetailTableViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 14/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
	
	var post : Post?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.tableFooterView = UIView()
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44
		self.tableView.separatorColor = UIColor.clearColor()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if section == 0 {
			return 4
		}
		if section == 1 {
			if let _post = self.post {
				return _post.tags.count
			}
		}
		if section == 2 {
			return 5
		}
		return 0
    }
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UILabel(frame: CGRectMake(0, 0, CGSize.screenSize().width, 30))
		headerView.textAlignment = .Left
		headerView.backgroundColor = UIColor.themeColor()
		headerView.font = UIFont.boldSystemFontOfSize(18)
		headerView.textColor = UIColor.konaColor()
		
		switch section{
		case 0:
			headerView.text = "Post Information"
		case 1:
			headerView.text = "Tags"
		default:
			headerView.text = ""
		}
		headerView.text = "   " + headerView.text!
		
		return headerView
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let section = indexPath.section
		let row = indexPath.row
		
		if section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier("postNameCell", forIndexPath: indexPath) as! PostNameCell
			if row == 0 {
				if let _post = self.post {
					cell.label.text = "Author: \(_post.author)"
				}
			}
			if row == 1 {
				if let _post = self.post {
					let date = NSDate(timeIntervalSince1970: NSTimeInterval(_post.created_at))
					cell.label.text = "Created at: " + NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: .MediumStyle)
				}
			}
			if row == 2 {
				if let _post = self.post {
					cell.label.text = "Score: \(_post.score)"
				}
			}
			if row == 3 {
				if let _post = self.post {
					cell.label.text = "Rating: " + _post.rating
				}
			}
			return cell
		}
		if section == 1 {
			let cell = UITableViewCell()
			cell.selectionStyle = .None
			if let _post = self.post {
				let label = UILabel(frame: CGRectMake(0, 0, 10, 10))
				label.font = UIFont.systemFontOfSize(17)
				label.textAlignment = .Center
				label.text = _post.tags[row]
				label.sizeToFit()
				label.backgroundColor = UIColor.konaColor()
				label.textColor = UIColor.themeColor()
				label.frame = CGRectMake(0, 0, label.bounds.width + 10, label.bounds.height + 5)
				label.center = CGPointMake(16 + label.bounds.width/2, cell.bounds.height/2)
				label.layer.cornerRadius = 5
				label.clipsToBounds = true
				cell.addSubview(label)
			}
			return cell
		}
		
		return UITableViewCell()
    }
}
