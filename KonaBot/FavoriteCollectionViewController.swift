//
//  FavoriteCollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 2/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class FavoriteCollectionViewController: UICollectionViewController {
	
	let yuno = Yuno()
	
	var favoritePostList : [String] = []
	
	var label : UILabel = UILabel()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Favorite"
    }
	
	override func viewWillAppear(animated: Bool) {

		self.favoritePostList = self.yuno.favoriteList()
		self.collectionView!.reloadData()
		
		if (self.favoritePostList.count == 0){
			self.showLabel()
		}
	}
	
	override func viewDidDisappear(animated: Bool) {
		self.label.removeFromSuperview()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func showLabel(){
		let height : CGFloat = 20
		self.label.text = "You haven't favorited any image yet"
		self.label.frame = CGRectMake(0, CGSize.screenSize().height/2 - height/2, CGSize.screenSize().width, height)
		self.label.backgroundColor = UIColor.themeColor()
		self.label.textColor = UIColor.konaColor()
		self.label.textAlignment = NSTextAlignment.Center
		self.view.addSubview(self.label)
	}

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.favoritePostList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell

		if let img = yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[indexPath.row]){
			cell.imageView.image = img
		}
		
        return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let detailVC = DetailViewController()
		detailVC.postUrl = self.favoritePostList[indexPath.row]
		let frame = collectionView.cellForItemAtIndexPath(indexPath)?.frame
		detailVC.heightOverWidth = frame!.height/frame!.width
		detailVC.smallImage = yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[indexPath.row])
		detailVC.view.backgroundColor = UIColor.whiteColor()
		self.navigationController!.pushViewController(detailVC, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let size = (yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[indexPath.row]))!.size
		var width : CGFloat
		if UIDevice.currentDevice().model.hasPrefix("iPad"){
			width = CGSize.screenSize().height/3 - 10
		}
		else{
			if CGSize.screenSize().width >= 375{
				width = CGSize.screenSize().width/2 - 5
			}
			else{
				width = CGSize.screenSize().width
			}
		}
		let height = width * (size.height / size.width)
		return CGSizeMake(width, height)
	}
}
