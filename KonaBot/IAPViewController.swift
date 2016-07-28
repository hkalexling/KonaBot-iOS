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
	
	var loading : SteamLoadingView!
	
	let contentLabel = UILabel()
	let button = UIButton()
	let titleLabel = UILabel()
	
	let productIdentifiers = Set(["hkalexling.KonaBot.buyMeACoffee"])
	var product: SKProduct?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.loading = SteamLoadingView(barNumber: nil, color: UIColor.konaColor(), minHeight: 10, maxHeight: 80, width: 20, spacing: 10, animationDuration: nil, deltaDuration: nil, delay: nil, options: nil)
		self.loading.alpha = 0.8
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
		
		self.contentLabel.frame = CGRect(x: CGSize.screenSize().width/2 - contentWidth/2, y: CGSize.screenSize().height/2 - contentHeight/2, width: contentWidth, height: contentHeight)
		self.contentLabel.text = ""
		self.contentLabel.textAlignment = NSTextAlignment.center
		self.contentLabel.textColor = UIColor.konaColor()
		self.contentLabel.backgroundColor = UIColor.clear()
		self.contentLabel.numberOfLines = 0
		self.contentLabel.lineBreakMode = .byWordWrapping
		self.view.addSubview(self.contentLabel)
		
		let titleHeight : CGFloat = 30
		self.titleLabel.frame = CGRect(x: 0, y: CGSize.screenSize().height/2 - contentHeight/2 - 10 - titleHeight, width: CGSize.screenSize().width, height: titleHeight)
		self.titleLabel.textAlignment = .center
		self.titleLabel.text = ""
		self.titleLabel.backgroundColor = UIColor.clear()
		self.titleLabel.textColor = UIColor.konaColor()
		self.titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
		self.view.addSubview(self.titleLabel)
		
		let buttonWidth : CGFloat = 100
		let buttonHeight : CGFloat = 30
		
		self.button.frame = CGRect(x: CGSize.screenSize().width/2 - buttonWidth/2, y: CGSize.screenSize().height/2 + self.contentLabel.frame.height/2 + 10, width: buttonWidth, height: buttonHeight)
		self.button.backgroundColor = UIColor.clear()
		self.button.layer.cornerRadius = 5
		self.button.layer.borderColor = UIColor.konaColor().cgColor
		self.button.layer.borderWidth = 1.5
		self.button.setTitleColor(UIColor.konaColor(), for: UIControlState())
		self.button.addTarget(self, action: #selector(IAPViewController.buyProduct), for: .touchDown)
		self.button.isHidden = true
		self.view.addSubview(self.button)
	}
	
	func requestProductData(){
		if SKPaymentQueue.canMakePayments() {
			let request = SKProductsRequest(productIdentifiers:
				self.productIdentifiers)
			request.delegate = self
			request.start()
		} else {
			let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
				alert.dismiss(animated: true, completion: nil)
				
				let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
				if url != nil
				{
					UIApplication.shared().openURL(url!)
				}
				
			}))
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
				alert.dismiss(animated: true, completion: nil)
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		
		var products = response.products
		if (products.count != 0) {
			self.product = products[0] as SKProduct
			self.contentLabel.text = self.product!.localizedDescription
			self.titleLabel.text = self.product!.localizedTitle
			self.getPrice()
		} else {
			print("No products found", terminator: "")
		}
		
		for product in products
		{
			print("Product not found: \(product)", terminator: "")
		}
	}
	
	func buyProduct() {
		let payment = SKPayment(product: self.product!)
		SKPaymentQueue.default().add(payment)
	}
	
	func getPrice(){
		let numberFormatter = NumberFormatter()
		numberFormatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
		numberFormatter.numberStyle = .currency
		numberFormatter.locale = self.product!.priceLocale
		
		self.button.setTitle(numberFormatter.string(from: self.product!.price), for: UIControlState())
		self.button.isHidden = false
		self.loading.removeFromSuperview()
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

		for transaction in transactions {
			
			switch transaction.transactionState {
				
			case SKPaymentTransactionState.purchased:
				print("Transaction Approved", terminator: "")
				print("Product Identifier: \(transaction.payment.productIdentifier)", terminator: "")
				self.thanks()
				SKPaymentQueue.default().finishTransaction(transaction)
				
			case SKPaymentTransactionState.failed:
				print("Transaction Failed", terminator: "")
				SKPaymentQueue.default().finishTransaction(transaction)
			default:
				break
			}
		}
	}
	
	func thanks(){
		self.titleLabel.isHidden = true
		self.button.isHidden = true
		self.contentLabel.text = "Thanks for your donation!\n\nIt's a huge motivation for me to maintain this project and keep it free of charge :)".localized
	}
}
