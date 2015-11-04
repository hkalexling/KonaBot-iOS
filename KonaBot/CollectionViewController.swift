//
//  CollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 31/10/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Kanna

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
	
	var refreshControl : UIRefreshControl!
	
	var baseUrl : String!
	
	var searchVC : SearchViewController?
	var loading : RZSquaresLoading!

	var keyword : String = ""
	
	var postUrls : [String] = []
	var imageUrls : [String] = []
	var heightOverWidth : [CGFloat] = []
	
	var currentPage : Int = 1
	
	var numberOfPagesTried : Int = 0
	var maxNumberOfPagesToTry : Int = 3
	
	var compact : Bool = true
	
	var cellWidth : CGFloat!
	
	var columnNum : Int!

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
		
		self.postUrls = []
		self.imageUrls = []
		self.heightOverWidth = []
		self.collectionView!.reloadData()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem()
		self.baseUrl = Yuno().baseUrl()
		if self.baseUrl.containsString(".com"){
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
			self.title = "Featured"
		}
		else{
			self.title = self.keyword
		}
		self.getHtml("\(self.baseUrl)/post?tags=\(self.keyword)")
		
		self.refreshControl.endRefreshing()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageUrls.count
    }
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		if (self.numberOfPagesTried < self.maxNumberOfPagesToTry){
			if (self.imageUrls.count > 3){
				if (indexPath.row == imageUrls.count - 3){
					self.loadMore()
				}
			}
			else{
				if (indexPath.row == imageUrls.count - 1){
					self.loadMore()
				}
			}
		}
	}

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
		
		cell.imageView.image = UIImage.imageWithColor(UIColor.darkGrayColor())
		downloadImg(self.imageUrls[indexPath.row], view: cell.imageView)
		
        return cell
    }
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let detailVC : DetailViewController = DetailViewController()
		detailVC.postUrl = self.postUrls[indexPath.row]
		detailVC.heightOverWidth = self.heightOverWidth[indexPath.row]
		detailVC.smallImage =  (self.collectionView!.cellForItemAtIndexPath(indexPath) as! ImageCell).imageView!.image
		detailVC.view.backgroundColor = UIColor.whiteColor()
		self.navigationController!.pushViewController(detailVC, animated: true)
	}

	func downloadImg(url : String, view : UIImageView){
		let requestOperation : AFHTTPRequestOperation = AFHTTPRequestOperation(request: NSURLRequest(URL: NSURL(string: url)!))
		requestOperation.responseSerializer = AFImageResponseSerializer()
		requestOperation.setCompletionBlockWithSuccess({(operation: AFHTTPRequestOperation!,
			responseObject: AnyObject!) in
				view.image = responseObject as? UIImage
			},
			failure: { (operation: AFHTTPRequestOperation!,
				error: NSError!) in
				print ("Error: \(error)")
			}
		)
		requestOperation.start()
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		return CGSize(width: self.cellWidth, height: self.cellWidth * self.heightOverWidth[indexPath.row])
	}
	
	func loadMore(){
		self.currentPage++
		self.getHtml("\(self.baseUrl)/post?page=\(self.currentPage)&tags=\(self.keyword)")
	}

	func getHtml(url : String){
		let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		
		manager.GET(url, parameters: nil,
			success: {(operation, responseObject) -> Void in
				
				let html : NSString = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)!
				self.parse(html as String)
				var index : [NSIndexPath] = []
				for (var i = self.collectionView!.numberOfItemsInSection(0); i < self.imageUrls.count; i++){
					index.append(NSIndexPath(forRow: i, inSection: 0))
				}
				self.collectionView!.insertItemsAtIndexPaths(index)
			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
				let alert = UIAlertController.alertWithOKButton("Network Error", message: error.localizedDescription)
				self.presentViewController(alert, animated: true, completion: nil)
		})
	}
	
	func parse(htmlString : String){
		if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
			let ulList = doc.css("ul#post-list-posts")
			for ul in ulList {
				for a in ul.css("a"){
					if a.className != nil {
						if a.className! == "thumb"{
							self.postUrls.append(a["href"]!)
						}
					}
				}
				for img in ul.css("img"){
					self.imageUrls.append(img["src"]!)
					let height : CGFloat = CGFloat((img["height"]! as NSString).floatValue)
					let width : CGFloat = CGFloat((img["width"]! as NSString).floatValue)
					self.heightOverWidth.append(height/width)
				}
				self.loading.removeFromSuperview()
			}
			if ulList.count == 0 {
				if (self.numberOfPagesTried < self.maxNumberOfPagesToTry){
					self.numberOfPagesTried++
					loadMore()
				}
				else{
					var suggestedTag : [String] = []
					for div in doc.css("div"){
						if (div.className != nil) {
							if (div.className! == "status-notice"){
								for span in div.css("span"){
									let a = span.css("a")[0]
									suggestedTag.append(a.text!)
								}
							}
						}
					}
					if (self.searchVC != nil && self.postUrls.count == 0){
						self.searchVC!.noResult = true
						if (suggestedTag.count > 0){
							self.searchVC!.suggestedTag = suggestedTag
						}
						self.navigationController!.popViewControllerAnimated(true)
					}
				}
			}
		}
	}
}
