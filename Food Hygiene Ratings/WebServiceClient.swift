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
        request.timeoutInterval = TimeInterval(Settings.connectionTimeOut)
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            
            if let jsonData = data {
                if Logging.enabled {
                    Logging.append(msg: "Web Data:")
                    jsonData.forEach { byte in
                        Logging.log.append(String(format: "%2X ",byte))
                    }
                    Logging.append(msg: "\nWeb fetch ok, JSON")
                }
                completion(FoodHygieneAPI.establishments(fromJSON: jsonData))
            } else if let requestError = error {
                Logging.append(msg: "Web fetch requestError, \(requestError)")
                completion(.failure(requestError))
            } else {
                Logging.append(msg: "Web fetch failed")
                completion(.failure(FoodHygieneError.webError))
            }
        }
        task.resume()
    }
}
