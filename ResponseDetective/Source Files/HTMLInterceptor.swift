//
//  HTMLInterceptor.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Intercepts HTML requests and responses.
public final class HTMLInterceptor {

	/// The output stream used by the interceptor.
	public fileprivate(set) var outputStream: OutputStreamType

	// The acceptable content types.
	fileprivate let acceptableContentTypes = [
		"text/html"
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

	/// Prettifies the HTML string.
	///
	/// - parameter string: The HTML string to prettify.
	///
	/// - returns: A prettified HTML string.
	fileprivate func prettifyHTMLString(_ string: String) -> String? {
		return rdv_prettifyHTMLString(string)
	}

	/// Prettifies the HTML data.
	///
	/// - parameter data: The HTML data to prettify.
	///
	/// - returns: A prettified HTML string.
	fileprivate func prettifyHTMLData(_ data: Data) -> String? {
		return Optional(data).flatMap({
			NSString(data: $0, encoding: String.Encoding.utf8.rawValue) as String?
		}).flatMap({
			self.prettifyHTMLString($0)
		})
	}

}

// MARK: -

extension HTMLInterceptor: RequestInterceptorType {

	// MARK: RequestInterceptorType implementation

	public func canInterceptRequest(_ request: RequestRepresentation) -> Bool {
		return request.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}

	public func interceptRequest(_ request: RequestRepresentation) {
    DispatchQueue.global(qos: .default).async {
			if let HTMLString = request.bodyData.flatMap({
				self.prettifyHTMLData($0 as Data)
			}) {
				DispatchQueue.main.async {
					self.outputStream.write(HTMLString)
				}
			}
		}
	}

}

// MARK: -

extension HTMLInterceptor: ResponseInterceptorType {

	// MARK: ResponseInterceptorType implementation

	public func canInterceptResponse(_ response: ResponseRepresentation) -> Bool {
		return response.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}

	public func interceptResponse(_ response: ResponseRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let HTMLString = response.bodyData.flatMap({
				self.prettifyHTMLData($0 as Data)
			}) {
				DispatchQueue.main.async {
					self.outputStream.write(HTMLString)
				}
			}
		}
	}
	
}
