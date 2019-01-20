//
//  PostViewController.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 20/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import UIKit

class PostViewController: UITableViewController, UITextViewDelegate {
	@IBOutlet var headerView: UIView!
	@IBOutlet var footerView: UIView!
	@IBOutlet var accessoryView: UIToolbar!
	@IBOutlet var commentText: UITextView!
	@IBOutlet var userLabel: UILabel!

	var post: Post? {
		didSet {
			navigationItem.title	= post?.slug
		}
	}
	var comments = [Comment]()
	var restService: CloudService   = CloudService()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.tableFooterView		= footerView
		
		restService.urlProtocol			= "http"
		restService.serviceString   	= "localhost:9001"
		
		commentText.inputAccessoryView	= accessoryView

		NotificationCenter.default.addObserver(forName: CommentSavedNotification, object: nil, queue: OperationQueue.main)
		{ [weak self] (notification) in
			self?.tableView.reloadData()
		}
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		userLabel.text	= UIDevice.current.name
		
		loadComments()
	}
	
	// MARK:- Comments handling
	
	func loadComments() {
		guard post != nil else {
			comments	= [Comment]()
			
			return
		}
		
		UIApplication.shared.isNetworkActivityIndicatorVisible	= true
		
		post!.loadComments(from: restService) { (error, comments) in
			DispatchQueue.main.async {
				if error == nil && comments != nil {
					self.comments   = comments!
					self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
				} else {
					self.view.makeToast("Error: \(error?.localizedDescription ?? "")",  duration: 3.0, position: .center)
				}
				UIApplication.shared.isNetworkActivityIndicatorVisible	= false
			}
		}
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard post != nil else { return 0 }
		
		if section == 0 {
        	return 2
		} else {
			return comments.count
		}
    }
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section < 1 || comments.count < 1 {
			return 0.0
		}
		return 30.0
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section < 1 || comments.count < 1 { return nil }
		
		return headerView
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section	= indexPath.section
		let row		= indexPath.row
		var cell	= tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
		
		if section == 0 {
			switch row {
			case 0:
				cell.textLabel?.text	= post?.title
			case 1:
				cell	= tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath)
				
				if let contentCell = cell as? ContentTableCell {
					contentCell.post	= post
				}
			default:
				cell.textLabel?.text	= nil
			}
		} else {
			cell	= tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
			
			if let commentCell = cell as? CommentTableCell {
				commentCell.comment	= comments[row]
			}
		}
        return cell
    }
	
	// MARK:- Actions
	
	@IBAction func addComment(_ sender: UIButton) {
		guard commentText.text != nil else { return }
		
		Comment.create(on: restService,
					   for: post!.postId,
					   user: UIDevice.current.name,
					   content: commentText.text!)
		{ [weak self] (error, data) in
			DispatchQueue.main.async {
				self?.commentText.endEditing(true)
				if error == nil {
					self?.commentText.text	= nil
					self?.loadComments()
				} else {
					self?.view.makeToast("Error: \(error!.localizedDescription)", duration: 3.0, position: .center)
				}
			}
		}
	}
	
	@IBAction func endCommentEditing(_ sender: UIBarButtonItem) {
		view.endEditing(true)
	}
	
	// MARK:- UITextViewDelegate
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		tableView.scrollRectToVisible(footerView.frame, animated: true)
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
