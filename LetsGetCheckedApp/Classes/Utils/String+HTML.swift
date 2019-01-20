//
//  String+HTML.swift
//
//  Created by Paolo on 20/01/2019.
//

import Foundation

// From https://stackoverflow.com/a/47230632 - but with fewer optionals

extension String {
	var htmlToAttributedString: NSAttributedString {
		guard let data = data(using: .utf8) else { return NSAttributedString() }
		
		do {
			return try NSAttributedString(data: data,
										  options: [.documentType: NSAttributedString.DocumentType.html,
													.characterEncoding:String.Encoding.utf8.rawValue],
										  documentAttributes: nil)
		} catch {
			return NSAttributedString()
		}
	}
	var htmlToString: String {
		return htmlToAttributedString.string
	}
}
