//
//  Project.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Foundation

struct StashProject {
    
    let key: String
    let id: Int
    let name: String
    let description: String
    let link: String
    
    init(withJSON json: JSON) {
        self.key = json["key"].string ?? ""
        self.id = json["id"].int ?? NSNotFound
        self.name = json["name"].string ?? ""
        self.description = json["description"].string ?? ""
        self.link = json["links"]["self"][0]["href"].string ?? ""
    }
}