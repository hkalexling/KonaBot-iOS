//
//  TextArrowCell.swift
//  KonaBot
//
//  Created by Alex Ling on 3/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class TextArrowCell: UITableViewCell {

	@IBOutlet weak var label: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		let accessory = KonaDisclosureIndicatorView(color: UIColor.konaColor())
		self.accessoryView = accessory
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
