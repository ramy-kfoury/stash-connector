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
    private var masterBot: Bot!
    private var newBranches: Set<String> = []
    private var deletedBranches: Set<String> = []
    
    func connectToServer(completion: () -> Void) {
        do {
            let config = try XcodeServerConfig(host: "", user: "", password: "")
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
            self.findDevelopBot()
        }
    }
    
    func findDevelopBot() {
        masterBot = bots.first!
        let fileLocation = NSBundle.mainBundle().pathForResource("id_rsa", ofType: "")!
        let text = try! String(contentsOfFile: fileLocation)
        masterBot.configuration.sourceControlBlueprint.privateSSHKey = text
        masterBot.configuration.sourceControlBlueprint.publicSSHKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJc69TW+cpA3lbK5D6AbUG9NJMsluch6YCz688JQRIccHNStF0DMFTGkSj4W6ZHyjW1ycRBo0TfLtnEPOrTOqe7qaCBEE8yC9WNJYsnmd62VvaXx/Xieou/SCZhSwUT+q46wHtih1S4Fi7G31ltQsknrI9cbt7Fe3tHj6OPYli2/aiME7QQ30kIOqtPYWt1ePXHkXLgHPPVwlo8dKEwgt5oeTI1JV6mkirxYLkF1GGLnNyfG8l3Irx3C/kFii2xJLrVlNZ3RUwhFRgmR4rQNNhJzHoqP3cVoTFJh6UwYzr4WEwSlrk8yipKjVHVdi5rKeQkPbFR1P4mQLRdqfDJ6G/ ramy.kfoury@zalando.de"
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
    
    private func toString(dict: NSDictionary) {
        let data = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
        let json = NSString(data: data, encoding: NSUTF8StringEncoding)
        if let json = json {
            print(json)
        }
    }

    private func createBot(forBranch branch: String) {
        print("creating bot for branch \(branch)")
        var json = masterBot.dictionarify().mutableCopy() as! [NSString: AnyObject]
        json["name"] = branch
        let text = try! String(contentsOfFile: "/Users/\(NSUserName())/.ssh/id_rsa")
        
        var configuration = masterBot.configuration.dictionarify().mutableCopy() as! [NSString: AnyObject]
        var sourceControlBlueprint = configuration["sourceControlBlueprint"] as! [NSString: AnyObject]
        toString(sourceControlBlueprint)
        let repoID = sourceControlBlueprint["DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey"] as! NSString
        var workspaceBlueprint = sourceControlBlueprint["DVTSourceControlWorkspaceBlueprintLocationsKey"] as! [NSString: AnyObject]
        toString(workspaceBlueprint)
        var repo = workspaceBlueprint[repoID] as! [NSString: AnyObject]
        repo["DVTSourceControlBranchIdentifierKey"] = branch
        toString(repo)
        workspaceBlueprint[repoID] = repo
        sourceControlBlueprint["DVTSourceControlWorkspaceBlueprintLocationsKey"] = workspaceBlueprint
        configuration["sourceControlBlueprint"] = sourceControlBlueprint
        json["configuration"] = configuration
        toString(json)
        
        let bot = Bot(json: json)
        bot.configuration.sourceControlBlueprint.privateSSHKey = text
        bot.configuration.sourceControlBlueprint.publicSSHKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJc69TW+cpA3lbK5D6AbUG9NJMsluch6YCz688JQRIccHNStF0DMFTGkSj4W6ZHyjW1ycRBo0TfLtnEPOrTOqe7qaCBEE8yC9WNJYsnmd62VvaXx/Xieou/SCZhSwUT+q46wHtih1S4Fi7G31ltQsknrI9cbt7Fe3tHj6OPYli2/aiME7QQ30kIOqtPYWt1ePXHkXLgHPPVwlo8dKEwgt5oeTI1JV6mkirxYLkF1GGLnNyfG8l3Irx3C/kFii2xJLrVlNZ3RUwhFRgmR4rQNNhJzHoqP3cVoTFJh6UwYzr4WEwSlrk8yipKjVHVdi5rKeQkPbFR1P4mQLRdqfDJ6G/ ramy.kfoury@zalando.de"
        bot.configuration.sourceControlBlueprint.certificateFingerprint = "8CA5483171A2C9C9B2C7C6F0BC913230"
        server.createBot(bot) { (response) -> () in
            print("yo bitch")
        }
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