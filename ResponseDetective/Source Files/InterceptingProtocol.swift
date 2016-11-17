//
//  Protocol.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

@objc(RDVIntercetingProtocol) public final class InterceptingProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {

	/// Request interceptors store.
	public fileprivate(set) static var requestInterceptors = [RequestInterceptorType]()

	/// Response interceptors store.
	public fileprivate(set) static var responseInterceptors = [ResponseInterceptorType]()
	
	/// Error interceptors store.
	public fileprivate(set) static var errorInterceptors = [ErrorInterceptorType]()

	/// Private under-the-hood session object.
	fileprivate var session: Foundation.URLSession!

	/// Private under-the-hood session task.
	fileprivate var sessionTask: URLSessionDataTask!
	
	/// Private under-the-hood response object
	fileprivate var response: HTTPURLResponse?
	
	/// Private under-the-hood response data object.
	fileprivate lazy var responseData = NSMutableData()

	// MARK: Interceptor registration

	/// Registers a new request interceptor.
	///
	/// - parameter interceptor: The new interceptor instance to register.
	///
	/// - returns: A unique token which can be used for removing that request
	/// interceptor.
	public static func registerRequestInterceptor(_ interceptor: RequestInterceptorType) {
		requestInterceptors.append(interceptor)
	}

	/// Registers a new response interceptor.
	///
	/// - parameter interceptor: The new response interceptor instance to register.
	///
	/// - returns: A unique token which can be used for removing that response
	/// interceptor.
	public static func registerResponseInterceptor(_ interceptor: ResponseInterceptorType) {
		responseInterceptors.append(interceptor)
	}
	
	/// Registers a new error interceptor.
	///
	/// - parameter interceptor: The new error interceptor instance to register.
	///
	/// - returns: A unique token which can be used for removing that error
	/// interceptor.
	public static func registerErrorInterceptor(_ interceptor: ErrorInterceptorType) {
		errorInterceptors.append(interceptor)
	}

	/// Unregisters the previously registered request interceptor.
	///
	/// - parameter removalToken: The removal token obtained when registering the
	/// request interceptor.
	public static func unregisterRequestInterceptor(_ interceptor: RequestInterceptorType) {
		requestInterceptors = requestInterceptors.filter({ $0 !== interceptor })
	}

	/// Unregisters the previously registered response interceptor.
	///
	/// - parameter removalToken: The removal token obtained when registering the
	/// response interceptor.
	public static func unregisterResponseInterceptor(_ interceptor: ResponseInterceptorType) {
		responseInterceptors = responseInterceptors.filter({ $0 !== interceptor })
	}
	
	/// Unregisters the previously registered error interceptor.
	///
	/// - parameter removalToken: The removal token obtained when registering the
	/// error interceptor.
	public static func unregisterErrorInterceptor(_ interceptor: ErrorInterceptorType) {
		errorInterceptors = errorInterceptors.filter({ $0 !== interceptor })
	}

	// MARK: Propagation helpers

	/// Propagates the request interception.
	///
	/// - parameter request: The intercepted request.
	fileprivate func propagateRequestInterception(_ request: URLRequest) {
		if let representation = RequestRepresentation(request) {
			for interceptor in InterceptingProtocol.requestInterceptors {
				if interceptor.canInterceptRequest(representation) {
					interceptor.interceptRequest(representation)
				}
			}
		}
	}

	/// Propagates the request interception.
	///
	/// - parameter request: The intercepted response.
	/// - parameter data: The intercepted response data.
	fileprivate func propagateResponseInterception(_ response: HTTPURLResponse, _ data: Data) {
		if let representation = ResponseRepresentation(response, data) {
			for interceptor in InterceptingProtocol.responseInterceptors {
				if interceptor.canInterceptResponse(representation) {
					interceptor.interceptResponse(representation)
				}
			}
		}
	}

	/// Propagates the error interception.
	///
	/// - parameter error: The intercepted response error.
	/// - parameter response: The intercepted response (if any).
	/// - parameter error: The error which occured during the request.
	fileprivate func propagateResponseErrorInterception(_ response: HTTPURLResponse?, _ data: Data?, _ error: NSError) {
		if let response = response, let representation = ResponseRepresentation(response, data) {
			for interceptor in InterceptingProtocol.errorInterceptors {
				interceptor.interceptError(error, representation)
			}
		}
	}

	// MARK: NSURLProtocol overrides
	
	public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
		super.init(request: request, cachedResponse: cachedResponse, client: client)
		session = Foundation.URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil)
		sessionTask = session.dataTask(with: request)
	}

	public override static func canInit(with request: URLRequest) -> Bool {
		return true
	}

	public override static func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}

	public override func startLoading() {
		propagateRequestInterception(request)
		sessionTask.resume()
	}

	public override func stopLoading() {
		sessionTask.cancel()
	}

	// MARK: NSURLSessionDataDelegate methods
	
	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy:URLCache.StoragePolicy.allowed)
		completionHandler(.allow)
		if let response = response as? HTTPURLResponse {
			self.response = response
		}
	}
	
	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		client?.urlProtocol(self, didLoad: data)
		responseData.append(data)
	}

	// MARK: NSURLSessionTaskDelegate methods
	
	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			client?.urlProtocol(self, didFailWithError: error)
			propagateResponseErrorInterception(response, responseData as Data, error as NSError)
		}
		client?.urlProtocolDidFinishLoading(self)
		if let response = self.response {
			propagateResponseInterception(response, responseData as Data)
		}
	}
}

// MARK: -

public extension InterceptingProtocol {
	
	static func unregisterAllRequestInterceptors() {
		requestInterceptors.removeAll(keepingCapacity: false)
	}
	
	static func unregisterAllResponseInterceptors() {
		responseInterceptors.removeAll(keepingCapacity: false)
	}
	
	static func unregisterAllErrorInterceptors() {
		errorInterceptors.removeAll(keepingCapacity: false)
	}
}
