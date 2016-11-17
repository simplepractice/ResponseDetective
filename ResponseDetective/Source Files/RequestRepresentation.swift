//
//  RequestRepresentation.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Represents a request.
public final class RequestRepresentation {

	/// Request method.
	public let method: String

	/// Request URL string.
	public let url: String

	/// Request headers, represented by strings.
	public let headers: [String: String]

	/// Request content type.
	public var contentType: String? {
		return headers["Content-Type"]
	}

	/// Request body input stream.
	public let bodyStream: InputStream?

	/// Request body data. Most requests will have only a stream available, so
	/// accessing this property will lazily open the stream and drain it in a
	/// thread-blocking manner.
	public var bodyData: Data? {
		return bodyStream.flatMap { stream in
			let data = NSMutableData()
			stream.open()
			while stream.hasBytesAvailable {
				var buffer = [UInt8](repeating: 0, count: 1024)
				let length = stream.read(&buffer, maxLength: buffer.count)
				data.append(buffer, length: length)
			}
			stream.close()
			return data as Data
		}
	}

	/// Request body UTF-8 string.
	public var bodyUTF8String: String? {
		return bodyData.flatMap { NSString(data: $0, encoding: String.Encoding.utf8.rawValue) } as String?
	}

	/// Initializes the receiver with an instance of NSURLRequest.
	///
	/// - parameter request: The foundation NSSURLRequest object.
	///
	/// - returns: An initialized receiver or nil if an instance should not be
	/// created using the given request.
	public init?(_ request: URLRequest) {
		if let url = request.url?.absoluteString {
			self.method = request.httpMethod ?? "GET"
			self.url = url
			self.headers = request.allHTTPHeaderFields ?? [:]
			self.bodyStream = {
				if let bodyData = request.httpBody {
					return InputStream(data: bodyData)
				} else if let bodyStream = request.httpBodyStream {
					return bodyStream
				} else {
					return nil
				}
			}()
		} else {
			self.method = String()
			self.url = String()
			self.headers = Dictionary()
			self.bodyStream = nil
			return nil
		}
	}

}

// MARK: -

extension RequestRepresentation: CustomStringConvertible {

	public var description: String {
		return "\(method) \(url)"
	}

}
