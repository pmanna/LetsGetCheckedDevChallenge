//
//  CommentTableCell.swift
//  LetsGetCheckedApp
//
//  Created by Paolo on 20/01/2019.
//  Copyright © 2019 LetsGetChecked. All rights reserved.
//

import UIKit

class CommentTableCell: UITableViewCell {
	@IBOutlet var userLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	
	var comment: Comment? {
		didSet {
			if comment != nil {
				contentLabel.text	= comment!.content
				userLabel.text		= comment!.user
				dateLabel.text		= dateFormatters.mediumDateFormatter.string(for: comment!.date)
			} else {
				userLabel.text		= nil
				dateLabel.text		= nil
				contentLabel.text	= nil
			}
		}
	}
}
