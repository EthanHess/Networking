//
//  PostController.swift
//  Networking
//
//  Created by Ethan Hess on 10/3/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = NSURL(string: "https://devmtn-post.firebaseio.com/posts/")
    static let endpoint = baseURL?.URLByAppendingPathExtension("json")
    
    weak var delegate: PostControllerDelegate?
    
    //delegate called when posts uptaded/set
    
    var posts: [Post] = [] {
        
        didSet {
            delegate?.postsUpdated(posts)
        }
    }
    
    init() {
        
        fetchPosts()
    }
    
    func addPost(username: String, text: String) {
     
        let post = Post(username: username, text: text)
        
        guard let requestURL = post.endpoint else { fatalError("URL optional is nil") }
        
        NetworkController.performHTTPRequestForURL(requestURL, httpMethod: .PUT, body: post.jsonData) { (data, error) in
            
            let responseDataString = NSString(data: data!, encoding: NSUTF8StringEncoding) ?? ""
            
            if error != nil {
                print("Error: \(error)")
            } else if responseDataString.containsString("error") {
                print("Error: \(responseDataString)")
            } else {
                print("Successfully saved data to endpoint. \nResponse: \(responseDataString)")
            }
            
            self.fetchPosts()
            
        }
    }
    
    func fetchPosts(reset reset : Bool = true, completion:((newPosts: [Post]) -> Void)? = nil) {
        
        guard let requestURL = PostController.endpoint else { fatalError("Post Endpoint url failed") }
        
        let queryEndInterval = reset ? NSDate().timeIntervalSince1970 : posts.last?.queryTimestamp ?? NSDate().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
            ]
        
        NetworkController.performHTTPRequestForURL(requestURL, httpMethod: .GET, urlParams: urlParameters) { (data, error) in
            
            let responseDataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            guard let data = data,
                
                let postDictionaries = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? [String: [String: AnyObject]] else {
                    
                    print("Unable to serialize JSON. \nResponse: \(responseDataString)") //pop alert?
                    if let completion = completion {
                        completion(newPosts: [])
                    }
                    return
            }
            
            //map posts and sort them
            
            let posts = postDictionaries.flatMap({
                Post(json: $0.1, identifier: $0.0)
            })
            
            let sortedPosts = posts.sort({
                $0.0.timestamp > $0.1.timestamp
            })
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.appendContentsOf(sortedPosts)
                }
                
                if let completion = completion {
                    completion(newPosts: sortedPosts)
                }
                
                return
            })
        }
    }
}

protocol PostControllerDelegate: class {
    
    func postsUpdated(posts: [Post])
}