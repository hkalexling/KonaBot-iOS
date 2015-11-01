//
//  SearchViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 1/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate{

	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var noResultLabel: UILabel!
	
	var suggestedTag : [String] = []
	var noResult : Bool = false
	
	var tagButtons : [UIButton] = []
	var youMeantLabel: UILabel?
	
	var keyword : String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.searchTextField.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.searchTextField.bounds.height)
		self.searchTextField.delegate = self
		
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
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func hideKeyboard(){
		self.searchTextField.endEditing(true)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.hideKeyboard()
		var searchText = self.searchTextField.text!
		searchText = searchText.stringByReplacingOccurrencesOfString(" ", withString: "")
		if (!searchText.isEmpty){
			self.keyword = searchText
			self.handleSearch()
		}
		return true
	}
	
	func handleSearch(){
		self.performSegueWithIdentifier("segueFromSearchVCToCollectionVC", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "segueFromSearchVCToCollectionVC"){
			let destVC = segue.destinationViewController as! CollectionViewController
			destVC.fromSearch = true
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
		
		self.youMeantLabel = UILabel(frame: CGRectMake(0, y, CGSize.screenSize().width, buttonHeight))
		youMeantLabel!.text = "Maybe you meant..."
		self.youMeantLabel!.backgroundColor = UIColor.whiteColor()
		self.youMeantLabel!.textColor = UIColor.blackColor()
		self.youMeantLabel!.textAlignment = NSTextAlignment.Center
		self.view.addSubview(youMeantLabel!)
		
		for (var i : Int = 0; i < self.suggestedTag.count; i++){
			let button = UIButton(type: UIButtonType.System) as UIButton
			button.backgroundColor = UIColor.whiteColor()
			button.setTitle(self.suggestedTag[i], forState: .Normal)
			button.frame = CGRectMake((CGSize.screenSize().width - buttonWidht)/2, y + (buttonHeight + buttonGap) * CGFloat(i + 1), buttonWidht, buttonHeight)
			button.addTarget(self, action: Selector("suggestionButtonTapped:"), forControlEvents: .TouchUpInside)
			self.tagButtons.append(button)
			self.view.addSubview(button)
		}
	}
	
	func suggestionButtonTapped(sender : UIButton){
		let suggestion : String = sender.titleLabel!.text!
		self.keyword = suggestion
		self.handleSearch()
	}
}
