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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.searchTextField.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.searchTextField.bounds.height)
		self.searchTextField.delegate = self
		
		let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
		self.view.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func hideKeyboard(){
		self.searchTextField.endEditing(true)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.hideKeyboard()
		self.handleSearch()
		return true
	}
	
	func handleSearch(){
		let searchText = self.searchTextField.text!
		if (!searchText.isEmpty){
			self.performSegueWithIdentifier("segueFromSearchVCToCollectionVC", sender: self)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "segueFromSearchVCToCollectionVC"){
			let destVC = segue.destinationViewController as! CollectionViewController
			destVC.fromSearch = true
			destVC.keyword = self.searchTextField.text!
		}
	}
}
