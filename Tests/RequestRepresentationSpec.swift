//
// RequestRepresentationSpec.swift
//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
// Licensed under the MIT License.
//

import Foundation
import Nimble
import ResponseDetective
import Quick

internal final class RequestRepresentationSpec: QuickSpec {
	
	override func spec() {
		
		describe("RequestRepresentation") {
			
			context("after initializing with a request") {
				
				let fixtureRequest = NSMutableURLRequest(
					URL: NSURL(string: "https://httpbin.org/post")!,
					HTTPMethod: "POST",
					headerFields: [
						"Content-Type": "application/json",
						"X-Foo": "bar",
					],
					HTTPBody: try! NSJSONSerialization.dataWithJSONObject(["foo": "bar"], options: [])
				)
				
				let fixtureIdentifier = "1"
				
				var sut: RequestRepresentation!
				
				beforeEach {
					sut = RequestRepresentation(identifier: fixtureIdentifier, request: fixtureRequest, deserializedBody: nil)
				}
				
				it("should have a correct identifier") {
					expect(sut.identifier).to(equal(fixtureIdentifier))
				}
				
				it("should have a correct URLString") {
					expect(sut.URLString).to(equal(fixtureRequest.URL!.absoluteString))
				}
				
				it("should have a correct method") {
					expect(sut.method).to(equal(fixtureRequest.HTTPMethod))
				}
				
				it("should have correct headers") {
					expect(sut.headers).to(equal(fixtureRequest.allHTTPHeaderFields))
				}
				
				it("should have a correct body") {
					expect(sut.body).to(equal(fixtureRequest.HTTPBody))
				}
				
			}
			
		}

	}

}

private extension NSMutableURLRequest {

	convenience init(URL: Foundation.URL, HTTPMethod: String, headerFields: [String: String], HTTPBody: Data?) {
		self.init(url: URL)
		self.httpMethod = HTTPMethod
		self.allHTTPHeaderFields = headerFields
		self.httpBody = HTTPBody
	}

}
