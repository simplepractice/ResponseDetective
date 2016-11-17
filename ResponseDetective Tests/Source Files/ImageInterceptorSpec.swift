//
//  ImageInterceptorSpec.swift
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Nimble
import ResponseDetective
import Quick

class ImageInterceptorSpec: QuickSpec {

	override func spec() {

		describe("ImageInterceptor") {

			var stream: BufferOutputStream!
			var sut: ImageInterceptor!

			let fixtureImageData = TestImageGenerator.generateImageData(type: .png, size: (100, 100))
			let fixtureImageString = "image/png (100px × 100px)"

			let fixtureResponse = ResponseRepresentation(HTTPURLResponse(
        url: URL(string: "https://httpbin.org/image/png")!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
				headerFields: [
					"Content-Type": "image/png"
				]
			)!, fixtureImageData)!

			beforeEach {
				stream = BufferOutputStream()
				sut = ImageInterceptor(outputStream: stream)
			}

			it("should be able to intercept image/png responses") {
				expect(sut.canInterceptResponse(fixtureResponse)).to(beTrue())
			}

			it("should output a correct string when intercepting a text/html response") {
				sut.interceptResponse(fixtureResponse)
				expect(stream.buffer).toEventually(contain(fixtureImageString), timeout: 2, pollInterval: 0.5)
			}
			
		}
		
	}
	
}
