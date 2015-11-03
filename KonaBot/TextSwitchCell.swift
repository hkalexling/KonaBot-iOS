//
//  TextSwitchCell.swift
//  KonaBot
//
//  Created by Alex Ling on 3/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class TextSwitchCell: UITableViewCell {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var `switch`: UISwitch!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.`switch`.setOn(NSUserDefaults.standardUserDefaults().boolForKey("optimize"), animated: false)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
