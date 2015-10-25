//
//  Project.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Foundation

class StashProject {
    
    let key: String
    let id: Int
    let name: String
    let description: String
    let link: String
    var repositories: [StashRepository]
    
    init(withJSON json: JSON) {
        self.key = json["key"].string ?? ""
        self.id = json["id"].int ?? NSNotFound
        self.name = json["name"].string ?? ""
        self.description = json["description"].string ?? ""
        self.link = json["links"]["self"][0]["href"].string ?? ""
        self.repositories = [StashRepository]()
    }
    
    
    func toJSON() -> [String: AnyObject] {
        return [
            "name": name,
            "repositories": repositories.map({ $0.toJSON() })
        ]
    }
    
}

class StashRepository {
    let id: Int
    let slug: String
    let projectid: Int
    var branches: [StashBranch]
    
    init(withJSON json: JSON) {
        self.slug = json["slug"].string ?? ""
        self.id = json["id"].int ?? NSNotFound
        self.projectid = json["project"]["id"].int ?? NSNotFound
        self.branches = [StashBranch]()
    }
    
    func toJSON() -> [String: AnyObject] {
        return [
            "slug": slug,
            "branches": branches.map({ $0.toJSON() })
        ]
    }
}

class StashBranch {
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
    
    func toJSON() -> [String: AnyObject] {
        return [
            "id": id
        ]
    }
}