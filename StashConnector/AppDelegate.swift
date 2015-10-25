//
//  AppDelegate.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var projectsViewController: ProjectsViewController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        projectsViewController = ProjectsViewController.instance()
        
        window.contentView!.addSubview(projectsViewController.view)
        projectsViewController.view.frame = window.contentView!.bounds
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

