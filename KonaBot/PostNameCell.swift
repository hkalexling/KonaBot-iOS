//
//  PostNameCell.swift
//  KonaBot
//
//  Created by Alex Ling on 14/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class PostNameCell: UITableViewCell {

	@IBOutlet weak var label: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.label.textColor = UIColor.konaColor()
		self.label.numberOfLines = 0
		self.label.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
