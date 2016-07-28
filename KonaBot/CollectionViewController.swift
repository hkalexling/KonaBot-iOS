//
//  CollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 31/10/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Kanna
import AFNetworking

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, KonaAPIPostDelegate, KonaAPIErrorDelegate, KonaHTMLParserTagsDelegate {
	
	var refreshControl : UIRefreshControl!
	
	var searchVC : SearchViewController?
	var loading : SteamLoadingView!
	
	var r18 : Bool = false

	var keyword : String = ""

	var posts : [Post] = []
	var postSelectable : [Bool] = []
	var postsPerRequest : Int = 30
	
	var currentPage : Int = 1
	
	var compact : Bool = true
	
	var cellWidth : CGFloat!
	
	var columnNum : Int!
	
	var api : KonaAPI!
	
	var alert : AWAlertView?
	
	var isFromDetailTableVC = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if UserDefaults.standard.object(forKey: "tabToSelect") != nil {
			let tabToSelect = UserDefaults.standard.integer(forKey: "tabToSelect")
			UserDefaults.standard.removeObject(forKey: "tabToSelect")
			self.tabBarController!.selectedIndex = tabToSelect
		}
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		self.refreshControl.tintColor = UIColor.konaColor()
		self.collectionView!.addSubview(self.refreshControl)
		
		self.refresh()
    }
	
	func refresh(){
		
		self.r18 = Yuno().baseUrl().contains(".com")
		
		self.compact = UserDefaults.standard.integer(forKey: "viewMode") == 1
		
		print("compact: \(self.compact)")
		
		if UIDevice.current().model.hasPrefix("iPad"){
			self.columnNum = 3
		}
		else{
			if CGSize.screenSize().width >= 375 && self.compact {
				self.columnNum = 2
			}
			else{
				self.columnNum = 1
			}
		}
		self.cellWidth = CGSize.screenSize().width/CGFloat(self.columnNum) - 5
		
		let layout : UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
		layout.sectionInset = UIEdgeInsetsMake(0, (CGSize.screenSize().width/CGFloat(self.columnNum) - self.cellWidth)/2, 0, (CGSize.screenSize().width/CGFloat(self.columnNum) - self.cellWidth)/2)

		self.currentPage = 1
		self.posts = []
		self.collectionView!.reloadData()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem()
		if self.r18 {
			let r18Label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
			r18Label.textColor = UIColor.konaColor()
			r18Label.text = "R18"
			r18Label.textAlignment = NSTextAlignment.right
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: r18Label)
		}
		self.loading = SteamLoadingView(barNumber: nil, color: UIColor.konaColor(), minHeight: 10, maxHeight: 80, width: 20, spacing: 10, animationDuration: nil, deltaDuration: nil, delay: nil, options: nil)
		self.loading.alpha = 0.8
		self.view.addSubview(self.loading)
		
		if (self.keyword == ""){
			self.title = "Home".localized
		}
		else{
			self.title = self.keyword
		}
		self.api = KonaAPI(r18: self.r18, delegate: self, errorDelegate: self)
		self.loadMore()
		
		self.refreshControl.endRefreshing()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.posts.count
    }
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if (indexPath as NSIndexPath).row == self.posts.count - (self.posts.count >= 4 ? 5 : 1) {
			self.loadMore()
		}
	}

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
		
		if let img = Yuno().fetchImageWithKey("Preview", key: self.posts[(indexPath as NSIndexPath).row].previewUrl) {
			cell.imageView.image = img
			self.postSelectable[(indexPath as NSIndexPath).row] = true
		}
		else{
			cell.imageView.image = UIImage.imageWithColor(UIColor.placeHolderImageColor())
			downloadImg(self.posts[(indexPath as NSIndexPath).row].previewUrl, view: cell.imageView, index: (indexPath as NSIndexPath).row)
		}
		
        return cell
    }
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if !self.postSelectable[(indexPath as NSIndexPath).row] {return}
		let detailVC : DetailViewController = DetailViewController()
		detailVC.postUrl = self.posts[(indexPath as NSIndexPath).row].postUrl
		detailVC.heightOverWidth = self.posts[(indexPath as NSIndexPath).row].heightOverWidth
		detailVC.imageUrl = self.posts[(indexPath as NSIndexPath).row].url
		detailVC.smallImage =  (self.collectionView!.cellForItem(at: indexPath) as! ImageCell).imageView!.image
		detailVC.post = self.posts[(indexPath as NSIndexPath).row]
		self.navigationController!.pushViewController(detailVC, animated: true)
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		self.collectionView!.reloadData()
	}

	func downloadImg(_ url : String, view : UIImageView, index : Int){
				
		let manager = AFHTTPSessionManager()
		manager.responseSerializer = AFImageResponseSerializer()
		manager.get(url, parameters: nil, progress: nil, success: {(task, response) in
			UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
				view.image = response as? UIImage
				}, completion: {(finished) in
					self.postSelectable[index] = true
			})
			Yuno().saveImageWithKey("Preview", image: view.image!, key: url, skipUpload: false)
			}, failure: {(task, error) in
				print (error.localizedDescription)
				
				if let _alert = self.alert {
					if !_alert.alertHidden {
						return
					}
				}
				self.alert = AWAlertView.networkAlertFromError(error)
				self.navigationController?.view.addSubview(self.alert!)
				self.alert!.showAlert()
		})
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		return CGSize(width: self.cellWidth, height: self.cellWidth * self.posts[(indexPath as NSIndexPath).row].heightOverWidth)
	}
	
	func loadMore(){
		self.api.getPosts(self.postsPerRequest, page: self.currentPage, tag: self.keyword)
		if !UserDefaults.standard.bool(forKey: "feedbackFinished") {
			if UserDefaults.standard.integer(forKey: "viewCount") > Yuno.viewCountBeforeFeedback {
				UserDefaults.standard.set(true, forKey: "feedbackFinished")
				_ = FeedbackManager(parentVC: self, backgroundVC: self.tabBarController!, baseColor: UIColor.themeColor(), secondaryColor: UIColor.konaColor(), dismissButtonColor: UIColor.konaColor())
			}
		}
	}
	
	func konaAPIDidGetPost(_ ary: [Post]) {
		if ary.count == 0 && self.keyword != "" {
			self.handleEmtptySearch()
			return
		}
		if ary.count == 0 && self.keyword == "" {
			//when all posts in first fetch are R18
			self.currentPage += 1
			self.loadMore()
			return
		}
		self.currentPage += 1
		self.loading.removeFromSuperview()
		self.posts += ary
		self.postSelectable += [Bool](repeating: false, count: ary.count)
		var index : [IndexPath] = []
		for i in self.collectionView!.numberOfItems(inSection: 0) ..< self.posts.count {
			index.append(IndexPath(row: i, section: 0))
		}
		self.collectionView!.insertItems(at: index)
	}
	
	func konaAPIGotError(_ error: NSError) {
		if let _alert = self.alert {
			if !_alert.alertHidden {
				return
			}
		}
		self.alert = AWAlertView.networkAlertFromError(error)
		self.navigationController?.view.addSubview(self.alert!)
		self.alert!.showAlert()
	}
	
	func konaHTMLParserFinishedParsing(_ tags: [String]) {
		if (self.searchVC != nil && self.posts.count == 0){
			if self.isFromDetailTableVC {
				self.alert = AWAlertView.redAlertFromTitleAndMessage("No Result Found".localized, message: "Post with this tag does not exist. Please try another tag".localized)
				self.navigationController!.view.addSubview(self.alert!)
				self.alert!.showAlert()
				self.navigationController!.popViewController(animated: true)
				return
			}
			self.searchVC!.noResult = true
			if (tags.count > 0){
				self.searchVC!.suggestedTag = tags
			}
			self.navigationController!.popViewController(animated: true)
		}
	}
	
	//Parse HTML and get suggested tags
	func handleEmtptySearch(){
		let konaParser = KonaHTMLParser(delegate: self, errorDelegate: self)
		konaParser.getSuggestedTagsFromEmptyTag(self.keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!)
	}
}
