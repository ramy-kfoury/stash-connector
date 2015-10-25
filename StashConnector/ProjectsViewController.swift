//
//  ProjectsViewController.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Cocoa

class ProjectsViewController: NSViewController {

    private var projects = [StashProject]()
    
    static func instance() -> ProjectsViewController {
        return ProjectsViewController(nibName: "ProjectsViewController", bundle: nil)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StashNetworking.request(withEndpoint: .Projects) { (json, error) -> Void in
            guard let json = json else {
                print(error)
                return
            }
            
            if let values = json["values"].array {
                self.projects = values.map { value in
                    StashProject(withJSON: value)
                }
                self.listProjects()
            }
        }
    }
    
    private func listProjects() {
        print(projects);
    }
    
}
