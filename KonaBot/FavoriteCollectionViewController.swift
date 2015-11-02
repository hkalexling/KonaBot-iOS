//
//  FavoriteCollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 2/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class FavoriteCollectionViewController: UICollectionViewController {
	
	var favoritePostList : [String]!
	var imageList : [UIImage]!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Favorite"
    }
	
	override func viewWillAppear(animated: Bool) {
		self.favoritePostList = NSKeyedUnarchiver.unarchiveObjectWithData(NSUserDefaults.standardUserDefaults().objectForKey("favoriteList") as! NSData) as! [String]
		self.imageList = NSKeyedUnarchiver.unarchiveObjectWithData(NSUserDefaults.standardUserDefaults().objectForKey("imageList") as! NSData) as! [UIImage]
		self.collectionView!.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.favoritePostList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
		
		cell.imageView.image = self.imageList[indexPath.row]
		
        return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let detailVC = DetailViewController()
		detailVC.postUrl = self.favoritePostList[indexPath.row]
		let frame = collectionView.cellForItemAtIndexPath(indexPath)?.frame
		detailVC.heightOverWidth = frame!.height/frame!.width
		detailVC.smallImage = self.imageList[indexPath.row]
		detailVC.view.backgroundColor = UIColor.whiteColor()
		self.navigationController!.pushViewController(detailVC, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let size = self.imageList[indexPath.row].size
		let width = CGSize.screenSize().width
		let height = width * (size.height / size.width)
		return CGSizeMake(width, height)
	}
}
