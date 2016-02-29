# AWActionSheet
A customizable replacement of UIActionSheet, written in Swift

###Demo GIF

![](https://github.com/hkalexling/AWActionSheet/blob/master/Media/AWActionSheet.gif)

The demo is from my app [KoneBot](https://github.com/hkalexling/KonaBot-iOS), feel free to check it out as well :)

###Usage

- Drag and drop files in the source folder into your Xcode project
- Do something like this

```swift
let awActionSheet = AWActionSheet(parentView: self.view)
let firstAction = AWActionSheetAction(title: "First Action", handler: {
			print ("First Action")
		})
let secondAction = AWActionSheetAction(title: "Second Action", handler: {
			print ("Second Action")
		})
awActionSheet.addAction(firstAction)
awActionSheet.addAction(secondAction)

//Optional: you can customise the action sheet here

self.view.addSubview(awActionSheet)
awActionSheet.showActionSheet()
```

A list of properties you can customise and their default values:

```swift
var buttonColor = UIColor.grayColor()
var cancelButtonColor = UIColor.darkGrayColor()
var textColor = UIColor.whiteColor()
	
var buttonWidth : CGFloat = 300
var buttonHeight : CGFloat = 40
var buttonCornerRadius : CGFloat = 10
	
var gapBetweetnCancelButtonAndOtherButtons : CGFloat = 8
var gapBetweetButtons : CGFloat = 2
	
var buttonFont : UIFont = UIFont.systemFontOfSize(16)
var cancelButtonFont : UIFont = UIFont.boldSystemFontOfSize(16)
	
var animationDuraton : NSTimeInterval = 0.5
var damping : CGFloat = 0.4
```

For more detail usage, see how I use it in real project: [link](https://github.com/hkalexling/KonaBot-iOS/blob/master/KonaBot/DetailViewController.swift#L235)
