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

class DataProvider {
    
    private var savedToDiskProjects = [StashProject]()
    private var projects = [StashProject]()
    private var dataStream = DataIOStream()
    
    func run() {
        savedToDiskProjects.appendContentsOf(dataStream.readLog())
        getProjects()
    }
    
    private func getProjects() {
        StashNetworking.request(withEndpoint: .Projects) { (json, error) -> Void in
            guard let json = json else { return }
            
            if let values = json["values"].array {
                self.projects = values.map { value in
                    StashProject(withJSON: value)
                }
                self.getRepositories()
            }
        }
    }
    
    private func getRepositories() {
        projects.forEach { project in
            self.getRepositories(forProject: project)
        }
    }
    
    private func getRepositories(forProject project: StashProject) {
        StashNetworking.request(withEndpoint: Endpoint.Repos(projectKey: project.key)) { (json, error) in
            guard let json = json else { return }
            
            if let values = json["values"].array {
                project.repositories = values.map { value in
                    StashRepository(withJSON: value)
                }
                self.getBranches()
            }
        }
    }
    
    private func getBranches() {
        var projectCount = 0
        projects.forEach { project in
            let savedProject = self.savedToDiskProjects.filter({ $0.key == project.key }).first
            var repositoryCount = 0
            project.repositories.forEach { repository in
                StashNetworking.request(withEndpoint: Endpoint.Branches(projectKey: project.key, repositorySlug: repository.slug)) { json, error in
                    guard let json = json else { return }
                    
                    if let values = json["values"].array {
                        repository.branches = values.map { value in
                            StashBranch(withJSON: value)
                        }
                    }
                    
                    if let savedProject = savedProject {
                        project.repositories.forEach { repository in
                            let fetchedBranches = Set(repository.branches.map({ $0.id }))
                            if let savedRepository = savedProject.repositories.filter({ $0.slug == repository.slug }).first {
                                let savedBranches = Set(savedRepository.branches.map({ $0.id }))
                                let newBranches = fetchedBranches.subtract(savedBranches)
                                let deletedBranches = savedBranches.subtract(fetchedBranches)
                                XcodeServerManager(newBranches: newBranches, deletedBranches: deletedBranches).updateBots()
                            }
                        }
                    }
                    
                    repositoryCount++
                    if (repositoryCount == project.repositories.count) {
                        projectCount++
                        if (projectCount == self.projects.count) {
                            self.dataStream.writeLog(self.projects)
                        }
                    }
                }
            }
        }
    }

}

private class DataIOStream {
    
    private var logPath: NSURL {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: String = paths[0]
        let directoryURL = NSURL(string: documentsDirectory)!.URLByAppendingPathComponent("StashConnector")
        let logPathURL = directoryURL.URLByAppendingPathComponent("Logs")
        if NSFileManager.defaultManager().fileExistsAtPath(logPathURL.absoluteString) {
            return logPathURL
        }
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(logPathURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
            return logPathURL
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        return NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("Logs")
    }
    
    func writeLog(projects: [StashProject]) {
        let writableProjects = projects.map { $0.toJSON() }
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(writableProjects, options: NSJSONWritingOptions.PrettyPrinted)
            do {
                let projectsPath = logPath.URLByAppendingPathComponent("projects.log").absoluteString
                if !NSFileManager.defaultManager().fileExistsAtPath(projectsPath) {
                    NSFileManager.defaultManager().createFileAtPath(projectsPath, contents: nil, attributes: nil)
                }
                if let theJSONText = NSString(data: jsonData,
                    encoding: NSASCIIStringEncoding) {
                        try theJSONText.writeToFile(projectsPath, atomically: true, encoding: NSUTF8StringEncoding)
                }
            } catch {
                // handle error
            }
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    func readLog() -> [StashProject] {
        do {
            let projectsPath = logPath.URLByAppendingPathComponent("projects.log").absoluteString
            if NSFileManager.defaultManager().fileExistsAtPath(projectsPath) {
                let contents = try String(contentsOfFile: projectsPath, encoding: NSUTF8StringEncoding)
                let json = JSON(data: contents.dataUsingEncoding(NSUTF8StringEncoding)!)
                if let projectsJSON = json.array {
                    let projects = projectsJSON.map { value in
                        StashProject(withJSON: value)
                    }
                    return projects
                }
            }
        } catch {
            // handle error
        }
        return [StashProject]()
    }
}


