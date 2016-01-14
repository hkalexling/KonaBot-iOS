//
//  PostDetailTableViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 14/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController, TagViewDelegate {
	
	var post : Post?
	var parentVC : DetailViewController!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.tableFooterView = UIView()
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44
		self.tableView.separatorColor = UIColor.clearColor()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 4
		}
		if section == 1 {
			return 1
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
					cell.label.text = "Created at: " + NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
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
				let tagView = TagView(tags: _post.tags, textColor: UIColor.themeColor(), tagColor: UIColor.konaColor(), font: UIFont.systemFontOfSize(17))
				tagView.delegate = self
				cell.addSubview(tagView)
			}
			
			return cell
		}
		
		let defaultCell = UITableViewCell()
		defaultCell.selectionStyle = .None
		return defaultCell
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 1 {
			if let _post = self.post {
				return TagView(tags: _post.tags, textColor: UIColor.themeColor(), tagColor: UIColor.konaColor(), font: UIFont.systemFontOfSize(17)).bounds.height
			}
		}
		return 44
	}
	
	func tagViewDidSelecteTag(tag: String?) {
		self.parentVC.tabBarController?.selectedIndex = 1
		let navigationVC = self.parentVC.tabBarController?.selectedViewController as! UINavigationController
		navigationVC.popToRootViewControllerAnimated(false)
		let searchVC = navigationVC.topViewController as! SearchViewController
		searchVC.searchBar.text = tag
		searchVC.searchBarSearchButtonClicked(searchVC.searchBar)
	}
}
