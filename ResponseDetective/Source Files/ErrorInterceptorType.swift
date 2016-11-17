//
//  ErrorInterceptorType.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Instances of conforming types can be registered in the intercepting
/// NSURLProtocol and used to intercept NSHTTPURLResponses' errors.
public protocol ErrorInterceptorType: class {
	
	/// Intercepts and processes the incoming response error. Preferably, all
	/// side effects should be executed asynchronously, so that the response
	/// doesn't get blocked.
	///
	/// - parameter error: The received error.
	/// - parameter response: The response received along the error (if any).
	func interceptError(_ error: NSError, _ response: ResponseRepresentation?)
	
}
