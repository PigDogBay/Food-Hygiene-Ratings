//
//  IDataProvider.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 10/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

protocol IDataProvider {
    var model : MainModel! {get set}
    func findLocalEstablishments()
    func fetchEstablishments(query : Query)
}
