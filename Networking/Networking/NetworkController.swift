//
//  NetworkController.swift
//  Networking
//
//  Created by Ethan Hess on 10/3/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import Foundation

class NetworkController {
    
    enum HTTPMethod : String {
        case GET = "GET"
        case PUT = "PUT"
        case POST = "POST"
        case PATCH = "PATCH"
        case DELETE = "DELETE"
    }
    
    static func performHTTPRequestForURL(url: NSURL, httpMethod: HTTPMethod, urlParams: [String:String]? = nil, body: NSData? = nil, completion:((data: NSData?, error: NSError?) -> Void)?) {
        
        let requestURL = urlFromURLParameters(url, urlParams: urlParams)
        
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = httpMethod.rawValue
        request.HTTPBody = body
        
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let completion = completion {
                completion(data: data, error: error)
            }
        }
        
        dataTask.resume()
    }
    
    static func urlFromURLParameters(url: NSURL, urlParams: [String:String]?) -> NSURL {
        
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = urlParams?.flatMap({
            NSURLQueryItem(name: $0.0, value: $0.1)
        })
        
        if let urlToReturn = components?.URL {
            return urlToReturn
            
        } else {
            fatalError("Something went terrible wrong, oh no")
        }
        
    }
}