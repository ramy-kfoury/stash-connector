//
//  StashNetworking.swift
//  StashConnector
//
//  Created by Ramy Kfoury on 24/10/15.
//  Copyright © 2015 Ramy Kfoury. All rights reserved.
//

import Foundation

private class StashURLBuilder {
    
    struct Constants {
        private static let scheme = "http"
        private static let host = "localhost"
        private static let port = 7990
        private static let apiPath = "/rest/api/1.0/"
    }
 
    static func build(endpoint: Endpoint) -> NSURL? {
        let components = NSURLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.port = Constants.port
        components.path = "\(Constants.apiPath)\(endpoint.path)"
        return components.URL
    }
}

private class StashRequestBuilder {
    
    struct Constants {
        private static let username = "ramy_kfoury"
        private static let password = "ramy10+08_89"
    }
    
    static func build(url: NSURL) -> NSURLRequest? {
        let loginString = "\(Constants.username):\(Constants.password)"
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
    case Repos(endpoint: Endpoint, projectKey: String)
    
    var path : String {
        switch self {
        case .Projects: return "projects"
        case let Repos(endpoint, projectKey): return "\(endpoint.path)/\(projectKey)/repos"
        }
    }
}

typealias StashNetworkingCompletion = (JSON?, ErrorType?) -> Void


class StashNetworking {
    
    static func request(withEndpoint endpoint: Endpoint, completion: StashNetworkingCompletion) {
        if let url = StashURLBuilder.build(endpoint), request = StashRequestBuilder.build(url) {
    
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print("error: \(error.localizedDescription): \(error.userInfo)")
                }
                else if let data = data {
                    let json = JSON(data: data)
                    completion(json, nil)
                }
            })
            
            task.resume()
        }
        else {
            print("Unable to create NSURL")
        }

    }
}