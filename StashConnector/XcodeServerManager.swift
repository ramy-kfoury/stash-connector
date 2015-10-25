//
//  XcodeServerManager.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 25/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Foundation

class XcodeServerManager {
    
    private var newBranches: Set<String>
    private var deletedBranches: Set<String>
    
    required init(newBranches: Set<String>, deletedBranches: Set<String>) {
        self.newBranches = newBranches
        self.deletedBranches = deletedBranches
    }
    
    func updateBots() {
        newBranches.forEach { (branch) -> () in
            createBot(forBranch: branch)
        }
        deletedBranches.forEach { (branch) -> () in
            deleteBot(forBranch: branch)
        }
    }

    private func createBot(forBranch branch: String) {
        print("creating bot for branch \(branch)")
    }
    
    private func deleteBot(forBranch branch: String) {
        print("deleting bot for branch \(branch)")
    }
    
}