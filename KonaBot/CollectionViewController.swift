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

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, KonaAPIDelegate {
	
	var refreshControl : UIRefreshControl!
	
	var searchVC : SearchViewController?
	var loading : RZSquaresLoading!
	
	var r18 : Bool = false

	var keyword : String = ""

	var posts : [Post] = []
	var postsPerRequest : Int = 30
	
	var currentPage : Int = 1
	
	var numberOfPagesTried : Int = 0
	var maxNumberOfPagesToTry : Int = 3
	
	var compact : Bool = true
	
	var cellWidth : CGFloat!
	
	var columnNum : Int!
	
	var api : KonaAPI!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if NSUserDefaults.standardUserDefaults().objectForKey("tabToSelect") != nil {
			let tabToSelect = NSUserDefaults.standardUserDefaults().integerForKey("tabToSelect")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("tabToSelect")
			self.tabBarController!.selectedIndex = tabToSelect
		}
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: Selector("refresh"), forControlEvents: .ValueChanged)
		self.refreshControl.tintColor = UIColor.konaColor()
		self.refreshControl.alpha = 0.5
		self.collectionView!.addSubview(self.refreshControl)
		
		self.refresh()
    }
	
	func refresh(){
		
		self.r18 = Yuno().baseUrl().containsString(".com")
		
		self.compact = NSUserDefaults.standardUserDefaults().integerForKey("viewMode") == 1
		
		if UIDevice.currentDevice().model.hasPrefix("iPad"){
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
			let r18Label = UILabel(frame: CGRectMake(0, 0, 80, 20))
			r18Label.backgroundColor = UIColor.themeColor()
			r18Label.textColor = UIColor.konaColor()
			r18Label.text = "R18"
			r18Label.textAlignment = NSTextAlignment.Right
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: r18Label)
		}
		
		let loadingSize : CGFloat = 80
		self.loading = RZSquaresLoading(frame: CGRectMake(CGSize.screenSize().width/2 - loadingSize/2, CGSize.screenSize().height/2 - loadingSize/2, loadingSize, loadingSize))
		self.loading.color = UIColor.konaColor()
		self.view.addSubview(loading)
		
		if (self.keyword == ""){
			self.title = "Home".localized
		}
		else{
			self.title = self.keyword
		}
		self.api = KonaAPI(r18: self.r18, delegate: self)
		self.loadMore()
		
		self.refreshControl.endRefreshing()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.posts.count
    }
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row == self.posts.count - 5 {
			self.loadMore()
		}
	}

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
		
		if let img = Yuno().fetchImageWithKey("Preview", key: self.posts[indexPath.row].previewUrl) {
			cell.imageView.image = img
		}
		else{
			cell.imageView.image = UIImage.imageWithColor(UIColor.darkGrayColor())
			downloadImg(self.posts[indexPath.row].previewUrl, view: cell.imageView)
		}
		
        return cell
    }
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let detailVC : DetailViewController = DetailViewController()
		detailVC.postUrl = self.posts[indexPath.row].postUrl
		detailVC.heightOverWidth = self.posts[indexPath.row].heightOverWidth
		detailVC.imageUrl = self.posts[indexPath.row].url
		detailVC.smallImage =  (self.collectionView!.cellForItemAtIndexPath(indexPath) as! ImageCell).imageView!.image
		//self.navigationController!.pushViewController(detailVC, animated: true)
		self.navigationController!.pushViewController(detailVC, animated: true)
	}
	
	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		self.collectionView!.reloadData()
	}

	func downloadImg(url : String, view : UIImageView){
		
		let manager = AFHTTPSessionManager()
		manager.responseSerializer = AFImageResponseSerializer()
		manager.GET(url, parameters: nil, progress: nil, success: {(task, response) in
			UIView.transitionWithView(view, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
				view.image = response as? UIImage
				}, completion: nil)
			Yuno().saveImageWithKey("Preview", image: view.image!, key: url)
			}, failure: {(task, error) in
				print (error.localizedDescription)
		})
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		return CGSize(width: self.cellWidth, height: self.cellWidth * self.posts[indexPath.row].heightOverWidth)
	}
	
	func loadMore(){
		self.api.getPost(self.postsPerRequest, page: self.currentPage, tag: self.keyword)
	}
	
	func getHtml(url : String){
		let manager = AFHTTPSessionManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
	
		manager.GET(url, parameters: nil, progress: nil,
			success: {(operation, responseObject) -> Void in
				
				let html : NSString = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)!
				self.parse(html as String)

			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
				let alert = UIAlertController.alertWithOKButton("Network Error".localized, message: error.localizedDescription)
				self.presentViewController(alert, animated: true, completion: nil)
		})
	}
	
	func parse(htmlString : String){
		if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
			let ulList = doc.css("ul#post-list-posts")
			if ulList.count == 0 {
				var suggestedTag : [String] = []
				for div in doc.css("div"){
					if (div.className != nil) {
						if (div.className! == "status-notice"){
							for span in div.css("span"){
								let a = span.at_css("a")!
								suggestedTag.append(a.text!)
							}
						}
					}
				}
				if (self.searchVC != nil && self.posts.count == 0){
					self.searchVC!.noResult = true
					if (suggestedTag.count > 0){
						self.searchVC!.suggestedTag = suggestedTag
					}
					self.navigationController!.popViewControllerAnimated(true)
				}
			}
		}
	}
	
	func konaAPIDidGetPosts(ary: [Post]) {
		if ary.count == 0 && self.keyword != "" {
			self.handleEmtptySearch()
			return
		}
		self.currentPage++
		self.loading.removeFromSuperview()
		self.posts += ary
		var index : [NSIndexPath] = []
		for (var i = self.collectionView!.numberOfItemsInSection(0); i < self.posts.count; i++){
			index.append(NSIndexPath(forRow: i, inSection: 0))
		}
		self.collectionView!.insertItemsAtIndexPaths(index)
	}
	
	func handleEmtptySearch(){
		self.getHtml("\(Yuno().baseUrl())/post?tags=\(self.keyword)")
	}
}
