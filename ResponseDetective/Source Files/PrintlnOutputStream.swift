//
//  PrintlnOutputStream.swift
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

/// A simple output stream which prints its data right to the console using
/// stdlib's println function.
public final class PrintlnOutputStream: OutputStreamType {

	// MARK: OutputStreamType implementation

	public func write(_ string: String) {
		print(string)
	}

}
