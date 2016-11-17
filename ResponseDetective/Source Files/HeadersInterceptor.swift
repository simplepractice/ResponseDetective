//
//  HeadersInterceptor.swift
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Intercepts all requests and responses and displays their metadata, including
/// errors.
public final class HeadersInterceptor {

	/// The output stream used by the interceptor.
	public fileprivate(set) var outputStream: OutputStreamType

	// The acceptable content types.
	fileprivate let acceptableContentTypes = [
		"application/json"
	]

	// MARK: Initialization

	/// Initializes the interceptor with an output stream.
	///
	/// - parameter outputStream: The output stream to be used.
	public init(outputStream: OutputStreamType) {
		self.outputStream = outputStream
	}

	/// Initializes the interceptor with a Println output stream.
	public convenience init() {
		self.init(outputStream: PrintlnOutputStream())
	}
	
}

// MARK: -

extension HeadersInterceptor: RequestInterceptorType {

	// MARK: RequestInterceptorType implementation

	public func canInterceptRequest(_ request: RequestRepresentation) -> Bool {
		return true
	}

	public func interceptRequest(_ request: RequestRepresentation) {
		DispatchQueue.global(qos: .default).async {
			let headersString = (request.headers.map({ (key, value) in
				"\(key): \(value)"
			}) as NSArray).componentsJoined(by: "\n") as String
			DispatchQueue.main.async {
				self.outputStream.write("\(request.method) \(request.url)")
				self.outputStream.write(headersString)
			}
		}
	}

}

// MARK: -

extension HeadersInterceptor: ResponseInterceptorType {

	// MARK: ResponseInterceptorType implementation

	public func canInterceptResponse(_ response: ResponseRepresentation) -> Bool {
		return true
	}

	public func interceptResponse(_ response: ResponseRepresentation) {
		DispatchQueue.global(qos: .default).async {
			let headersString = (response.headers.map({ (key, value) in
				"\(key): \(value)"
			}) as NSArray).componentsJoined(by: "\n") as String
			DispatchQueue.main.async {
				self.outputStream.write("\(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
				self.outputStream.write(headersString)
			}
		}
	}
	
}

// MARK: -

extension HeadersInterceptor: ErrorInterceptorType {

	// MARK: ErrorInterceptorType implementation

	public func interceptError(_ error: NSError, _ response: ResponseRepresentation?) {
		DispatchQueue.global(qos: .default).async {
			if let response = response {
				let headersString = (response.headers.map({ (key, value) in
					"\(key): \(value)"
				}) as NSArray).componentsJoined(by: "\n") as String
				DispatchQueue.main.async {
					self.outputStream.write("\(response.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
					self.outputStream.write(headersString)
				}
			}
			DispatchQueue.main.async {
				self.outputStream.write(error.description)
			}
		}
	}
	
}
