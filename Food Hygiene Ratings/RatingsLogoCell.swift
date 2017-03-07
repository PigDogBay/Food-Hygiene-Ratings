//
//  RatingsLogoCell.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 15/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit

class RatingsLogoCell: UITableViewCell {

    
    @IBOutlet weak var ratingLogo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var subTitle2: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
