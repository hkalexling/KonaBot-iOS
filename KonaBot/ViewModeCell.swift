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
		
		if UserDefaults.standard().object(forKey: "viewMode") != nil{
			segmentControl.selectedSegmentIndex = UserDefaults.standard().integer(forKey: "viewMode")
		}
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
