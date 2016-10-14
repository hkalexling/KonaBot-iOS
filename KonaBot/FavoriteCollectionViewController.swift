//
//  FavoriteCollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 2/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class FavoriteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
	
	let yuno = Yuno()
	
	var favoritePostList : [String] = []
	
	var label : UILabel = UILabel()
	
	var compact : Bool = true
	
	var cellWidth : CGFloat!
	
	var columnNum : Int!
	
	let previewQuility : CGFloat = 2
	
	var newFavUrls : [String] = []
	var newFavPostUrls : [String] = []
	var newFavNum = 0
	var downloadTask : URLSessionDownloadTask?
	var favUrlIndex = 0
	
	var favDownloadVC : CloudFavPostsDownloadViewController!
	var downloadDismissed = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Favorite".localized
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		self.compact = UserDefaults.standard.integer(forKey: "viewMode") == 1
		
		if UIDevice.current.model.hasPrefix("iPad"){
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
		
		self.favoritePostList = []
		self.collectionView?.reloadData()
		self.yuno.asyncFavoriteList { (list : [String]) in
			self.favoritePostList = list
			self.reload()
		}
	}
	
	func reload(){
		self.collectionView!.reloadData()
		if (self.favoritePostList.count == 0){
			self.showLabel()
		}
		else{
			self.label.removeFromSuperview()
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		self.label.removeFromSuperview()
	}
	
	func showLabel(){
		let height : CGFloat = 20
		self.label.text = "You haven't favorited any image yet".localized
		self.label.frame = CGRect(x: 0, y: CGSize.screenSize().height/2 - height/2, width: CGSize.screenSize().width, height: height)
		self.label.backgroundColor = UIColor.themeColor()
		self.label.textColor = UIColor.konaColor()
		self.label.textAlignment = NSTextAlignment.center
		self.view.addSubview(self.label)
	}

	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.favoritePostList.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
		
		cell.imageView.image = UIImage.imageWithColor(UIColor.placeHolderImageColor())
		DispatchQueue.global().async { 
			if var img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[(indexPath as NSIndexPath).row]){
				img = img.resize(cell.imageView.bounds.width * self.previewQuility)
				DispatchQueue.main.async(execute: {
					UIView.transition(with: cell.imageView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
						cell.imageView.image = img
					}, completion: nil)
				})
			}
		}
		
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let detailVC = DetailViewController()
		detailVC.postUrl = self.favoritePostList[(indexPath as NSIndexPath).row]
		let frame = collectionView.cellForItem(at: indexPath)?.frame
		detailVC.heightOverWidth = frame!.height/frame!.width
		detailVC.smallImage = (collectionView.cellForItem(at: indexPath) as! ImageCell).imageView.image
		self.navigationController!.pushViewController(detailVC, animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = (yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[(indexPath as NSIndexPath).row]))!.size
		let height = self.cellWidth * (size.height / size.width)
		return CGSize(width: self.cellWidth, height: height)
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		self.collectionView!.reloadData()
	}
}
