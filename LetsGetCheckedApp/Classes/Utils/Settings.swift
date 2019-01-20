//
//  Settings.swift
//
//  Created by Paolo Manna on 14/08/2018.
//

import UIKit

@objc class Settings: NSObject {
	override func value(forKey key: String) -> Any? {
		return UserDefaults.standard.object(forKey: key)
	}
	
	override func setValue(_ value: Any?, forKey key: String) {
		let ud	= UserDefaults.standard
		
		if value == nil {
			ud.removeObject(forKey: key)
		} else {
			ud.set(value!, forKey: key)
		}
	}
}

let settings	= Settings()

