//
//  Extension.swift
//  KonaBot
//
//  Created by Alex Ling on 1/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public extension String {
	var localized : String {
		return NSLocalizedString(self, comment: "")
	}
}

extension AWAlertView {
	static func networkAlertFromError (error : NSError) -> AWAlertView {
		return AWAlertView(title: "Network Error".localized, message: error.localizedDescription, height: 100, bgColor: UIColor(red: 239/255, green: 92/255, blue: 72/255, alpha: 1), textColor: UIColor.whiteColor())
	}
	static func alertFromTitleAndMessage (title : String, message : String) -> AWAlertView {
		return AWAlertView(title: title, message: message, height: 100, bgColor: UIColor(red: 48/255, green: 176/255, blue: 114/255, alpha: 1), textColor: UIColor.whiteColor())
	}
	static func redAlertFromTitleAndMessage (title : String, message : String) -> AWAlertView {
		return AWAlertView(title: title, message: message, height: 100, bgColor: UIColor(red: 239/255, green: 92/255, blue: 72/255, alpha: 1), textColor: UIColor.whiteColor())
	}
}

extension CGFloat {
	static func tabBarHeight() -> CGFloat{
		return 49
	}
	static func navitaionBarHeight() -> CGFloat{
		return 44
	}
	static func statusBarHeight() -> CGFloat {
		let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
		return Swift.min(statusBarSize.width, statusBarSize.height)
	}
}

extension UIButton {
	func block_setAction(block: ButtonActionBlock) {
		objc_setAssociatedObject(self, &ActionBlockKey, ActionBlockWrapper(block: block), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		addTarget(self, action: "block_handleAction:", forControlEvents: .TouchUpInside)
	}
	
	func block_handleAction(sender: UIButton) {
		let wrapper = objc_getAssociatedObject(self, &ActionBlockKey) as! ActionBlockWrapper
		wrapper.block()
	}
}

public extension UIImage {
	class func imageWithColor(color: UIColor) -> UIImage {
		let size = CGSizeMake(10, 10)
		let rect = CGRectMake(0, 0, size.width, size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	func coloredImage(color : UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		let context : CGContextRef? = UIGraphicsGetCurrentContext()
		CGContextTranslateCTM(context, 0, self.size.height)
		CGContextScaleCTM(context, 1.0, -1.0)
		CGContextSetBlendMode(context, .Normal)
		let rect : CGRect = CGRectMake(0, 0, self.size.width, self.size.height)
		CGContextClipToMask(context, rect, self.CGImage)
		color.setFill()
		CGContextFillRect(context, rect)
		let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage
	}
	func resize(newWidth: CGFloat) -> UIImage {
		
		let scale = newWidth / self.size.width
		let newHeight = self.size.height * scale
		UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
		self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
}

public extension Int{
	static func randInRange(range: Range<Int>) -> Int {
		return  Int(arc4random_uniform(UInt32(range.endIndex - range.startIndex))) + range.startIndex
	}
}

public extension CGSize {
	static func screenSize() -> CGSize {
		return UIScreen.mainScreen().bounds.size
	}
}

public extension NSDate {
	func toString() -> String{
		let dateFormatter: NSDateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MM-dd-yyyy"
		
		return dateFormatter.stringFromDate(self)
	}
	func weekDay() -> String{
		let formatter = NSDateFormatter()
		formatter.dateFormat = "E"
		
		return formatter.stringFromDate(self)
	}
	func toLocalTime() -> NSDate {
		let tz = NSTimeZone.defaultTimeZone()
		let seconds = tz.secondsFromGMTForDate(self)
		let date : NSDate = self.dateByAddingTimeInterval(NSTimeInterval(seconds))
		return date
	}
	func extract() -> NSDateComponents {
		let cal = NSCalendar.currentCalendar()
		let comp = cal.components([.Calendar, .Day, .Era, .Hour, .Minute, .Month, .Nanosecond, .Year], fromDate: self)
		return comp
	}
}

public extension UIColor {
	class func softPink() -> UIColor{
		return UIColor(red:206/255.0, green:67/255.0, blue:130/255.0, alpha:1)
	}
	class func softYelow() -> UIColor{
		return UIColor(red: 253/255, green: 197/255, blue: 0, alpha: 1)
	}
	class func softOrange() -> UIColor{
		return UIColor(red: 1, green: 167/255, blue: 28/255, alpha: 1)
	}
	class func softGreen() -> UIColor{
		return UIColor(red: 158/255, green: 211/255, blue: 15/255, alpha: 1)
	}
	class func softBlue() -> UIColor{
		return UIColor(red: 100/255, green: 194/255, blue: 227/255, alpha: 1)
	}
	class func softPurple() -> UIColor{
		return UIColor(red: 124/255, green: 118/255, blue: 247/255, alpha: 1)
	}
	var components:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		var r:CGFloat = 0
		var g:CGFloat = 0
		var b:CGFloat = 0
		var a:CGFloat = 0
		getRed(&r, green: &g, blue: &b, alpha: &a)
		return (r,g,b,a)
	}
	func soften(coeff : CGFloat) -> UIColor{
		let comp = self.components
		return UIColor(red: comp.red * coeff, green: comp.green * coeff, blue: comp.blue * coeff, alpha: comp.alpha)
	}
	
	
	class func themeColor() -> UIColor{
		switch Yuno.theme{
		case .KonaChan:
			return UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
		case .LightBlue:
			return UIColor(hexString: "#EEEEEE")
		case .Orange:
			return UIColor(hexString: "#EEEEEE")
		case .Dark:
			return UIColor(hexString: "#262626")
		}
	}
	class func konaColor() -> UIColor{
		switch Yuno.theme{
		case .KonaChan:
			return UIColor(red: 253/255, green: 168/255, blue: 142/255, alpha: 1)
		case .LightBlue:
			return UIColor(hexString: "#2196F3")
		case .Orange:
			return UIColor(hexString: "#FF8F00")
		case .Dark:
			return UIColor(hexString: "#84FFFF")
		}
	}
	class func lighterThemeColor() -> UIColor {
		switch Yuno.theme{
		case .KonaChan:
			return UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
		case .LightBlue:
			return UIColor.whiteColor()
		case .Orange:
			return UIColor.whiteColor()
		case .Dark:
			return UIColor(hexString: "#333333")
		}
	}
	class func searchVCLabelColor() -> UIColor {
		switch Yuno.theme{
		case .KonaChan:
			return UIColor.whiteColor()
		case .LightBlue:
			return UIColor.grayColor()
		case .Orange:
			return UIColor.grayColor()
		case .Dark:
			return UIColor.whiteColor()
		}
	}
	class func placeHolderImageColor() -> UIColor {
		switch Yuno.theme{
		case .KonaChan:
			return UIColor.darkGrayColor()
		case .LightBlue:
			return UIColor.lightGrayColor()
		case .Orange:
			return UIColor.lightGrayColor()
		case .Dark:
			return UIColor.darkGrayColor()
		}
	}
	
	convenience init(hexString: String) {
		let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
		var int = UInt32()
		NSScanner(string: hex).scanHexInt(&int)
		let a, r, g, b: UInt32
		switch hex.characters.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}

extension UIStatusBarStyle {
	static func styleAccordingToTheme() -> UIStatusBarStyle {
		switch Yuno.theme{
		case .KonaChan:
			return .LightContent
		case .LightBlue:
			return .Default
		case .Orange:
			return .Default
		case .Dark:
			return .LightContent
		}
	}
}

extension UIScrollViewIndicatorStyle {
	static func styleAccordingToTheme() -> UIScrollViewIndicatorStyle {
		switch Yuno.theme{
		case .KonaChan:
			return .White
		case .LightBlue:
			return .Black
		case .Orange:
			return .Black
		case .Dark:
			return .White
		}
	}
}

public extension UIAlertController {
	class func alertWithOKButton(title : String?, message : String?) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: nil))
		return alert
	}
	
	class func alert(title : String?, message : String?, actions : [UIAlertAction]?) -> UIAlertController{
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		
		for action in actions! {
			alert.addAction(action)
		}
		
		return alert
	}
}

public extension UIDevice {
	
	var modelName: String {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8 where value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		
		switch identifier {
			case "iPod5,1":                                 return "iPod Touch 5"
			case "iPod7,1":                                 return "iPod Touch 6"
			case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
			case "iPhone4,1":                               return "iPhone 4s"
			case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
			case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
			case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
			case "iPhone7,2":                               return "iPhone 6"
			case "iPhone7,1":                               return "iPhone 6 Plus"
			case "iPhone8,1":                               return "iPhone 6s"
			case "iPhone8,2":                               return "iPhone 6s Plus"
			case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
			case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
			case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
			case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
			case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
			case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
			case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
			case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
			case "iPad6,7", "iPad6,8":                      return "iPad Pro"
			case "AppleTV5,3":                              return "Apple TV"
			default:                                        return identifier
		}
	}
}

public enum Theme {
	case KonaChan
	case LightBlue
	case Orange
	case Dark
}

public class Yuno{
	
	var imageCoreData = [NSManagedObject]()
	var favoriteCoreData = [NSManagedObject]()
	
	static let theme = Theme.Dark
	static let viewCountBeforeFeedback = 10
	
	static var r18 : Bool {
		return NSUserDefaults.standardUserDefaults().boolForKey("r18")
	}
	
	func baseUrl() -> String{

		let r18 = NSUserDefaults.standardUserDefaults().boolForKey("r18")
		
		if r18 {
			return "http://konachan.com"
		}
		else{
			return "http://konachan.net"
		}
	}
	
	public func saveImageWithKey(entity : String, image : UIImage, key : String){
		let data = NSKeyedArchiver.archivedDataWithRootObject(image)
		let managedContext = entity == "FavoritedImage" ? (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let entity = NSEntityDescription.entityForName(entity,
			inManagedObjectContext: managedContext)
		let options = NSManagedObject(entity: entity!,
			insertIntoManagedObjectContext:managedContext)
		
		options.setValue(data, forKey: "image")
		options.setValue(key, forKey: "key")
		
		self.imageCoreData.append(options)
		do {
			try managedContext.save()
		}
		catch{
			print (error)
		}
	}
	
	public func fetchImageWithKey(entity : String, key : String) -> UIImage?{
		let managedContext = entity == "FavoritedImage" ? (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: entity)
		fetchRequest.predicate = NSPredicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		if fetchedResults.count == 1 {
			return NSKeyedUnarchiver.unarchiveObjectWithData(fetchedResults[0].valueForKey("image") as! NSData) as? UIImage
		}
		return nil
	}
	
	public func checkFullsSizeWithKey(key : String) -> Bool {
		let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: "FavoritedImage")
		fetchRequest.predicate = NSPredicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		
		if fetchedResults.count == 1 {
			return fetchedResults[0].valueForKey("isFullSize") as! Bool
		}
		
		return false
	}
	
	public func deleteRecordForKey(entity : String, key : String) {
		let managedContext = entity == "FavoritedImage" ? (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: entity)
		fetchRequest.predicate = NSPredicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		if fetchedResults.count == 1 {
			managedContext.deleteObject(fetchedResults[0])
			do {
				try managedContext.save()
			}
			catch{
				print (error)
			}
		}
	}
	
	public func saveFavoriteImageIfNecessary(key : String, image : UIImage){
		let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: "FavoritedImage")
		fetchRequest.predicate = NSPredicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		
		if fetchedResults.count > 0 {
			self.deleteRecordForKey("FavoritedImage", key: key)

			let data = NSKeyedArchiver.archivedDataWithRootObject(image)
			let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
			let entity = NSEntityDescription.entityForName("FavoritedImage",
				inManagedObjectContext: managedContext)
			let options = NSManagedObject(entity: entity!,
				insertIntoManagedObjectContext:managedContext)
			
			options.setValue(data, forKey: "image")
			options.setValue(key, forKey: "key")
			options.setValue(true, forKey: "isFullSize")
			
			self.imageCoreData.append(options)
			do {
				try managedContext.save()
			}
			catch{
				print (error)
			}
		}
	}
	
	public func favoriteList() -> [String]{
		var returnAry : [String] = []
		
		let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: "FavoritedImage")
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		
		for result in fetchedResults{
			returnAry.append(result.valueForKey("key") as! String)
		}
		
		return returnAry
	}
	
	public func deleteEntity(entity : String){
		let managedContext = entity == "FavoritedImage" ? (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: entity)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}

		if fetchedResults.count > 0 {
			for result in fetchedResults{
				managedContext.deleteObject(result)
			}
		}
		
		do {
			try managedContext.save()
		}
		catch{
			print (error)
		}
	}
	
	public func backgroundThread(background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			if(background != nil){ background!(); }
			
			dispatch_async(dispatch_get_main_queue()){
				if(completion != nil){ completion!(); }
			}
		}
	}
}