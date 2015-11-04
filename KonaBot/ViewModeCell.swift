//
//  ViewModeCell.swift
//  KonaBot
//
//  Created by Alex Ling on 4/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class ViewModeCell: UITableViewCell {

	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var label: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		if NSUserDefaults.standardUserDefaults().objectForKey("viewMode") != nil{
			segmentControl.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("viewMode")
		}
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
