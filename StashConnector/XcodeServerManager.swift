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
    
    private var server: XcodeServer!
    private var bots: [Bot] = []
    private var newBranches: Set<String> = []
    private var deletedBranches: Set<String> = []
    
    
    func connectToServer(completion: () -> Void) {
        do {
            let config = try XcodeServerConfig(host: "https://rock-hudson.local", user: "hudson", password: "myhud$0n")
            self.server = XcodeServerFactory.server(config)
            
            self.server.getUserCanCreateBots({ canCreateBots, error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                print("user can create bots")
            })
            completion()
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
    
    func getBots() {
        self.server.getBots { bots, error in
            guard let bots = bots else {
                print("Oh no! \(error!.description)")
                return
            }
            
            self.bots = bots
        }
    }
    
    func set(newBranches: Set<String> = Set<String>(), deletedBranches: Set<String> = Set<String>()) {
        self.newBranches = newBranches
        self.deletedBranches = deletedBranches
        self.updateBots()
    }
    
    private func updateBots() {
        newBranches.forEach { (branch) -> () in
            createBot(forBranch: branch)
        }
        deletedBranches.forEach { (branch) -> () in
            deleteBot(forBranch: branch)
        }
    }

    private func createBot(forBranch branch: String) {
        // TODO get master bot
        // duplicate it
        // create bot for new branch
        print("creating bot for branch \(branch)")
    }
    
    private func deleteBot(forBranch branch: String) {
        if let bot = self.findBot(forBranch: branch) {
            print("found bot \(bot)")
            
            self.server.deleteBot(bot.id, revision: bot.rev, completion: { success, error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                print("deleted bot for branch \(branch)")
            })
        }
    }
    
    private func findBot(forBranch branch: String) -> Bot? {
        return bots.filter { bot in
            branch.containsString(bot.configuration.sourceControlBlueprint.branch)
        }.first
    }
    
}