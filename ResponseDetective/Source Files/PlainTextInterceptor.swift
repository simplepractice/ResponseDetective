//
//  PlainTextInterceptor.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Intercepts plain text requests and responses.
public final class PlainTextInterceptor {
	
	/// The output stream used by the interceptor.
	public fileprivate(set) var outputStream: OutputStreamType
	
	// The acceptable content types.
	fileprivate let acceptableContentTypes = [
		"text/plain"
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
	
	// MARK: Prettifying
	
	/// Prettifies the plain text data.
	///
	/// - parameter data: The plain text data to prettify.
	///
	/// - returns: A prettified plain text string.
	fileprivate func prettifyPlainTextData(_ data: Data) -> String? {
		return Optional(data).flatMap {
			NSString(data: $0, encoding: String.Encoding.utf8.rawValue) as String?
		}
	}
}

// MARK: -

extension PlainTextInterceptor: RequestInterceptorType {
	
	// MARK: RequestInterceptorType implementation
	
	public func canInterceptRequest(_ request: RequestRepresentation) -> Bool {
		return request.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}
	
	public func interceptRequest(_ request: RequestRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let plainTextString = request.bodyData.flatMap({
				self.prettifyPlainTextData($0 as Data)
			}) {
				DispatchQueue.main.async {
					self.outputStream.write(plainTextString)
				}
			}
		}
	}
	
}

// MARK: -

extension PlainTextInterceptor: ResponseInterceptorType {
	
	// MARK: ResponseInterceptorType implementation
	
	public func canInterceptResponse(_ response: ResponseRepresentation) -> Bool {
		return response.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}
	
	public func interceptResponse(_ response: ResponseRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let plainTextString = response.bodyData.flatMap({
				self.prettifyPlainTextData($0 as Data)
			}) {
				DispatchQueue.main.async {
					self.outputStream.write(plainTextString)
				}
			}
		}
	}
	
}
