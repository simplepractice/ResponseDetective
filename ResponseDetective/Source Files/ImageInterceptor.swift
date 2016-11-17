//
//  ImageInterceptor.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

#if os(iOS)
	import UIKit
	private typealias OSImage = UIImage
#else
	import AppKit
	private typealias OSImage = NSImage
#endif

/// Intercepts image responses.
public final class ImageInterceptor {

	/// The output stream used by the interceptor.
	public fileprivate(set) var outputStream: OutputStreamType

	// MARK: Initialization

	/// Initializes the interceptor with a output stream.
	///
	/// - parameter outputStream: The output stream to be used.
	public init(outputStream: OutputStreamType) {
		self.outputStream = outputStream
	}

	/// Initializes the interceptor with a Println output stream.
	public convenience init() {
		self.init(outputStream: PrintlnOutputStream())
	}

	// MARK: Metadata extraction

	/// Extracts the metadata out of the image.
	///
	/// - parameter image: An image from which to extract metadata.
	///
	/// - returns: A metadata string.
	fileprivate func extractMetadataFromImage(_ contentType: String, _ image: OSImage) -> String {
		return "\(contentType) (\(Int(image.size.width))px × \(Int(image.size.height))px)"
	}

	/// Extracts the metadata out of the image data.
	///
	/// - parameter data: Image data from which to extract metadata.
	///
	/// - returns: A metadata string.
	fileprivate func extractMetadataFromImageData(_ contentType: String, _ data: Data) -> String? {
		return Optional(data).flatMap({
			#if os(iOS)
				return UIImage(data: $0)
			#else
				return NSImage(data: $0)
			#endif
		}).map({
			return self.extractMetadataFromImage(contentType, $0)
		})
	}

}

// MARK: -

extension ImageInterceptor: ResponseInterceptorType {

	// MARK: ResponseInterceptorType implementation

	public func canInterceptResponse(_ response: ResponseRepresentation) -> Bool {
		return response.contentType.map {
			(($0 as NSString).substring(to: 6) as String) == "image/"
		} ?? false
	}

	public func interceptResponse(_ response: ResponseRepresentation) {
		DispatchQueue.global(qos: .default).async {
			if let contentType = response.contentType, let metadataString = response.bodyData.flatMap({
				self.extractMetadataFromImageData(contentType, $0 as Data)
		    }) {
				DispatchQueue.main.async {
					self.outputStream.write(metadataString)
				}
			}
		}
	}
	
}
