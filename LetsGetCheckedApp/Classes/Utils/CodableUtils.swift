//
//  CodableUtils.swift
//  MyTime
//
//  Created by Paolo Manna on 26/11/2018.
//  Copyright © 2018 ESB Networks. All rights reserved.
//

import Foundation

/*
	Oddly enough, can't use ISO8601DateFormatter if using .formatted() below, because it's NOT a subclass of DateFormatter!
	Trying to use .iso8601 first for JSONxxx, this everywhere else
*/
let jsonDateFormatter: DateFormatter = {
	let df	= DateFormatter()
	
	df.locale		= Locale(identifier: "en_US_POSIX")
	df.timeZone		= TimeZone(secondsFromGMT: 0)
	df.dateFormat	= "yyyy-MM-dd'T'HH:mm:ss'Z'"
	
	return df
}()

let jsonEncoder: JSONEncoder	= { let enc = JSONEncoder(); enc.dateEncodingStrategy = .formatted(jsonDateFormatter); enc.outputFormatting = [.sortedKeys]; return enc }()
let jsonDecoder: JSONDecoder	= { let dec = JSONDecoder(); dec.dateDecodingStrategy = .formatted(jsonDateFormatter); return dec }()

extension Settings {
	func dateValue(forKey key: String) -> Date? {
		if let dateStr = value(forKey: key) as? String {
			return jsonDateFormatter.date(from: dateStr)
		}
		return nil
	}
	
	func setDateValue(_ value: Date?, forKey key: String) {
		if value != nil {
			setValue(jsonDateFormatter.string(from: value!), forKey: key)
		} else {
			setValue(nil, forKey: key)
		}
	}
	
	func objValue<T>(forKey key: String, ofType type: T.Type) -> T? where T : Decodable {
		if let objData = value(forKey: key) as? Data,
			let object = try? jsonDecoder.decode(type, from: objData) {
			return object
		}
		return nil
	}
	
	func setObjValue<T>(_ value: T?, forKey key: String) -> Void where T : Encodable {
		if value != nil,
			let data = try? jsonEncoder.encode(value) {
			setValue(data, forKey: key)
		} else {
			setValue(nil, forKey: key)
		}
	}
}

extension CloudService {
	func post<T>(endpoint: String, object: T, completion: @escaping (Error?, Any?) -> Void) -> Void where T: Encodable {
		var request = URLRequest(url: URL(string: "\(urlProtocol)://\(serviceString)\(basePath)/\(endpoint)")!,
								 cachePolicy: .useProtocolCachePolicy,
								 timeoutInterval: 30.0)
		request.httpMethod          = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody		    = try? jsonEncoder.encode(object)
		
		send(request: request, convert: false, completion: completion)
	}
	
	func put<T>(endpoint: String, object: T, completion: @escaping (Error?, Any?) -> Void) -> Void where T: Encodable {
		var request = URLRequest(url: URL(string: "\(urlProtocol)://\(serviceString)\(basePath)/\(endpoint)")!,
								 cachePolicy: .useProtocolCachePolicy,
								 timeoutInterval: 30.0)
		request.httpMethod          = "PUT"
		request.allHTTPHeaderFields = headers
		request.httpBody            = try? jsonEncoder.encode(object)
		
		send(request: request, convert: false, completion: completion)
	}
}
