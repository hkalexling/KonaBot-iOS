//
//  IAPViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 15/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import StoreKit

class IAPViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	var loading : RZSquaresLoading!
	
	let contentLabel = UILabel()
	let button = UIButton()
	let titleLabel = UILabel()
	
	let productIdentifiers = Set(["hkalexling.KonaBot.buyMeACoffee"])
	var product: SKProduct?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let loadingSize : CGFloat = 80
		self.loading = RZSquaresLoading(frame: CGRectMake((CGSize.screenSize().width - loadingSize)/2, (CGSize.screenSize().height - loadingSize)/2, loadingSize, loadingSize))
		self.loading.color = UIColor.konaColor()
		self.view.addSubview(self.loading)
		
        self.requestProductData()
		self.viewSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func viewSetup(){
		self.view.backgroundColor = UIColor.themeColor()
		
		let contentWidth : CGFloat = CGSize.screenSize().width * 0.8
		let contentHeight : CGFloat = CGSize.screenSize().height/3
		
		self.contentLabel.frame = CGRectMake(CGSize.screenSize().width/2 - contentWidth/2, CGSize.screenSize().height/2 - contentHeight/2, contentWidth, contentHeight)
		self.contentLabel.text = ""
		self.contentLabel.textAlignment = NSTextAlignment.Center
		self.contentLabel.textColor = UIColor.konaColor()
		self.contentLabel.backgroundColor = UIColor.clearColor()
		self.contentLabel.numberOfLines = 0
		self.contentLabel.lineBreakMode = .ByWordWrapping
		self.view.addSubview(self.contentLabel)
		
		let titleHeight : CGFloat = 30
		self.titleLabel.frame = CGRectMake(0, CGSize.screenSize().height/2 - contentHeight/2 - 10 - titleHeight, CGSize.screenSize().width, titleHeight)
		self.titleLabel.textAlignment = .Center
		self.titleLabel.text = ""
		self.titleLabel.backgroundColor = UIColor.clearColor()
		self.titleLabel.textColor = UIColor.konaColor()
		self.titleLabel.font = UIFont.boldSystemFontOfSize(23)
		self.view.addSubview(self.titleLabel)
		
		let buttonWidth : CGFloat = 100
		let buttonHeight : CGFloat = 30
		
		self.button.frame = CGRectMake(CGSize.screenSize().width/2 - buttonWidth/2, CGSize.screenSize().height/2 + self.contentLabel.frame.height/2 + 10, buttonWidth, buttonHeight)
		self.button.backgroundColor = UIColor.clearColor()
		self.button.layer.cornerRadius = 5
		self.button.layer.borderColor = UIColor.konaColor().CGColor
		self.button.layer.borderWidth = 1.5
		self.button.setTitleColor(UIColor.konaColor(), forState: .Normal)
		self.button.addTarget(self, action: Selector("buyProduct"), forControlEvents: .TouchDown)
		self.button.hidden = true
		self.view.addSubview(self.button)
	}
	
	func requestProductData(){
		if SKPaymentQueue.canMakePayments() {
			let request = SKProductsRequest(productIdentifiers:
				self.productIdentifiers)
			request.delegate = self
			request.start()
		} else {
			let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
				alert.dismissViewControllerAnimated(true, completion: nil)
				
				let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
				if url != nil
				{
					UIApplication.sharedApplication().openURL(url!)
				}
				
			}))
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
				alert.dismissViewControllerAnimated(true, completion: nil)
			}))
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		
		var products = response.products
		if (products.count != 0) {
			self.product = products[0] as SKProduct
			self.contentLabel.text = self.product!.localizedDescription
			self.titleLabel.text = self.product!.localizedTitle
			self.getPrice()
		} else {
			print("No products found")
		}
		
		for product in products
		{
			print("Product not found: \(product)")
		}
	}
	
	func buyProduct() {
		let payment = SKPayment(product: self.product!)
		SKPaymentQueue.defaultQueue().addPayment(payment)
	}
	
	func getPrice(){
		let numberFormatter = NSNumberFormatter()
		numberFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
		numberFormatter.numberStyle = .CurrencyStyle
		numberFormatter.locale = self.product!.priceLocale
		
		self.button.setTitle(numberFormatter.stringFromNumber(self.product!.price), forState: .Normal)
		self.button.hidden = false
		self.loading.removeFromSuperview()
	}
	
	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

		for transaction in transactions {
			
			switch transaction.transactionState {
				
			case SKPaymentTransactionState.Purchased:
				print("Transaction Approved")
				print("Product Identifier: \(transaction.payment.productIdentifier)")
				self.thanks()
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				
			case SKPaymentTransactionState.Failed:
				print("Transaction Failed")
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
			default:
				break
			}
		}
	}
	
	func thanks(){
		self.titleLabel.hidden = true
		self.button.hidden = true
		self.contentLabel.text = "Thanks for your donation!\n\nIt's a huge motivation for me to maintain this project and keep it free of charge :)".localized
	}
}
