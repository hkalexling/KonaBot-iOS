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
		self.tableView.separatorColor = UIColor.clear()
		
		let tags = self.post != nil ? self.post!.tags : self.parsedPost!.tags
		self.tagView = TagView(tags: tags, textColor: UIColor.themeColor(), tagColor: UIColor.konaColor(), font: UIFont.systemFont(ofSize: 17))
		self.tagView!.delegate = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 4
		}
		if section == 1 {
			return 1
		}
		return 0
    }
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UILabel(frame: CGRect(x: 0, y: 0, width: CGSize.screenSize().width, height: 30))
		headerView.textAlignment = .left
		headerView.backgroundColor = UIColor.themeColor()
		headerView.font = UIFont.boldSystemFont(ofSize: 18)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let section = (indexPath as NSIndexPath).section
		let row = (indexPath as NSIndexPath).row
		
		if section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "postNameCell", for: indexPath) as! PostNameCell
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
					let date = Date(timeIntervalSince1970: TimeInterval(_post.created_at))
					cell.label.text = "Created at".localized + ": " + DateFormatter.localizedString(from: date, dateStyle: .mediumStyle, timeStyle: .shortStyle)
				}
				if let _parsed = self.parsedPost {
					let date = Date(timeIntervalSince1970: TimeInterval(_parsed.time))
					cell.label.text = "Created at".localized + ": " + DateFormatter.localizedString(from: date, dateStyle: .mediumStyle, timeStyle: .shortStyle)
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
			cell.selectionStyle = .none
			
			if self.tagView != nil {
				cell.addSubview(self.tagView!)
			}
			
			return cell
		}
		
		let defaultCell = UITableViewCell()
		defaultCell.selectionStyle = .none
		return defaultCell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (indexPath as NSIndexPath).section == 1 {
			if self.tagView != nil {
				return self.tagView!.bounds.height
			}
		}
		return 44
	}
	
	func tagViewDidSelecteTag(_ tag: String?) {
		let collectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionVC") as! CollectionViewController
		collectionVC.keyword = tag!
		collectionVC.isFromDetailTableVC = true
		collectionVC.searchVC = SearchViewController()
		self.parentVC.navigationController!.pushViewController(collectionVC, animated: true)
	}
}
