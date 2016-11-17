//
//  JSONInterceptorSpec.swift
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Nimble
import ResponseDetective
import Quick

class JSONInterceptorSpec: QuickSpec {

	override func spec() {

		describe("JSONInterceptor") {

			var stream: BufferOutputStream!
			var sut: JSONInterceptor!

			let uglyFixtureString = "{\"foo\":\"bar\"\n,\"baz\":true }"
			let uglyFixtureData = uglyFixtureString.data(using: String.Encoding.utf8)!
			let prettyFixtureString = "{\n  \"foo\" : \"bar\",\n  \"baz\" : true\n}"

			let fixtureRequest = RequestRepresentation( {
        var mutableRequest = URLRequest(url: URL(string: "https://httpbin.org/post")!)
				mutableRequest.httpMethod = "POST"
				mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
				mutableRequest.httpBody = uglyFixtureData
				return mutableRequest
			}())!

			let fixtureResponse = ResponseRepresentation(HTTPURLResponse(
        url: URL(string: "https://httpbin.org/post")!,
        statusCode: 200,
        httpVersion: "HTTP/1.1",
				headerFields: [
					"Content-Type": "application/json"
				]
			)!, uglyFixtureData)!

			beforeEach {
				stream = BufferOutputStream()
				sut = JSONInterceptor(outputStream: stream)
			}

			it("should be able to intercept application/json requests") {
				expect(sut.canInterceptRequest(fixtureRequest)).to(beTrue())
			}

			it("should be able to intercept application/json responses") {
				expect(sut.canInterceptResponse(fixtureResponse)).to(beTrue())
			}

			it("should output a correct string when intercepting a application/json request") {
				sut.interceptRequest(fixtureRequest)
				expect(stream.buffer).toEventually(contain(prettyFixtureString), timeout: 2, pollInterval: 0.5)
			}

			it("should output a correct string when intercepting a application/json response") {
				sut.interceptResponse(fixtureResponse)
				expect(stream.buffer).toEventually(contain(prettyFixtureString), timeout: 2, pollInterval: 0.5)
			}

		}

	}
	
}
