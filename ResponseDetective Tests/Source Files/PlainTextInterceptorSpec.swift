//
//  PlainTextInterceptorSpec.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Nimble
import ResponseDetective
import Quick

class PlainTextInterceptorSpec: QuickSpec {
	
	override func spec() {
		
		describe("PlainTextInterceptor") {
			
			var stream: BufferOutputStream!
			var sut: PlainTextInterceptor!
			
			let fixturePlainTextString = "foo-bar-baz"
			let fixturePlainTextData = fixturePlainTextString.data(using: String.Encoding.utf8)
			
			let fixtureRequest = RequestRepresentation( {
        var mutableRequest = URLRequest(url: URL(string: "https://httpbin.org/get")!)
				mutableRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
				mutableRequest.httpBody = fixturePlainTextData
				return mutableRequest
			}())!

			let fixtureResponse = ResponseRepresentation(HTTPURLResponse(
        url: URL(string: "https://httpbin.org/get")!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
				headerFields: [
					"Content-Type": "text/plain"
				]
			)!, fixturePlainTextData)!
			
			beforeEach {
				stream = BufferOutputStream()
				sut = PlainTextInterceptor(outputStream: stream)
			}
			
			it("should be able to intercept text/plain requests") {
				expect(sut.canInterceptRequest(fixtureRequest)).to(beTrue())
			}
			
			it("should be able to intercept text/plain responses") {
				expect(sut.canInterceptResponse(fixtureResponse)).to(beTrue())
			}
			
			it("should output a correct string when intercepting a text/plain request") {
				sut.interceptRequest(fixtureRequest)
				expect(stream.buffer).toEventually(contain(fixturePlainTextString), timeout: 2, pollInterval: 0.5)
			}
			
			it("should output a correct string when intercepting a text/plain response") {
				sut.interceptResponse(fixtureResponse)
				expect(stream.buffer).toEventually(equal([fixturePlainTextString]), timeout: 2, pollInterval: 0.5)
			}

		}
		
	}
}
