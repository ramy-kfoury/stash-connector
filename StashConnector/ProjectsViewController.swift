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
    private var repositories = [StashRepository]()
    
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
                self.getRepositories()
            }
        }
    }
    
    private func getRepositories() {
        projects.forEach { project in
            self.getRepository(forProject: project)
        }
    }
    
    private func getRepository(forProject project: StashProject) {
        StashNetworking.request(withEndpoint: Endpoint.Repos(projectKey: project.key)) { (json, error) in
            guard let json = json else { return }
            
            if let values = json["values"].array {
                self.repositories = values.map { value in
                    StashRepository(withJSON: value)
                }
                self.listRepositoriesPerProject()
            }
        }
    }
    
    private func listRepositoriesPerProject() {
        projects.forEach { project in
            let projectRepos = self.repositories.filter { repository in
                repository.projectid == project.id
            }
            projectRepos.forEach{ repository in
                StashNetworking.request(withEndpoint: Endpoint.Branches(projectKey: project.key, repositorySlug: repository.slug)) { json, error in
                    guard let json = json else { return }

                    if let values = json["values"].array {
                        let branches = values.map { value in
                            StashBranch(withJSON: value)
                        }
                        print(project)
                        print(projectRepos)
                        print(branches)
                    }
                }
            }
        }
    }
    
}
