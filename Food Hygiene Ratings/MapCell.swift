//
//  MapCell.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 21/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import UIKit

class MapCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showMap(mapImage : UIImage){
        picture.image = mapImage
        activityIndicator.stopAnimating()
    }
}
