//
//  StashNetworking.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Foundation

private class StashURLBuilder {
    
    struct Personal {
        struct Constants {
            private static let scheme = "http"
            private static let host = "localhost"
            private static let port = 7990
            private static let apiPath = "/rest/api/1.0/"
        }
    }
    
    struct Work {
        struct Constants {
            private static let scheme = "https"
            private static let host = "stash.zalando.net"
            private static let port = 7990
            private static let apiPath = "/rest/api/1.0/"
        }
    }
 
    static func build(endpoint: Endpoint) -> NSURL? {
        let components = NSURLComponents()
        components.scheme = Work.Constants.scheme
        components.host = Work.Constants.host
        components.path = "\(Work.Constants.apiPath)\(endpoint.path)"
        return components.URL
    }
}

private class StashRequestBuilder {
    
    struct Personal {
        struct Constants {
            private static let username = "ramy_kfoury"
            private static let password = "password"
        }
    }
    struct Work {
    struct Constants {
        private static let username = ""
        private static let password = ""
    }
    }
    
    static func build(url: NSURL) -> NSURLRequest? {
        let loginString = "\(Work.Constants.username):\(Work.Constants.password)"
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        let request = NSMutableURLRequest(URL: url)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("Content-Type", forHTTPHeaderField: "application/json")
        return request
    }
    
}

indirect enum Endpoint {
    case Projects
    case Project(projectKey: String)
    case Repos(projectKey: String)
    case Repo(projectKey: String, repositorySlug: String)
    case Changes(projectKey: String, repositorySlug: String)
    case Commits(projectKey: String, repositorySlug: String)
    case Branches(projectKey: String, repositorySlug: String)
    
    var path : String {
        switch self {
        case .Projects: return "projects"
        case let Project(projectKey): return "\(Endpoint.Projects.path)/\(projectKey)"
        case let Repos(projectKey): return "\(Endpoint.Projects.path)/\(projectKey)/repos"
        case let Repo(projectkey, repositorySlug): return "\(Endpoint.Repos(projectKey: projectkey).path)/\(repositorySlug)"
        case let Changes(projectkey, repositorySlug): return "\(Endpoint.Repos(projectKey: projectkey).path)/\(repositorySlug)/changes"
        case let Commits(projectkey, repositorySlug): return "\(Endpoint.Repos(projectKey: projectkey).path)/\(repositorySlug)/commits"
        case let Branches(projectkey, repositorySlug): return "\(Endpoint.Repos(projectKey: projectkey).path)/\(repositorySlug)/branches"
        }
    }
}

typealias StashNetworkingCompletion = (JSON?, ErrorType?) -> Void


class StashNetworking {
    
    static func request(withEndpoint endpoint: Endpoint, completion: StashNetworkingCompletion) {
        if let url = StashURLBuilder.build(endpoint), request = StashRequestBuilder.build(url) {
            print(url)
            MyURLSession().httpGet(request, callback: { (data, error) -> Void in
                if let error = error {
                    print("error: \(error.localizedDescription): \(error.userInfo)")
                }
                else if let data = data {
                    let json = JSON(data: data)
                    completion(json, nil)
                }
            })
        }
        else {
            print("Unable to create NSURL")
        }

    }
}

class MyURLSession: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    typealias CallbackBlock = (data: NSData?, error: NSError?) -> Void
    var callback: CallbackBlock = {
        (data, error) -> Void in
        if error == nil {
            
        } else {
            print(error)
        }
    }
    
    func httpGet(request: NSURLRequest!, callback: CallbackBlock) {
            let configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration,
                delegate: self,
                delegateQueue:NSOperationQueue.mainQueue())
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                callback(data: data, error: error)
            }
            task.resume()
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential,
                NSURLCredential(forTrust:
                    challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
            completionHandler(request)
    }
}