//
//  XcodeServerManager.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 25/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Foundation
import XcodeServerSDK

class XcodeServerManager {
    
    private var newBranches: Set<String>
    private var deletedBranches: Set<String>
    
    required init(newBranches: Set<String> = Set<String>(), deletedBranches: Set<String> = Set<String>()) {
        self.newBranches = newBranches
        self.deletedBranches = deletedBranches
    }
    
    func connectToServer() {
        do {
            let config = try XcodeServerConfig(host: "https://ramyserver.local", user: "Ramy Kfoury", password: "ramy10+08_89")
            let server = XcodeServerFactory.server(config)
            server.getBots { bots, error in
                guard error == nil else {
                    print("Oh no! \(error!.description)")
                    return
                }
                
                // go crazy with bots
                if let firstBot = bots?.first {
                    
                }
            }
        } catch ConfigurationErrors.NoHostProvided {
            fatalError("You haven't provided any host")
        } catch ConfigurationErrors.InvalidHostProvided(let host){
            fatalError("You've provided invalid host: \(host)")
        } catch ConfigurationErrors.InvalidSchemeProvided(let scheme) {
            fatalError("You've provided invalid scheme: \(scheme)")
        } catch {
            fatalError("Error, not related to XcodeServerConfig; \(error)")
        }
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