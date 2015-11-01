//
//  CollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 31/10/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Kanna

class CollectionViewController: UICollectionViewController{
	
	var fromSearch : Bool = false
	var keyword : String = ""
	
	var postUrls : [String] = []
	var imageUrls : [String] = []
	var heightOverWidth : [CGFloat] = []
	
	var currentPage : Int = 1
	
	var selectedSmallImage : UIImage!
	var selectedPostUrl : String!
	var selectedHeightOverWidth : CGFloat!
	
	var numberOfPagesTried : Int = 0
	var maxNumberOfPagesToTry : Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if (!self.fromSearch){
			navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
		}
		self.getHtml("http://konachan.net/post?tags=\(self.keyword)")
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

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
		
		cell.imageView.image = UIImage.imageWithColor(UIColor.lightGrayColor())
		downloadImg(self.imageUrls[indexPath.row], view: cell.imageView)
		
        return cell
    }
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		self.selectedPostUrl = self.postUrls[indexPath.row]
		self.selectedHeightOverWidth = self.heightOverWidth[indexPath.row]
		self.selectedSmallImage = (self.collectionView!.cellForItemAtIndexPath(indexPath) as! ImageCell).imageView!.image
		self.performSegueWithIdentifier("segueToDetailVC", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "segueToDetailVC") {
			let destVC = segue.destinationViewController as! DetailViewController
			destVC.postUrl = self.selectedPostUrl
			destVC.heightOverWidth = self.selectedHeightOverWidth
			destVC.smallImage = self.selectedSmallImage
		}
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
		let collectionViewWidth = self.collectionView!.bounds.size.width
		return CGSize(width: collectionViewWidth, height: collectionViewWidth * self.heightOverWidth[indexPath.row])
	}
	
	func loadMore(){
		self.currentPage++
		self.getHtml("http://konachan.net/post?page=\(self.currentPage)&tags=\(self.keyword)")
	}
	
	func getHtml(url : String){
		let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		
		manager.GET(url, parameters: nil,
			success: {(operation, responseObject) -> Void in
				
				let html : NSString = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)!
				self.parse(html as String)
				self.collectionView!.reloadData()
			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
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
			}
			if ulList.count == 0 {
				if (self.numberOfPagesTried < self.maxNumberOfPagesToTry){
					self.numberOfPagesTried++
					loadMore()
				}
				else{
					print ("no reslt")
				}
			}
		}
	}
}
