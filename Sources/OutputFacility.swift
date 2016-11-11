//
// OutputFacility.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation

/// Represents an output facility which is capable of displaying requests,
/// responses and errors.
@objc(RDTOutputFacility) public protocol OutputFacility {
	
	/// Outputs a request representation.
	///
	/// - Parameter request: The request representation to output.
	func outputRequestRepresentation(_ request: RequestRepresentation)
	
	/// Outputs a response representation.
	///
	/// - Parameter response: The response representation to output.
	func outputResponseRepresentation(_ response: ResponseRepresentation)
	
	/// Outputs an error representation.
	///
	/// - Parameter error: The error representation to output.
	func outputErrorRepresentation(_ error: ErrorRepresentation)
	
}
