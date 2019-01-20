//
//  CloudService.swift
//
//  Created by Paolo Manna on 23/02/2017.
//

import Foundation

/*
 A bit of explanation here:
 It would have been possible, and seemingly more natural, to use a serial DispatchQueue
 or OperationQueue to achieve the same serial behaviour for the service, however canceling a
 specific task would have been hard
 */

public class CloudService {
    static let session		= URLSession(configuration: .ephemeral)
    static var queueReqs	= true
	
    var headers: [String:String]
	var urlProtocol		= "https"
	var serviceString	= "localhost:8080"
	var basePath		= ""
	var tasks			= [URLSessionDataTask]()
	var lock			= NSLock()
#if DEBUG || TEST
	var timeStart: TimeInterval	= 0.0
#endif
	
	// MARK:- Methods
	
	required public init(token aToken: String? = nil) {
        headers = [String:String]()
        
        headers["Content-Type"]     = "application/json"
        headers["Cache-Control"]    = "No-Cache"
		headers["Accept"]			= "*/*"
		headers["Accept-Encoding"]	= "gzip, deflate"
		
        if let token = aToken {
            headers["Authorization"]    = "Bearer " + token
        }
    }
	
	func enqueue(task: URLSessionDataTask) {
		// Add task to the queue: it will be removed when response arrives
		// Under lock to support multi-threading
		if lock.lock(before: Date.distantFuture) {
#if DEBUG || TEST
			print("Queueing task \(tasks.count)")
#endif
			tasks.append(task)
			
			// If it's the only element in the queue, start it
			if tasks.count == 1 {
#if DEBUG || TEST
				print("Starting task 0")
				timeStart	= Date.timeIntervalSinceReferenceDate
#endif
				task.resume()
			}
			
			lock.unlock()
		}
	}
	
	func dequeue() {
		guard tasks.count > 0 else { return }
		
		if lock.lock(before: Date.distantFuture) {
#if DEBUG || TEST
			print("Dequeueing task 0 of \(tasks.count): response took \(((Date.timeIntervalSinceReferenceDate - timeStart) * 1000.0).rounded() / 1000.0) secs")
#endif
			tasks.remove(at: 0)
			
			// If there's another element in the queue, start it
			if tasks.count > 0 {
#if DEBUG || TEST
				print("Starting task 0 of \(tasks.count)")
				timeStart	= Date.timeIntervalSinceReferenceDate
#endif
				tasks[0].resume()
			}
			
			lock.unlock()
		}
	}
	
	func cancelPending() {
		guard tasks.count > 0 else { return }
		
		if lock.lock(before: Date.distantFuture) {
#if DEBUG || TEST
			print("Trying to cancel task 0")
#endif
			tasks.first?.cancel()
			
			lock.unlock()
			
			dequeue()
		}
	}
	
	func cancelAll() {
		guard tasks.count > 0 else { return }
		
		if lock.lock(before: Date.distantFuture) {
			for task in tasks {
				task.cancel()
			}
			
			tasks.removeAll()
			
			lock.unlock()
		}
	}
	
	func send(request: URLRequest, convert:Bool, completion: @escaping (Error?, Any?) -> Void) -> Void {
		let task	= CloudService.session.dataTask(with: request) { (data, response, error) in
			if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode < 200 || httpResponse.statusCode > 399 {
					let serverMsg		= HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
					
					completion(NSError(domain: Bundle.main.bundleIdentifier!,
					                   code: httpResponse.statusCode,
					                   userInfo: [NSLocalizedDescriptionKey: serverMsg]), nil)
                    self.dequeue()
					
					return
				}
                
                let responseHeaders = httpResponse.allHeaderFields
                
                if let contentType = responseHeaders["Content-Type"] as? String,
                    !contentType.contains("application/json") {
                    completion(NSError(domain: Bundle.main.bundleIdentifier!,
                                       code: -1,
                                       userInfo: [NSLocalizedDescriptionKey: "Invalid response: not a JSON payload"]), nil)
                    self.dequeue()
                    
                    return
                }
			}
			
			if convert {
				var responseObject: Any?	= nil
				
				if data != nil && data!.count > 0 {
					responseObject	= try? JSONSerialization.jsonObject(with: data!, options: [.mutableContainers])
				}
				
				completion(error, responseObject)
			} else {
				completion(error,data)
			}
			
            self.dequeue()
		}
		
		if CloudService.queueReqs {
			enqueue(task: task)
		} else {
			task.resume()
		}
	}
	
	
	
	func get(endpoint: String, parameters: [String:String] = [:], convert:Bool = true, completion: @escaping (Error?, Any?) -> Void) -> Void {
		
		var queryString	= ""
		
		for aKey in parameters.keys {
			if let paramValue = (parameters[aKey])?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
				if queryString.count > 1 {
					queryString.append("&")
				} else {
					queryString.append("?")
				}
				queryString.append("\(aKey)=\(paramValue)")
			}
		}
		
		var request		= URLRequest(url: URL(string: "\(urlProtocol)://\(serviceString)\(basePath)/\(endpoint)\(queryString)")!,
		           		             cachePolicy: .useProtocolCachePolicy,
		           		             timeoutInterval: 30.0)
		
		request.httpMethod          = "GET"
        request.allHTTPHeaderFields = headers
		
		send(request: request, convert: convert, completion: completion)
    }
	
    func prepareBody(with parameters: [String:Any]) -> Data? {
        if #available(iOS 11, *) {
            return try? JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys])
        } else {
            return try? JSONSerialization.data(withJSONObject: parameters, options: [])
        }
    }
    
	func post(endpoint: String, parameters: [String:Any], convert:Bool = true, completion: @escaping (Error?, Any?) -> Void) -> Void {
        var request = URLRequest(url: URL(string: "\(urlProtocol)://\(serviceString)\(basePath)/\(endpoint)")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 30.0)
        request.httpMethod          = "POST"
        request.allHTTPHeaderFields = headers
		request.httpBody		    = prepareBody(with: parameters)
		
		send(request: request, convert: convert, completion: completion)
    }
    
    func put(endpoint: String, parameters: [String:Any], convert:Bool = true, completion: @escaping (Error?, Any?) -> Void) -> Void {
        var request = URLRequest(url: URL(string: "\(urlProtocol)://\(serviceString)\(basePath)/\(endpoint)")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 30.0)
        request.httpMethod          = "PUT"
        request.allHTTPHeaderFields = headers
        request.httpBody            = prepareBody(with: parameters)
        
        send(request: request, convert: convert, completion: completion)
    }
}


