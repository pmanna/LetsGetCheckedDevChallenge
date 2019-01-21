//
//  Post.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 20/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import Foundation

class Post: Decodable {
    var postId: Int
    var title: String
    var author: String
    var publishDate: Date
    var slug: String
    var desc: String
    var content: String
	
	// Not included in JSON
	var comments	= [Comment]()
	
	private enum CodingKeys : String, CodingKey {
		case postId = "id"
		case title
		case author
		case publishDate = "publish_date"
		case slug
		case desc = "description"
		case content
	}
	
	func createHierarchical(from originalComments: [Comment]) {
		let ordered		= originalComments.sorted { $0.date < $1.date }
		let root		= ordered.filter { $0.parentId == nil }
		let children	= ordered.filter { $0.parentId != nil }
		
		for aChild in children {
			for aRoot in root {
				if aRoot.addToChildren(comment: aChild) {
					break
				}
			}
		}
		
		comments	= root
	}
	
	func flatComments() -> [Comment] {
		var result	= [Comment]()
		
		for aComment in comments {
			result.append(contentsOf: aComment.flatComments())
		}
		
		return result
	}
	
	func loadComments(from service: CloudService, completion: @escaping (Error?, [Comment]?) -> Void) -> Void {
		service.get(endpoint: "posts/\(postId)/comments", parameters: [:], convert: false) { (error, data) in
			if error == nil, data != nil,
				let results = try? jsonDecoder.decode([Comment].self, from: data as! Data) {
				self.createHierarchical(from: results)
				
				completion(error,results)
			} else {
				completion(error,nil)
			}
		}
	}
	
	class func load(from service: CloudService, completion: @escaping (Error?, [Post]?) -> Void) -> Void {
		service.get(endpoint: "posts", parameters: [:], convert: false) { (error, data) in
			if error == nil, data != nil,
				var results = try? jsonDecoder.decode([Post].self, from: data as! Data) {
				results.sort { (p1, p2) -> Bool in p1.publishDate > p2.publishDate }
				
				completion(error,results)
			} else {
				completion(error,nil)
			}
		}
	}
}
