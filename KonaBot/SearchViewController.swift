//
//  SearchViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 1/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Kanna
import AFNetworking

class SearchViewController: UIViewController, UISearchBarDelegate, KonaAPITagDelegate, KonaAPIErrorDelegate{
	
	@IBOutlet weak var noResultLabel: UILabel!
	var searchBar : UISearchBar = UISearchBar()
	
	var loading : SteamLoadingView!
	
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
		
		self.searchBar.frame = CGRect(x: 0, y: 0, width: CGSize.screenSize().width, height: 20)
		self.searchBar.placeholder = "Search tag".localized
		self.navigationItem.titleView = self.searchBar
		
		self.loading = SteamLoadingView(barNumber: nil, color: UIColor.konaColor(), minHeight: 10, maxHeight: 80, width: 20, spacing: 10, animationDuration: nil, deltaDuration: nil, delay: nil, options: nil)
		self.loading.alpha = 0.8
		self.view.addSubview(self.loading)

		self.searchBar.delegate = self
		
		let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.hideKeyboard))
		self.view.addGestureRecognizer(tapRecognizer)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
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
			self.topTagLabel.isHidden = true
		}
		
		self.noResultLabel.alpha = 1.0
		self.noResultLabel.textColor = UIColor.konaColor()
		self.noResultLabel.isHidden = !noResult
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.noResultLabel.isHidden = !noResult
		
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
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		self.hideKeyboard()
		var searchText = self.searchBar.text!
		searchText = self.prepareSearchKeyword(searchText)
		if (!searchText.isEmpty){
			self.keyword = searchText
			self.handleSearch()
		}
	}
	
	func toggleR18(){
		let r18 = UserDefaults.standard().bool(forKey: "r18")
		if r18 {
			UserDefaults.standard().set(false, forKey: "r18")
		}
		else{
			UserDefaults.standard().set(true, forKey: "r18")
		}
	}
	
	func prepareSearchKeyword(_ keyword : String) -> String{
		var original = keyword
		while(original.hasPrefix(" ")){
			original.remove(at: original.startIndex)
		}
		while(original.hasSuffix(" ")){
			original.remove(at: original.index(original.endIndex, offsetBy: -1))
		}
		original = original.replacingOccurrences(of: " ", with: "_")
		return original
	}
	
	func handleSearch(){
		self.performSegue(withIdentifier: "segueFromSearchVCToCollectionVC", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "segueFromSearchVCToCollectionVC"){
			let destVC = segue.destinationViewController as! CollectionViewController
			destVC.keyword = self.keyword
			destVC.searchVC = self
		}
	}
	
	func handleSuggestedTags(){
		UIView.animate(withDuration: 1.5, animations: {
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
		
		self.youMeantLabel = UILabel(frame: CGRect(x: 0, y: y - 10, width: CGSize.screenSize().width, height: buttonHeight))
		self.youMeantLabel!.text = "Maybe you meant...".localized
		self.youMeantLabel!.font = UIFont.systemFont(ofSize: 20)
		self.youMeantLabel!.backgroundColor = UIColor.themeColor()
		self.youMeantLabel!.textColor = UIColor.searchVCLabelColor()
		self.youMeantLabel!.textAlignment = NSTextAlignment.center
		self.view.addSubview(youMeantLabel!)
		
		for i in 0  ..< self.suggestedTag.count {
			let button = UIButton(type: UIButtonType.system) as UIButton
			button.backgroundColor = UIColor.themeColor()
			button.setTitle(self.suggestedTag[i], for: UIControlState())
			button.frame = CGRect(x: (CGSize.screenSize().width - buttonWidht)/2, y: y + (buttonHeight + buttonGap) * CGFloat(i + 1), width: buttonWidht, height: buttonHeight)
			button.addTarget(self, action: #selector(SearchViewController.suggestionButtonTapped(_:)), for: .touchUpInside)
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
			self.topTagLabel.isHidden = false
		}
		else{
			self.topTagLabel = UILabel(frame: CGRect(x: 0, y: y - 10, width: CGSize.screenSize().width, height: buttonHeight))
			self.topTagLabel.text = "Top Tags:".localized
			self.topTagLabel.font =  UIFont.systemFont(ofSize: 20)
			self.topTagLabel.backgroundColor = UIColor.themeColor()
			self.topTagLabel.textColor = UIColor.searchVCLabelColor()
			self.topTagLabel.textAlignment = NSTextAlignment.center
			
			self.view.addSubview(topTagLabel)
		}
		
		for i in 0 ..< randomTags.count {
			let button = UIButton(type: UIButtonType.system) as UIButton
			button.backgroundColor = UIColor.themeColor()
			button.setTitle(randomTags[i], for: UIControlState())
			button.frame = CGRect(x: (CGSize.screenSize().width - buttonWidht)/2, y: y + (buttonHeight + buttonGap) * CGFloat(i + 1), width: buttonWidht, height: buttonHeight)
			button.addTarget(self, action: #selector(SearchViewController.suggestionButtonTapped(_:)), for: .touchUpInside)
			button.tintColor = UIColor.konaColor()
			self.tagButtons.append(button)
			self.view.addSubview(button)
		}
	}
	
	func suggestionButtonTapped(_ sender : UIButton){
		let suggestion : String = sender.titleLabel!.text!
		self.keyword = suggestion
		self.searchBar.text = suggestion
		self.handleSearch()
	}
	
	func getTopTags(){
		let api = KonaAPI(r18: UserDefaults.standard().bool(forKey: "r18"), delegate: self, errorDelegate: self)
		api.getTags(50, type: 0, order: "count")
	}
	
	func konaAPIDidGetTag(_ ary: [String]) {
		self.topTags = ary
		self.loading.removeFromSuperview()
		self.showTopTags()
	}
	
	func konaAPIGotError(_ error: NSError) {
		let alert = AWAlertView.networkAlertFromError(error)
		self.navigationController?.view.addSubview(alert)
		alert.showAlert()
	}
}
