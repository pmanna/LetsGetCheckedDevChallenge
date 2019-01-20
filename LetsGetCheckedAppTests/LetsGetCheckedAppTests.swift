//
//  LetsGetCheckedAppTests.swift
//  LetsGetCheckedAppTests
//
//  Created by Paolo on 19/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import XCTest
@testable import LetsGetCheckedApp

class LetsGetCheckedAppTests: XCTestCase {
	var restService: CloudService!
	
	override func setUp() {
		restService	= CloudService()
		
		restService.urlProtocol		= "http"
		restService.serviceString   = "localhost:9001"
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testLoadPosts() {
		let loadExpect	= expectation(description: "Load Post")
		var posts: [Post]?
		
		Post.load(from: restService) { (error, result) in
			if error == nil {
				posts	= result
			} else {
				XCTFail("\(error!.localizedDescription)")
			}
			loadExpect.fulfill()
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)
		
		XCTAssertNotNil(posts, "Posts is nil")
		XCTAssertGreaterThanOrEqual(posts!.count, 1, "Empty posts")
		
		if posts!.count > 1 {
			let first	= posts![0]
			let second	= posts![1]
			
			XCTAssertGreaterThanOrEqual(first.publishDate, second.publishDate, "Posts are not ordered")
		}
	}
	
	func testLoadComments() {
		let loadPostExpect		= expectation(description: "Load Post")
		let loadCommentExpect	= expectation(description: "Load Comments")
		var comments: [Comment]?
		
		Post.load(from: restService) { (error, posts) in
			if error == nil, posts != nil {
				XCTAssertGreaterThanOrEqual(posts!.count, 1, "No posts loaded")
				
				let firstPost	= posts!.first
				
				firstPost?.loadComments(from: self.restService) { (error, results) in
					if error == nil, results != nil {
						comments	= results
					} else {
						XCTFail("\(error!.localizedDescription)")
					}
					loadCommentExpect.fulfill()
				}
			} else {
				XCTFail("\(error!.localizedDescription)")
			}
			loadPostExpect.fulfill()
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)
		
		XCTAssertNotNil(comments, "Comments is nil")
	}
	
	func testPostComment() {
		let loadPostExpect		= expectation(description: "Load Post")
		var firstPost: Post?
		
		Post.load(from: restService) { (error, posts) in
			if error == nil, posts != nil {
				XCTAssertGreaterThanOrEqual(posts!.count, 1, "No posts loaded")
				
				firstPost	= posts!.first
			} else {
				XCTFail("\(error!.localizedDescription)")
			}
			loadPostExpect.fulfill()
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)
		
		XCTAssertNotNil(firstPost, "No posts present")
		
		let commentCreateExpect	= expectation(description: "Create Comment")
		
		Comment.create(on: restService, for: firstPost!.postId,
					   user: "Test", content: "Test comment") { (error, data) in
						if error == nil {
							commentCreateExpect.fulfill()
						} else {
							XCTFail("\(error!.localizedDescription)")
						}
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)
		
		let loadCommentExpect	= expectation(description: "Load Comments")
		var lastComment: Comment?
		
		firstPost!.loadComments(from: restService) { (error, results) in
			if error == nil, results != nil {
				lastComment	= results!.last
			} else {
				XCTFail("\(error!.localizedDescription)")
			}
			loadCommentExpect.fulfill()
		}
		
		waitForExpectations(timeout: 10.0, handler: nil)

		XCTAssertNotNil(lastComment, "No comment created")
		XCTAssertEqual(lastComment!.postId, firstPost!.postId)
		XCTAssertEqual(lastComment!.user, "Test")
		XCTAssertEqual(lastComment!.content, "Test comment")
	}
}
