//
//  SearchViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 1/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Kanna

class SearchViewController: UIViewController, UISearchBarDelegate {
	
	let hiddenTags : [String] = ["nipples", "cleavage", "pussy", "nude" , "ass", "panties", "breasts"]
	
	@IBOutlet weak var noResultLabel: UILabel!
	var searchBar:UISearchBar = UISearchBar()
	
	var loading : RZSquaresLoading!
	
	var suggestedTag : [String] = []
	var noResult : Bool = false
	
	var tagButtons : [UIButton] = []
	var youMeantLabel: UILabel?
	
	var topTags : [String] = []
	var topTagLabel : UILabel!
	
	var keyword : String!
	
	var baseUrl : String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.baseUrl = Yuno().baseUrl()
		
		self.view.backgroundColor = UIColor.themeColor()
		
		self.searchBar.frame = CGRectMake(0, 0, CGSize.screenSize().width, 20)
		self.searchBar.placeholder = "Search tag"
		self.navigationItem.titleView = self.searchBar
		
		let loadingSize : CGFloat = 80
		self.loading = RZSquaresLoading(frame: CGRectMake((CGSize.screenSize().width - loadingSize)/2, (CGSize.screenSize().height - loadingSize)/2, loadingSize, loadingSize))
		self.loading.color = UIColor.konaColor()
		self.view.addSubview(self.loading)

		self.searchBar.delegate = self
		
		let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
		self.view.addGestureRecognizer(tapRecognizer)
    }
	
	override func viewWillDisappear(animated: Bool) {
		self.noResult = false
		self.suggestedTag = []
		
		for btn in self.tagButtons{
			btn.removeFromSuperview()
		}
		self.tagButtons = []
		if (youMeantLabel != nil){
			self.youMeantLabel!.removeFromSuperview()
		}
		if (self.topTagLabel != nil){
			self.topTagLabel.hidden = true
		}
		
		self.noResultLabel.alpha = 1.0
		
		self.noResultLabel.hidden = !noResult
	}
	
	override func viewWillAppear(animated: Bool) {
		self.noResultLabel.hidden = !noResult
		
		if (self.noResult){
			if (self.suggestedTag.count > 0){
				self.handleSuggestedTags()
			}
		}
		else{
			if (self.topTags.count > 0){
				self.showTopTags()
			}
			else{
				self.getTopTags()
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func hideKeyboard(){
		self.searchBar.endEditing(true)
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		self.hideKeyboard()
		var searchText = self.searchBar.text!
		searchText = self.prepareSearchKeyword(searchText)
		if (!searchText.isEmpty){
			if (searchText == "r18"){
				self.toggleR18()
				return
			}
			self.keyword = searchText
			self.handleSearch()
		}
	}
	
	func toggleR18(){
		let r18 = NSUserDefaults.standardUserDefaults().boolForKey("r18")
		if r18 {
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: "r18")
		}
		else{
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "r18")
		}
	}
	
	func prepareSearchKeyword(keyword : String) -> String{
		var original = keyword
		while(original.hasPrefix(" ")){
			original.removeAtIndex(original.startIndex)
		}
		while(original.hasSuffix(" ")){
			original.removeAtIndex(original.endIndex.advancedBy(-1))
		}
		original = original.stringByReplacingOccurrencesOfString(" ", withString: "_").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
		return original
	}
	
	func handleSearch(){
		self.performSegueWithIdentifier("segueFromSearchVCToCollectionVC", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "segueFromSearchVCToCollectionVC"){
			let destVC = segue.destinationViewController as! CollectionViewController
			destVC.keyword = self.keyword
			destVC.searchVC = self
		}
	}
	
	func handleSuggestedTags(){
		UIView.animateWithDuration(1.5, animations: {
				self.noResultLabel.alpha = 0
			}, completion: {(finished : Bool) in
				self.showSuggestions()
		})
	}
	
	func showSuggestions(){
		let buttonHeight : CGFloat = 30
		let buttonWidht : CGFloat = 200
		let buttonGap : CGFloat = 10
		let count = self.suggestedTag.count
		let y = CGSize.screenSize().height/2 - CGFloat(count)/2.0 * buttonHeight - CGFloat(count - 1)/2.0 * buttonGap
		
		self.youMeantLabel = UILabel(frame: CGRectMake(0, y - 10, CGSize.screenSize().width, buttonHeight))
		self.youMeantLabel!.text = "Maybe you meant..."
		self.youMeantLabel!.font = UIFont.systemFontOfSize(20)
		self.youMeantLabel!.backgroundColor = UIColor.themeColor()
		self.youMeantLabel!.textColor = UIColor.whiteColor()
		self.youMeantLabel!.textAlignment = NSTextAlignment.Center
		self.view.addSubview(youMeantLabel!)
		
		for (var i : Int = 0; i < self.suggestedTag.count; i++){
			let button = UIButton(type: UIButtonType.System) as UIButton
			button.backgroundColor = UIColor.themeColor()
			button.setTitle(self.suggestedTag[i], forState: .Normal)
			button.frame = CGRectMake((CGSize.screenSize().width - buttonWidht)/2, y + (buttonHeight + buttonGap) * CGFloat(i + 1), buttonWidht, buttonHeight)
			button.addTarget(self, action: Selector("suggestionButtonTapped:"), forControlEvents: .TouchUpInside)
			button.tintColor = UIColor.konaColor()
			self.tagButtons.append(button)
			self.view.addSubview(button)
		}
	}
	
	func showTopTags(){
		
		let numberOfTagsToShow : Int = 5
		var randomTags : [String] = []
		while (randomTags.count < numberOfTagsToShow){
			let ranInt = Int.randInRange(0..<self.topTags.count)
			let randomTag = self.topTags[ranInt]
			if (randomTags.contains(randomTag)){
				continue
			}
			else{
				randomTags.append(randomTag)
			}
		}
		
		let buttonHeight : CGFloat = 30
		let buttonWidht : CGFloat = 200
		let buttonGap : CGFloat = 10
		let count = randomTags.count
		let y = CGSize.screenSize().height/2 - CGFloat(count)/2.0 * buttonHeight - CGFloat(count - 1)/2.0 * buttonGap
		
		if (self.topTagLabel != nil){
			self.topTagLabel.hidden = false
		}
		else{
			self.topTagLabel = UILabel(frame: CGRectMake(0, y - 10, CGSize.screenSize().width, buttonHeight))
			self.topTagLabel.text = "Top Tags:"
			self.topTagLabel.font =  UIFont.systemFontOfSize(20)
			self.topTagLabel.backgroundColor = UIColor.themeColor()
			self.topTagLabel.textColor = UIColor.whiteColor()
			self.topTagLabel.textAlignment = NSTextAlignment.Center
			
			self.view.addSubview(topTagLabel)
		}
		
		for (var i : Int = 0; i < randomTags.count; i++){
			let button = UIButton(type: UIButtonType.System) as UIButton
			button.backgroundColor = UIColor.themeColor()
			button.setTitle(randomTags[i], forState: .Normal)
			button.frame = CGRectMake((CGSize.screenSize().width - buttonWidht)/2, y + (buttonHeight + buttonGap) * CGFloat(i + 1), buttonWidht, buttonHeight)
			button.addTarget(self, action: Selector("suggestionButtonTapped:"), forControlEvents: .TouchUpInside)
			button.tintColor = UIColor.konaColor()
			self.tagButtons.append(button)
			self.view.addSubview(button)
		}
	}
	
	func suggestionButtonTapped(sender : UIButton){
		let suggestion : String = sender.titleLabel!.text!
		self.keyword = suggestion
		self.searchBar.text = suggestion
		self.handleSearch()
	}
	
	func getTopTags(){
		self.getHtml("\(self.baseUrl)/tag?name=&type=0&order=count")
	}
	
	func getHtml(url : String){
		let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		
		manager.GET(url, parameters: nil,
			success: {(operation, responseObject) -> Void in
				
				let html : NSString = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)!
				self.parse(html as String)
				
			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
				let alert = UIAlertController.alertWithOKButton("Network Error", message: error.localizedDescription)
				self.presentViewController(alert, animated: true, completion: nil)
		})
	}
	
	func parse(htmlString : String){
		if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
			let tbody = doc.css("tbody")[3]
			for tr in tbody.css("tr"){
				for td in tr.css("td"){
					if (td.className != nil){
						if (td.className! == "tag-type-general"){
							if(td.text != nil){
								let tag = td.text!.stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString("?", withString: "")
								if (self.hiddenTags.contains(tag) && !NSUserDefaults.standardUserDefaults().boolForKey("r18")){continue}
								else{
									self.topTags.append(tag)
								}
							}
						}
					}
				}
			}
		}
		self.loading.removeFromSuperview()
		self.showTopTags()
	}
}
