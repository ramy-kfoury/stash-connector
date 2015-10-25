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

struct StashRepository {
    let id: Int
    let slug: String
    let projectid: Int
    
    init(withJSON json: JSON) {
        self.slug = json["slug"].string ?? ""
        self.id = json["id"].int ?? NSNotFound
        self.projectid = json["project"]["id"].int ?? NSNotFound
    }
}

struct StashBranch {
    let id: String
    let latestCommit: String
    let latestChangeset: String
    let displayId: String
    
    init(withJSON json: JSON) {
        self.id = json["id"].string ?? ""
        self.latestCommit = json["latestCommit"].string ?? ""
        self.latestChangeset = json["latestChangeset"].string ?? ""
        self.displayId = json["displayId"].string ?? ""
    }
}