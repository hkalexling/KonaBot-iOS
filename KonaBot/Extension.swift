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
	static func networkAlertFromError (_ error : NSError) -> AWAlertView {
		return AWAlertView(title: "Network Error".localized, message: error.localizedDescription, height: 100, bgColor: UIColor(red: 239/255, green: 92/255, blue: 72/255, alpha: 1), textColor: UIColor.white())
	}
	static func alertFromTitleAndMessage (_ title : String, message : String) -> AWAlertView {
		return AWAlertView(title: title, message: message, height: 100, bgColor: UIColor(red: 48/255, green: 176/255, blue: 114/255, alpha: 1), textColor: UIColor.white())
	}
	static func redAlertFromTitleAndMessage (_ title : String, message : String) -> AWAlertView {
		return AWAlertView(title: title, message: message, height: 100, bgColor: UIColor(red: 239/255, green: 92/255, blue: 72/255, alpha: 1), textColor: UIColor.white())
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
		let statusBarSize = UIApplication.shared().statusBarFrame.size
		return Swift.min(statusBarSize.width, statusBarSize.height)
	}
}

extension UIButton {
	func block_setAction(_ block: ButtonActionBlock) {
		objc_setAssociatedObject(self, &ActionBlockKey, ActionBlockWrapper(block: block), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		addTarget(self, action: #selector(self.block_handleAction(_:)), for: .touchUpInside)
	}
	
	func block_handleAction(_ sender: UIButton) {
		let wrapper = objc_getAssociatedObject(self, &ActionBlockKey) as! ActionBlockWrapper
		wrapper.block()
	}
}

public extension UIImage {
	class func imageWithColor(_ color: UIColor) -> UIImage {
		let size = CGSize(width: 10, height: 10)
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	func coloredImage(_ color : UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		let context : CGContext? = UIGraphicsGetCurrentContext()
		context?.translate(x: 0, y: self.size.height)
		context?.scale(x: 1.0, y: -1.0)
		context?.setBlendMode(.normal)
		let rect : CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		context?.clipToMask(rect, mask: self.cgImage!)
		color.setFill()
		context?.fill(rect)
		let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	func resize(_ newWidth: CGFloat) -> UIImage {
		
		let scale = newWidth / self.size.width
		let newHeight = self.size.height * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image!
	}
}

public extension Int{
	static func randInRange(_ range: Range<Int>) -> Int {
		return  Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))) + range.lowerBound
	}
}

public extension CGSize {
	static func screenSize() -> CGSize {
		return UIScreen.main().bounds.size
	}
}

public extension Date {
	func toString() -> String{
		let dateFormatter: DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM-dd-yyyy"
		
		return dateFormatter.string(from: self)
	}
	func weekDay() -> String{
		let formatter = DateFormatter()
		formatter.dateFormat = "E"
		
		return formatter.string(from: self)
	}
	func toLocalTime() -> Date {
		let tz = TimeZone.default()
		let seconds = tz.secondsFromGMT(for: self)
		let date : Date = self.addingTimeInterval(TimeInterval(seconds))
		return date
	}
	func extract() -> DateComponents {
		let cal = Calendar.current()
		let comp = cal.components([.calendar, .day, .era, .hour, .minute, .month, .nanosecond, .year], from: self)
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
	func soften(_ coeff : CGFloat) -> UIColor{
		let comp = self.components
		return UIColor(red: comp.red * coeff, green: comp.green * coeff, blue: comp.blue * coeff, alpha: comp.alpha)
	}
	
	
	class func themeColor() -> UIColor{
		switch Yuno.theme{
		case .konaChan:
			return UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
		case .lightBlue:
			return UIColor(hexString: "#EEEEEE")
		case .orange:
			return UIColor(hexString: "#EEEEEE")
		case .dark:
			return UIColor(hexString: "#262626")
		}
	}
	class func konaColor() -> UIColor{
		switch Yuno.theme{
		case .konaChan:
			return UIColor(red: 253/255, green: 168/255, blue: 142/255, alpha: 1)
		case .lightBlue:
			return UIColor(hexString: "#2196F3")
		case .orange:
			return UIColor(hexString: "#FF8F00")
		case .dark:
			return UIColor(hexString: "#84FFFF")
		}
	}
	class func lighterThemeColor() -> UIColor {
		switch Yuno.theme{
		case .konaChan:
			return UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
		case .lightBlue:
			return UIColor.white()
		case .orange:
			return UIColor.white()
		case .dark:
			return UIColor(hexString: "#333333")
		}
	}
	class func searchVCLabelColor() -> UIColor {
		switch Yuno.theme{
		case .konaChan:
			return UIColor.white()
		case .lightBlue:
			return UIColor.gray()
		case .orange:
			return UIColor.gray()
		case .dark:
			return UIColor.white()
		}
	}
	class func placeHolderImageColor() -> UIColor {
		switch Yuno.theme{
		case .konaChan:
			return UIColor.darkGray()
		case .lightBlue:
			return UIColor.lightGray()
		case .orange:
			return UIColor.lightGray()
		case .dark:
			return UIColor.darkGray()
		}
	}
	
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
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
		case .konaChan:
			return .lightContent
		case .lightBlue:
			return .default
		case .orange:
			return .default
		case .dark:
			return .lightContent
		}
	}
}

extension UIScrollViewIndicatorStyle {
	static func styleAccordingToTheme() -> UIScrollViewIndicatorStyle {
		switch Yuno.theme{
		case .konaChan:
			return .white
		case .lightBlue:
			return .black
		case .orange:
			return .black
		case .dark:
			return .white
		}
	}
}

public extension UIAlertController {
	class func alertWithOKButton(_ title : String?, message : String?) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
		return alert
	}
	
	class func alert(_ title : String?, message : String?, actions : [UIAlertAction]?) -> UIAlertController{
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		
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
	case konaChan
	case lightBlue
	case orange
	case dark
}

public class Yuno{
	
	var imageCoreData = [NSManagedObject]()
	var favoriteCoreData = [NSManagedObject]()
	
	static let theme = Theme.konaChan
	static let viewCountBeforeFeedback = 10
	
	static var r18 : Bool {
		return UserDefaults.standard().bool(forKey: "r18")
	}
	
	func baseUrl() -> String{

		let r18 = UserDefaults.standard().bool(forKey: "r18")
		
		if r18 {
			return "http://konachan.com"
		}
		else{
			return "http://konachan.net"
		}
	}
	
	public func saveImageWithKey(_ entity : String, image : UIImage, key : String, skipUpload : Bool){
		let data = NSKeyedArchiver.archivedData(withRootObject: image)
		let managedContext = entity == "FavoritedImage" ? (UIApplication.shared().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let entityDescription = NSEntityDescription.entity(forEntityName: entity,
			in: managedContext)
		let options = NSManagedObject(entity: entityDescription!,
			insertInto:managedContext)
		
		options.setValue(data, forKey: "image")
		options.setValue(key, forKey: "key")
		
		self.imageCoreData.append(options)
		do {
			try managedContext.save()
		}
		catch{
			print (error)
		}
		
		//CK
		if entity == "FavoritedImage" && !skipUpload {
			CKManager().addFavoritedWithUrl(key)
		}
	}
	
	public func fetchImageWithKey(_ entity : String, key : String) -> UIImage?{
		let managedContext = entity == "FavoritedImage" ? (UIApplication.shared().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		fetchRequest.predicate = Predicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		if fetchedResults.count == 1 {
			return NSKeyedUnarchiver.unarchiveObject(with: fetchedResults[0].value(forKey: "image") as! Data) as? UIImage
		}
		return nil
	}
	
	public func checkFullsSizeWithKey(_ key : String) -> Bool {
		let managedContext = (UIApplication.shared().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritedImage")
		fetchRequest.predicate = Predicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		
		if fetchedResults.count == 1 {
			return fetchedResults[0].value(forKey: "isFullSize") as! Bool
		}
		
		return false
	}
	
	public func deleteRecordForKey(_ entity : String, key : String, skipUpload : Bool) {
		let managedContext = entity == "FavoritedImage" ? (UIApplication.shared().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		fetchRequest.predicate = Predicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		if fetchedResults.count == 1 {
			managedContext.delete(fetchedResults[0])
			do {
				try managedContext.save()
			}
			catch{
				print (error)
			}
		}
		
		//CK
		if entity == "FavoritedImage" && !skipUpload {
			CKManager().removeFavoritedWithUrl(key)
		}
	}
	
	public func saveFavoriteImageIfNecessary(_ key : String, image : UIImage){
		let managedContext = (UIApplication.shared().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritedImage")
		fetchRequest.predicate = Predicate(format: "key == %@", key)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		
		if fetchedResults.count > 0 {
			self.deleteRecordForKey("FavoritedImage", key: key, skipUpload: true)

			let data = NSKeyedArchiver.archivedData(withRootObject: image)
			let managedContext = (UIApplication.shared().delegate as! AppDelegate).managedObjectContext
			let entity = NSEntityDescription.entity(forEntityName: "FavoritedImage",
				in: managedContext)
			let options = NSManagedObject(entity: entity!,
				insertInto:managedContext)
			
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
		
		let managedContext = (UIApplication.shared().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoritedImage")
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}
		
		for result in fetchedResults{
			returnAry.append(result.value(forKey: "key") as! String)
		}
		
		return returnAry
	}
	
	public func deleteEntity(_ entity : String){
		let managedContext = entity == "FavoritedImage" ? (UIApplication.shared().delegate as! AppDelegate).managedObjectContext : CacheManager.sharedInstance.managedObjectContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
		
		var fetchedResults : [NSManagedObject] = []
		do {
			fetchedResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
		}
		catch{
			print (error)
		}

		if fetchedResults.count > 0 {
			for result in fetchedResults{
				managedContext.delete(result)
			}
		}
		
		do {
			try managedContext.save()
		}
		catch{
			print (error)
		}
	}
	
	public func backgroundThread(_ background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
		DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async {
			if(background != nil){ background!(); }
			
			DispatchQueue.main.async{
				if(completion != nil){ completion!(); }
			}
		}
	}
	
	func actionSheetSetStyle (_ awActionSheet : AWActionSheet){
		awActionSheet.animationDuraton = 0.8
		awActionSheet.cancelButtonColor = UIColor.themeColor()
		let componets = UIColor.themeColor().components
		awActionSheet.buttonColor = UIColor(red: componets.red, green: componets.green, blue: componets.blue, alpha: 0.8)
		awActionSheet.textColor = UIColor.konaColor()
		
		//iPad
		if UIScreen.main().bounds.width > 415 {
			awActionSheet.buttonWidth = 400
			awActionSheet.buttonHeight = 60
			awActionSheet.gapBetweetnCancelButtonAndOtherButtons = 15
			awActionSheet.buttonFont = UIFont.systemFont(ofSize: 20)
			awActionSheet.cancelButtonFont = UIFont.boldSystemFont(ofSize: 20)
		}
	}
}
