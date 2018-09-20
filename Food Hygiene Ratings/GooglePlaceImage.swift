//
//  GooglePlaceImage.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation
import GooglePlaces

class GooglePlaceImage : IPlaceImage {
    private(set) var attribution: NSAttributedString? = nil
    private(set) var observableStatus: ObservableProperty<FetchStatus> = ObservableProperty<FetchStatus>(.uninitialized)
    private(set) var image: UIImage? = nil
    var index: Int = 0

    private let metadata : GMSPlacePhotoMetadata

    init(metadata : GMSPlacePhotoMetadata){
        self.metadata = metadata
        self.attribution = metadata.attributions
    }
    
    func fetchBitmap() {
        observableStatus.value = .fetching
        GMSPlacesClient.shared().loadPlacePhoto(metadata){ result, _ in
            if let result = result {
                self.image = result
                self.observableStatus.value = .ready
                return
            }
            self.observableStatus.value = .error
        }
    }
}
