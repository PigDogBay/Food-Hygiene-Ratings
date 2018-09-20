//
//  MBPlace.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation
import GooglePlaces

enum FetchStatus {
    case uninitialized, fetching, ready, error
}
protocol IPlaceImage {
    var attribution : String {get}
    var observableStatus : ObservableProperty<FetchStatus> {get}
    var image : UIImage? {get}
    var index : Int {get}
    func fetchBitmap()
}

protocol IPlaceFetcher {
    var observableStatus : ObservableProperty<FetchStatus> {get}
    var mbPlace : MBPlace? {get}
    func fetch(establishment : Establishment)
}

struct MBPlace {
    let id : String
    let telephone : String
    let web : String
    let images : [IPlaceImage]
}

class GooglePlaceFetcher : IPlaceFetcher {
    private(set) var observableStatus: ObservableProperty<FetchStatus> = ObservableProperty<FetchStatus>(.uninitialized)
    private(set) var mbPlace: MBPlace? = nil
    
    func fetch(establishment: Establishment) {
        observableStatus.value = .fetching
        let bounds = createBounds(establishment: establishment)
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        GMSPlacesClient.shared().autocompleteQuery(establishment.business.name, bounds: bounds, boundsMode: .restrict, filter: filter) { results,error in
            if let error = error {
                print("Autocomplete error \(error)")
            }
            if let results = results {
                if results.count>0 {
                    if let placeId = results[0].placeID{
                        self.fetchPlace(placeId: placeId)
                        return
                    }
                }
            }
            self.observableStatus.value = .error
        }
    }
    private func fetchPlace(placeId : String){
        GMSPlacesClient.shared().lookUpPlaceID(placeId) { result,error in
            if let error = error {
                print("Look up place by ID error \(error)")
            }
            if let place = result {
                self.fetchImageMetadata(place: place)
                return
            }
            self.observableStatus.value = .error
        }
    }
    private func fetchImageMetadata(place : GMSPlace){
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: place.placeID){ results,error in
            if let error = error {
                print("Look up place photos error \(error)")
            }
            if let results = results {
                print("OK found \(results.results.count) pictures")
                self.observableStatus.value = .ready
                return
            }
            self.observableStatus.value = .error
        }

    }
    
    private func createPlace(place : GMSPlace, placeImages : [IPlaceImage]) -> MBPlace {
        //convert the phone number from international format to UK
        let phone = place.phoneNumber?.replacingOccurrences(of: "+44", with: "0") ?? ""
        let web = place.website?.absoluteString ?? ""
        return MBPlace(id: place.placeID, telephone: phone, web: web, images: placeImages)
    }
    
    /*
        Returns bounds of about 0.25 mile radius about the establishment
    */
    private func createBounds(establishment : Establishment) -> GMSCoordinateBounds{
        let lat = establishment.address.coordinate.latitude
        let long = establishment.address.coordinate.longitude
        let delta = 0.005
        let northeast = CLLocationCoordinate2D(latitude: lat+delta, longitude: long+delta)
        let southwest = CLLocationCoordinate2D(latitude: lat-delta, longitude: long-delta)
        return GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
    }
}
