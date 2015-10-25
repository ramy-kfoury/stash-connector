//
//  ProjectsViewController.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Cocoa

class ProjectsViewController: NSViewController {
    
    static func instance() -> ProjectsViewController {
        return ProjectsViewController(nibName: "ProjectsViewController", bundle: nil)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "getData", userInfo: nil, repeats: true).fire()
    }
    
    func getData() {
        DataProvider().run()
    }
}


