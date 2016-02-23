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
	var parsedPost : ParsedPost?
	var parentVC : DetailViewController!
	
	var tagView : TagView?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.tableFooterView = UIView()
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 44
		self.tableView.separatorColor = UIColor.clearColor()
		
		let tags = self.post != nil ? self.post!.tags : self.parsedPost!.tags
		self.tagView = TagView(tags: tags, textColor: UIColor.themeColor(), tagColor: UIColor.konaColor(), font: UIFont.systemFontOfSize(17))
		self.tagView!.delegate = self
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 4
		}
		if section == 1 {
			return 1
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
			headerView.text = "Post Information".localized
		case 1:
			headerView.text = "Tags".localized
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
					cell.label.text = "Author".localized + ": \(_post.author)"
				}
				if let _parsed = self.parsedPost {
					cell.label.text = "Author".localized + ": \(_parsed.author)"
				}
			}
			if row == 1 {
				if let _post = self.post {
					let date = NSDate(timeIntervalSince1970: NSTimeInterval(_post.created_at))
					cell.label.text = "Created at".localized + ": " + NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
				}
				if let _parsed = self.parsedPost {
					let date = NSDate(timeIntervalSince1970: NSTimeInterval(_parsed.time))
					cell.label.text = "Created at".localized + ": " + NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
				}
			}
			if row == 2 {
				if let _post = self.post {
					cell.label.text = "Score".localized + ": \(_post.score)"
				}
				if let _parsed = self.parsedPost {
					cell.label.text = "Score".localized + ": \(_parsed.score)"
				}
			}
			if row == 3 {
				if let _post = self.post {
					cell.label.text = "Rating".localized + ": " + _post.rating
				}
				if let _parsed = self.parsedPost {
					cell.label.text = "Rating".localized + ": " + _parsed.rating
				}
			}
			return cell
		}
		if section == 1 {
			let cell = UITableViewCell()
			cell.selectionStyle = .None
			
			if self.tagView != nil {
				cell.addSubview(self.tagView!)
			}
			
			return cell
		}
		
		let defaultCell = UITableViewCell()
		defaultCell.selectionStyle = .None
		return defaultCell
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 1 {
			if self.tagView != nil {
				return self.tagView!.bounds.height
			}
		}
		return 44
	}
	
	func tagViewDidSelecteTag(tag: String?) {
		let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchVC") as! SearchViewController
		self.parentVC.navigationController!.pushViewController(searchVC, animated: true)
		searchVC.searchBar.text = tag
		searchVC.searchBarSearchButtonClicked(searchVC.searchBar)
		/*
		self.parentVC.tabBarController?.selectedIndex = 1
		let navigationVC = self.parentVC.tabBarController?.selectedViewController as! UINavigationController
		navigationVC.popToRootViewControllerAnimated(false)
		let searchVC = navigationVC.topViewController as! SearchViewController
		searchVC.searchBar.text = tag
		searchVC.searchBarSearchButtonClicked(searchVC.searchBar)
		*/
	}
}
