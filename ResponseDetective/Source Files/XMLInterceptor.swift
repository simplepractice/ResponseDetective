//
//  XMLInterceptor.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Intercepts XML requests and responses.
public final class XMLInterceptor {

	/// The output stream used by the interceptor.
	public fileprivate(set) var outputStream: OutputStreamType

	// The acceptable content types.
	fileprivate let acceptableContentTypes = [
		"application/xml",
		"text/xml"
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

	/// Prettifies the XML string.
	///
	/// - parameter string: The XML string to prettify.
	///
	/// - returns: A prettified XML string.
	fileprivate func prettifyXMLString(_ string: String) -> String? {
		return rdv_prettifyXMLString(string)
	}

	/// Prettifies the XML data.
	///
	/// - parameter data: The XML data to prettify.
	///
	/// - returns: A prettified XML string.
	fileprivate func prettifyXMLData(_ data: Data) -> String? {
		return Optional(data).flatMap({
			NSString(data: $0, encoding: String.Encoding.utf8.rawValue) as String?
		}).flatMap({
			self.prettifyXMLString($0)
		})
	}

}

// MARK: -

extension XMLInterceptor: RequestInterceptorType {

	// MARK: RequestInterceptorType implementation

	public func canInterceptRequest(_ request: RequestRepresentation) -> Bool {
		return request.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}

	public func interceptRequest(_ request: RequestRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let XMLString = request.bodyData.flatMap({
				self.prettifyXMLData($0 as Data)
			}) {
				DispatchQueue.main.async {
					self.outputStream.write(XMLString)
				}
			}
		}
	}

}

// MARK: -

extension XMLInterceptor: ResponseInterceptorType {

	// MARK: ResponseInterceptorType implementation

	public func canInterceptResponse(_ response: ResponseRepresentation) -> Bool {
		return response.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}

	public func interceptResponse(_ response: ResponseRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let XMLString = response.bodyData.flatMap({
				self.prettifyXMLData($0 as Data)
			}) {
				DispatchQueue.main.async {
					self.outputStream.write(XMLString)
				}
			}
		}
	}
	
}
