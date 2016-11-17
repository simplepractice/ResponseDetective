//
//  XMLInterceptorSpec.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Nimble
import ResponseDetective
import Quick

class XMLInterceptorSpec: QuickSpec {
	
	override func spec() {
		
		describe("XMLInterceptor") {
			
			var stream: BufferOutputStream!
			var sut: XMLInterceptor!

			let uglyFixtureString = "<foo>\t<bar baz=\"qux\">lorem ipsum</bar\n></foo>"
			let uglyFixtureData = uglyFixtureString.data(using: String.Encoding.utf8)!
			let prettyFixtureString = "<?xml version=\"1.0\"?>\n<foo>\n  <bar baz=\"qux\">lorem ipsum</bar>\n</foo>"

			let fixtureRequest = RequestRepresentation( {
        var mutableRequest = URLRequest(url: URL(string: "https://httpbin.org/post")!)
				mutableRequest.httpMethod = "POST"
				mutableRequest.setValue("application/xml", forHTTPHeaderField: "Content-Type")
				mutableRequest.httpBody = uglyFixtureData
				return mutableRequest
			}())!

			let fixtureResponse = ResponseRepresentation(HTTPURLResponse(
        url: URL(string: "https://httpbin.org/post")!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
				headerFields: [
					"Content-Type": "text/xml"
				]
			)!, uglyFixtureData)!

			beforeEach {
				stream = BufferOutputStream()
				sut = XMLInterceptor(outputStream: stream)
			}

			it("should be able to intercept application/xml requests") {
				expect(sut.canInterceptRequest(fixtureRequest)).to(beTrue())
			}

			it("should be able to intercept text/xml responses") {
				expect(sut.canInterceptResponse(fixtureResponse)).to(beTrue())
			}

			it("should output a correct string when intercepting a application/xml request") {
				sut.interceptRequest(fixtureRequest)
				expect(stream.buffer).toEventually(contain(prettyFixtureString), timeout: 2, pollInterval: 0.5)
			}

			it("should output a correct string when intercepting a text/xml response") {
				sut.interceptResponse(fixtureResponse)
				expect(stream.buffer).toEventually(contain(prettyFixtureString), timeout: 2, pollInterval: 0.5)
			}

		}
		
	}

}
