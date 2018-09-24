//
//  PlaceImageCellTableViewCell.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import UIKit

class PlaceImageCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var attribution: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private static let emptyAttribution = NSAttributedString(string:"")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reset(){
        picture.image = nil
        activityIndicator.startAnimating()
        attribution.attributedText = PlaceImageCell.emptyAttribution
    }
    
    func show(photo : UIImage){
        picture.image = photo
        //fill the UIImage and maintain aspect by clipping the image if necessary
        picture.contentMode = .scaleAspectFill
        activityIndicator.stopAnimating()
    }
    func showBroken(){
        picture.image = UIImage(named: "iconNoCamera")
        picture.contentMode = .center
        activityIndicator.stopAnimating()
    }
}
