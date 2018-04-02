//
//  JSONInterceptor.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Intercepts JSON requests and responses.
public final class JSONInterceptor {

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

	// MARK: Prettifying

	/// Prettifies the JSON data.
	///
	/// - parameter data: The JSON data to prettify.
	///
	/// - returns: A prettified JSON string.
	fileprivate func prettifyJSONData(_ data: Data) -> String? {
		return Optional(data).flatMap({
			try? JSONSerialization.jsonObject(with: $0, options: [])
		}).flatMap({
			try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted)
		}).flatMap({
			String(data: $0, encoding: .utf8)
		})
	}

	/// Prettifies the JSON data stream.
	///
	/// - parameter stream: The JSON data stream to prettify.
	///
	/// - returns: A prettified JSON stream.
	fileprivate func prettifyJSONStream(_ stream: InputStream) -> String? {
		return Optional(stream).flatMap({
			stream.open()
			let object: AnyObject? = try! JSONSerialization.jsonObject(with: $0, options: []) as AnyObject?
			stream.close()
			return object
		}).flatMap({
			try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted)
		}).flatMap({
			String(data: $0, encoding: .utf8)
		})
	}

}

// MARK: -

extension JSONInterceptor: RequestInterceptorType {

	// MARK: RequestInterceptorType implementation

	public func canInterceptRequest(_ request: RequestRepresentation) -> Bool {
		return request.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}

	public func interceptRequest(_ request: RequestRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let jsonString = request.bodyStream.flatMap({ self.prettifyJSONStream($0) }) {
				DispatchQueue.main.async {
					self.outputStream.write(jsonString)
				}
			}
		}
	}

}

// MARK: -

extension JSONInterceptor: ResponseInterceptorType {

	// MARK: ResponseInterceptorType implementation

	public func canInterceptResponse(_ response: ResponseRepresentation) -> Bool {
		return response.contentType.map {
			self.acceptableContentTypes.contains($0)
		} ?? false
	}

	public func interceptResponse(_ response: ResponseRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let jsonString = response.bodyData.flatMap({ self.prettifyJSONData($0 as Data) }) {
				DispatchQueue.main.async {
					self.outputStream.write(jsonString)
				}
			}
		}
	}

}
