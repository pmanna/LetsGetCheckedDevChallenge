//
//  ContentTableCell.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 20/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import UIKit

class ContentTableCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var authorLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!

	var post: Post? {
		didSet {
			if post != nil {
				descriptionLabel.text		= post!.desc
				authorLabel.text			= post!.author
				dateLabel.text				= dateFormatters.mediumDateFormatter.string(for: post!.publishDate)
//				contentLabel.attributedText	= post!.content.htmlToAttributedString
				contentLabel.text			= post!.content.htmlToString
			} else {
				descriptionLabel.text		= nil
				authorLabel.text			= nil
				dateLabel.text				= nil
				contentLabel.text			= nil
			}
		}
	}
}
