//
//  DateFormatterSet.swift
//  MySiteFinder
//
//  Created by Paolo Manna on 17/08/2018.
//  Copyright © 2018 ESB Networks. All rights reserved.
//

import Foundation

class DateFormatterSet {
	lazy var dateTimeFormatter: DateFormatter? = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.medium
		df.timeStyle	= DateFormatter.Style.short
		
		return df
	}()
	
	lazy var shortDateTimeFormatter: DateFormatter? = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.short
		df.timeStyle	= DateFormatter.Style.short
		
		return df
	}()

	let isoFormatter	= ISO8601DateFormatter()
	
	lazy var noYearDateFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateFormat	= "d MMM"
		
		return df
	}()

	lazy var shortDateFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.short
		df.timeStyle	= DateFormatter.Style.none
		
		return df
	}()

	lazy var mediumDateFormatter: DateFormatter = {
		let df	= DateFormatter()
		
		df.dateStyle	= DateFormatter.Style.medium
		df.timeStyle	= DateFormatter.Style.none
		
		return df
	}()
    
    lazy var shortTimeFormatter: DateFormatter = {
        let df    = DateFormatter()
        
        df.dateStyle    = DateFormatter.Style.none
        df.timeStyle    = DateFormatter.Style.short
        
        return df
    }()
}

let dateFormatters	= DateFormatterSet()

extension String {
	func ISO8601Normalized() -> String {
		return String(prefix(19)) + "Z"
	}
}
