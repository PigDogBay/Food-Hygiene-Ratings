//
//  LocalAuthority.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 01/03/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

/*
 "LocalAuthorityId":197,
 "LocalAuthorityIdCode":"760",
 "Name":"Aberdeen City",
 "EstablishmentCount":1757,
 "SchemeType":2,
 */


struct LocalAuthority {
    let email : String
    let web : String
    let name : String
    let code : String
    
    var searchCode : Int?
    var establishmentCount : Int?
    var schemeType : Int?
    
    init(email : String, web : String, name : String, code : String){
        self.email = email
        self.web = web
        self.name = name
        self.code = code
    }
    
    //Data from basic look-up
    init(name : String, searchCode : Int, establishmentCount : Int, schemeType : Int, code : String){
        self.email = ""
        self.web = ""
        self.name = name
        self.code = code
        self.searchCode = searchCode
        self.establishmentCount = establishmentCount
        self.schemeType = schemeType
    }

}

