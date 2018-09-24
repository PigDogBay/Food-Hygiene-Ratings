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
    
    @IBAction func attrClicked(_ sender: UIButton) {
        print("Clicked")
    }
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
        attribution.gestureRecognizers?.removeAll()
    }
    
    func show(placeImage : IPlaceImage){
        picture.image = placeImage.image
        //fill the UIImage and maintain aspect by clipping the image if necessary
        picture.contentMode = .scaleAspectFill
        attribution.attributedText = placeImage.attribution ?? PlaceImageCell.emptyAttribution
        activityIndicator.stopAnimating()
    }
    func showBroken(){
        picture.image = UIImage(named: "iconNoCamera")
        picture.contentMode = .center
        activityIndicator.stopAnimating()
    }
}
