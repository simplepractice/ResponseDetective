//
//  ResponseRepresentation.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Represents a response.
public final class ResponseRepresentation {

	/// Response status code.
	public let statusCode: Int

	/// Response status string.
	public var statusString: String {
		return HTTPURLResponse.localizedString(forStatusCode: statusCode).uppercased() as String
	}

	/// Response URL.
	public let url: String

	/// Response headers
	public let headers: [String: String]

	/// Response content type.
	public var contentType: String? {
		return headers["Content-Type"].map({
			$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		}).map({
			String($0[..<($0.range(of: ";")?.upperBound ?? $0.endIndex)])
		})
	}

	/// Response body data.
	public let bodyData: Data?

	/// Response body UTF-8 string.
	public var bodyUTF8String: String? {
		return bodyData.flatMap { NSString(data: $0, encoding: String.Encoding.utf8.rawValue) } as String?
	}

	/// Initializes the receiver with an instance of NSHTTPURLResponse.
	///
	/// - parameter response: The foundation NSHTTPURLResponse object.
	/// - parameter data: The data associated with the response.
	///
	/// - returns: An initialized receiver or nil if an instance should not be
	/// created using the given response.
	public init?(_ response: HTTPURLResponse, _ data: Data?) {
		if let url = response.url?.absoluteString {
			self.statusCode = response.statusCode
			self.url = url
			self.headers = response.allHeaderFields.reduce([:]) { (initial, element) in
        var _initial = initial
				if let key = element.0 as? String, let value = element.1 as? String {
					_initial[key] = value
				}
				return _initial
			}
			self.bodyData = data
		} else {
			self.statusCode = Int()
			self.url = String()
			self.headers = Dictionary()
			self.bodyData = nil
			return nil
		}
	}

}

// MARK: -

extension ResponseRepresentation: CustomStringConvertible {

	public var description: String {
		return "\(statusCode) \(statusString)"
	}

}
