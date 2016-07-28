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
		
		self.`switch`.onTintColor = UIColor.konaColor()
		self.`switch`.thumbTintColor = UIColor.themeColor()
		self.`switch`.backgroundColor = UIColor.placeHolderImageColor()
		self.`switch`.layer.cornerRadius = 16
		self.`switch`.tintColor = UIColor.konaColor()
		self.`switch`.setOn(UserDefaults.standard().bool(forKey: "optimize"), animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
