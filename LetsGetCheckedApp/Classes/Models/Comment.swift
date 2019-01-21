//
//  Comment.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 20/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import Foundation

let CommentSavedNotification	= Notification.Name("CommentSavedNotification")
let gMaxReplyLevel				= 8

class Comment: Codable {
    var commentId: Int?
    var postId: Int
    var parentId: Int?
    var user: String
    var date: Date
    var content: String
	
	// Not included in JSON
	var level: Int = 0
	var children	= [Comment]()
	
	private enum CodingKeys : String, CodingKey {
		case commentId = "id"
		case postId
		case parentId = "parent_id"
		case user
		case date
		case content
	}
	
	init(commentId: Int? = nil, postId: Int, parent: Int?, user: String, date: Date = Date(), content: String) {
		self.commentId	= commentId
		self.postId		= postId
		self.parentId	= parent
		self.user		= user
		self.date		= date
		self.content	= content
	}
	
	func addToChildren(comment: Comment) -> Bool {
		// Check if it's our child
		if comment.parentId == commentId {
			
			if level >= gMaxReplyLevel {
				return false
			}
			
			comment.level = level + 1
			children.append(comment)
			return true
		}
		
		for child in children {
			if child.addToChildren(comment: comment) {
				return true
			}
		}
		
		return false
	}
	
	func flatComments() -> [Comment] {
		var result	= [self]
		
		for child in children {
			result.append(contentsOf: child.flatComments())
		}
		
		return result
	}
	
	func edit(on service: CloudService, completion: @escaping (Error?, Any?) -> Void) {
		guard commentId != nil else { return }
		
		service.put(endpoint: "comments/\(commentId!)", object: self) { (error, data) in
			if error == nil {
				completion(error, data)
			} else {
				completion(error, nil)
			}
		}
	}
	
	class func create(on service: CloudService, for postId: Int, parent: Int? = nil,
					  user: String, content: String, completion: @escaping (Error?, Any?) -> Void) {
		// Now, there's an odd bug on the server: even though postId is an integer, the record is created with postId as String
		// (Not a problem in JavaScript, I suppose, but a serious issue in strong typed languages)
		// This forces to some sort of workaround: the one I found is implemented here
		let parameters	= [
			"parent_id": parent != nil ? parent as Any: NSNull(),
			"user": user,
			"date": jsonDateFormatter.string(from: Date()),
			"content": content
			]
		
		service.post(endpoint: "posts/\(postId)/comments", parameters: parameters) { (error, json) in
			if error == nil, let dict = json as? [String:Any] {
				// Workaround here!
				// Create an object, and save it back with the proper structure
				// Should the bug be solved, we'd have called completion already
				let comment = Comment(commentId: dict["id"] as? Int,
									  postId: postId,
									  parent: dict["parent_id"] as? Int,
									  user: dict["user"] as! String,
									  content: dict["content"] as! String)
				comment.edit(on: service, completion: completion)
			} else {
				completion(error, nil)
			}
		}
	}
}
