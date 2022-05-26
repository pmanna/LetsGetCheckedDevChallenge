//
//  MasterViewController.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 19/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var postViewController: PostViewController? = nil
    var posts   = [Post]()
    var restService: CloudService   = CloudService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let titleView	= UIImageView(image: UIImage(named: "Logo"))
		
		titleView.contentMode		= .scaleAspectFit
        navigationItem.titleView    = titleView
		
		tableView.tableFooterView	= UIView(frame: .zero)
		
        if let split = splitViewController {
            let controllers = split.viewControllers
            postViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PostViewController
        }
		
		restService.urlProtocol		= "http"
        restService.serviceString   = "localhost:9000"
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		
		loadPosts(self)
		
        super.viewWillAppear(animated)
    }
	
	// MARK:- Actions
	
	@IBAction func loadPosts(_ sender: Any) {
		UIApplication.shared.isNetworkActivityIndicatorVisible	= true
		
		Post.load(from: restService) { (error, posts) in
			DispatchQueue.main.async {
				if error == nil, posts != nil {
					self.posts   = posts!
					self.tableView.reloadData()
				} else {
					self.view.makeToast("Error: \(error?.localizedDescription ?? "")",  duration: 3.0, position: .center)
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible	= false
			}
		}
	}
	
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let post = posts[indexPath.row]
				
				if let vc = (segue.destination as! UINavigationController).topViewController as? PostViewController {
                	vc.post											= post
                	vc.navigationItem.leftBarButtonItem				= splitViewController?.displayModeButtonItem
               		vc.navigationItem.leftItemsSupplementBackButton	= true
				}
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableCell
		
        cell.post	= posts[indexPath.row]
		
        return cell
    }
}

