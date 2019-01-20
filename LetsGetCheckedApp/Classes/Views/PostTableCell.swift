//
//  PostTableCell.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 20/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import UIKit

class PostTableCell: UITableViewCell {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var authorLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	
	var post: Post? {
		didSet {
			if post != nil {
				titleLabel.text			= post!.title
				descriptionLabel.text	= post!.desc
				authorLabel.text		= post!.author
				dateLabel.text			= dateFormatters.mediumDateFormatter.string(for: post!.publishDate)
			} else {
				titleLabel.text			= nil
				descriptionLabel.text	= nil
				authorLabel.text		= nil
				dateLabel.text			= nil
			}
		}
	}
}
