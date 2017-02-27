//
//  FoodHygieneAPI.swift
//  FSAChecker
//
//  Created by Mark Bailey on 07/02/2017.
//  Copyright © 2017 Pig Dog Bay. All rights reserved.
//

import Foundation

enum FoodHygieneCategory : String{
    case establishments = "establishments/"
}
enum FoodHygieneError : Error
{
    case invalidJSONData
    case webError
}
extension FoodHygieneError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidJSONData:
            return NSLocalizedString("Invalid data format", comment: "invalid JSON")
        default:
            return NSLocalizedString("Unexpected error, check your internet connection", comment: "webError")
        }
    }
}


struct FoodHygieneAPI {
    
    private static let baseUrlString = "http://api.ratings.food.gov.uk/"

    //"RatingDate":"2015-06-25T00:00:00"
    private static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    static func createBusinessUrl(fhrsId : Int) -> URL{
        let urlString = "http://ratings.food.gov.uk/business/en-GB/\(fhrsId)"
        return URL(string: urlString)!
    }
    
    private static func createUrl(category : FoodHygieneCategory, parameters: [String:String?]? ) -> URL {
        var components = URLComponents(string: baseUrlString+category.rawValue)!
        var queryItems = [URLQueryItem]()
        
        if let additionalParameters = parameters {
            for (key, value) in additionalParameters {
                if let actualValue = value {
                    let item = URLQueryItem(name: key, value: actualValue)
                    queryItems.append(item)
                }
            }
        }
        components.queryItems = queryItems
        return components.url!
    }
    
    static func createEstablishmentsUrl(query : Query) -> URL {
        var latitudeString : String?
        if let latitude = query.latitude{
            latitudeString = String(latitude)
        }
        var longitudeString : String?
        if let longitude = query.longitude{
            longitudeString = String(longitude)
        }
        var radiusString : String?
        if let radius = query.radiusInMiles {
            radiusString = String(radius)
        }
        let params = [
            "latitude" : latitudeString,
            "longitude" : longitudeString,
            "maxDistanceLimit" : radiusString,
            "name" : query.businessName,
            "address" : query.placeName]
        return createUrl(category: .establishments, parameters: params)
    }
    
    static func establishments(fromJSON data: Data) -> EstablishmentsResult{
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let jsonDictionary = jsonObject as? [AnyHashable : Any],
                let establishmentsArray = jsonDictionary["establishments"] as? [[String:Any]] else {
                    return .failure(FoodHygieneError.invalidJSONData)
            }
            
            var establishments = [Establishment]()
            for estJSON in establishmentsArray {
                if let est = establishment(fromJSON: estJSON){
                    establishments.append(est)
                }
            }
            return .success(establishments)
            
        } catch let Error {	
            return .failure(Error)
        }
    }
    
    private static func establishment(fromJSON json: [String : Any]) -> Establishment? {
        guard
            let name = json["BusinessName"] as? String,
            let businessType = json["BusinessType"] as? String,
            let fhrsId = json["FHRSID"] as? Int,
            let businessTypeId = json["BusinessTypeID"] as? Int,
            let ratingString = json["RatingValue"] as? String,
            let ratingDateString = json["RatingDate"] as? String,
            let ratingDate = dateFormatter.date(from: ratingDateString),
            let newRatingPending = json["NewRatingPending"] as? Bool,
            let ratingsKey = json["RatingKey"] as? String,
            let scoresJson = json["scores"] as? [String : Any],
            let distance = json["Distance"] as? Double,
            let addressLine1 = json["AddressLine1"] as? String,
            let addressLine2 = json["AddressLine2"] as? String,
            let addressLine3 = json["AddressLine3"] as? String,
            let addressLine4 = json["AddressLine4"] as? String,
            let postcode = json["PostCode"] as? String,
            let authorityName = json["LocalAuthorityName"] as? String,
            let authorityWeb = json["LocalAuthorityWebSite"] as? String,
            let authorityEmail = json["LocalAuthorityEmailAddress"] as? String,
            let authorityCode = json["LocalAuthorityCode"] as? String,
            let geocode = json["geocode"] as? [String : String],
            let longitudeString = geocode["longitude"],
            let latitudeString = geocode["latitude"],
            let longitude = Double(longitudeString),
            let latitude = Double(latitudeString)
            else {
                return nil
            }

        let coordinate = Coordinate(longitude: longitude, latitude: latitude)
        let address = Address(line1: addressLine1, line2: addressLine2, line3: addressLine3, line4: addressLine4, postcode: postcode, coordinate: coordinate)
        let ratingValue = parseRating(fromString: ratingString)
        let hygieneScore = scoresJson["Hygiene"] as? Int ?? 0
        let structuralScore = scoresJson["Structural"] as? Int ?? 0
        let confidenceScore = scoresJson["ConfidenceInManagement"] as? Int ?? 0
        let scores = Scores(hygiene: hygieneScore, structural: structuralScore, confidenceInManagement: confidenceScore)
        let rating = Rating(value: ratingValue, ratingString: ratingString, awardedDate: ratingDate, newRatingPending: newRatingPending, scores: scores, ratingsKey : ratingsKey)
        
        let business = Business(name: name, type: businessType, typeId: businessTypeId, fhrsId: fhrsId)
        
        let localAuthority = LocalAuthority(email: authorityEmail, web: authorityWeb, name: authorityName, code: authorityCode)
        
        return Establishment(business: business, rating: rating, distance: distance, address: address, localAuthority: localAuthority)
    }
    
    private static func parseRating(fromString ratingString: String) -> RatingValue {
        switch ratingString {
        case "0":
            return .rating(0)
        case "1":
            return .rating(1)
        case "2":
            return .rating(2)
        case "3":
            return .rating(3)
        case "4":
            return .rating(4)
        case "5":
            return .rating(5)
        case "Exempt":
            return .exempt
        case "AwaitingInspection":
            return .awaitingInspection
        case "Awaiting Inspection":
            return .awaitingInspection
        case "Pass":
            return .pass
        case "Pass and Eat Safe":
            return .passEatSafe
        case "Improvement Required":
            return .improvementRequired
        case "ImprovementRequired":
            return .improvementRequired
        case "AwaitingPublication":
            return .awaitingPublication
        case "Awaiting Publication":
            return .awaitingPublication
        default:
            return .other
        }
    }
    
    
    
}

