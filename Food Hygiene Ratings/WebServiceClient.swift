//
//  WebServiceClient.swift
//  FSAChecker
//
//  Created by Mark Bailey on 07/02/2017.
//  Copyright © 2017 Pig Dog Bay. All rights reserved.
//

import Foundation

enum LocalAuthorityResult {
    case success([LocalAuthority])
    case failure(Error)
}
enum EstablishmentsResult {
    case success([Establishment])
    case failure(Error)
}
class WebServiceClient {

    private let session : URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchEstablishments(url : URL, completion: @escaping (EstablishmentsResult)->Void){
        var request = URLRequest(url: url)
        request.addValue("2", forHTTPHeaderField: "x-api-version")
        request.addValue("en-GB", forHTTPHeaderField: "Accept-Language")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "accept")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "content-type")
        request.httpMethod = "GET"
        
        let timeInterval = Double(Settings.connectionTimeOut)
        request.timeoutInterval = timeInterval
        session.configuration.timeoutIntervalForRequest = timeInterval
        session.configuration.timeoutIntervalForResource = timeInterval
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            
            if let jsonData = data {
                completion(FoodHygieneAPI.establishments(fromJSON: jsonData))
            } else if let requestError = error {
                completion(.failure(requestError))
            } else {
                completion(.failure(FoodHygieneError.webError))
            }
        }
        task.resume()
    }
}
