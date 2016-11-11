//
// JSONBodyDeserializer.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation

/// Deserializes JSON bodies.
@objc(RDTJSONBodyDeserializer) public final class JSONBodyDeserializer: NSObject, BodyDeserializer {
	
	/// Deserializes JSON data into a pretty-printed string.
	public func deserializeBody(_ body: Data) -> String? {
		do {
			let object = try JSONSerialization.jsonObject(with: body, options: [])
			let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
			return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
		} catch {
			return nil
		}
	}
	
}
