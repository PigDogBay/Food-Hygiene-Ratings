//
//  WebServiceClient.swift
//  FSAChecker
//
//  Created by Mark Bailey on 07/02/2017.
//  Copyright © 2017 Pig Dog Bay. All rights reserved.
//

import Foundation

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
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = "GET"
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            
            if let jsonData = data {
                let s = String(data: jsonData, encoding: .utf8)!
                print(s)
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
