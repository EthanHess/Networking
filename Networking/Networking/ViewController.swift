//
//  ViewController.swift
//  Networking
//
//  Created by Ethan Hess on 10/3/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tableView : UITableView!
    var refreshControl : UIRefreshControl!
    
    let postController = PostController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableViewAttributes()
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.addPostTapped))
        self.navigationItem.rightBarButtonItem = barButton
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ViewController.refreshControlPulled(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func tableViewAttributes() {
        
        registerTableView()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        postController.delegate = self
    }
    
    func registerTableView() {
        
        tableView = UITableView(frame: view.bounds, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
    }
    
    func refreshControlPulled(sender: UIRefreshControl) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        postController.fetchPosts(reset: true) { (newPosts) in
            
            sender.endRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func addPostTapped() {
        
        presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .Alert)
        
        var usernameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextFieldWithConfigurationHandler { (usernameField) in
            usernameField.placeholder = "Display name"
            usernameTextField = usernameField
        }
        
        alertController.addTextFieldWithConfigurationHandler { (messageField) in
            
            messageField.placeholder = "What's up?"
            messageTextField = messageField
        }
        
        let postAction = UIAlertAction(title: "Post", style: .Default) { (action) in
            
            guard let username = usernameTextField?.text where !username.isEmpty,
                let text = messageTextField?.text where !text.isEmpty else {
                    
                    self.popErrorAlert()
                    return
            }
            
            self.postController.addPost(username, text: text)
        }
        
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func popErrorAlert() {
        
        let alertController = UIAlertController(title: "Oh no!", message: "You may have not entered text or lack internet connection.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource, UITableViewDelegate, PostControllerDelegate {
    
    func postsUpdated(posts: [Post]) {
        
        tableView.reloadData()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postController.posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(NSDate(timeIntervalSince1970: post.timestamp))"
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row+1 == postController.posts.count {
            
            postController.fetchPosts(reset: false, completion: { (newPosts) in
                
                if !newPosts.isEmpty {
                    self.tableView.reloadData()
                }
            })
        }
    }
}

