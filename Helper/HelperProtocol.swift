//
//  HelperProtocol.swift
//  SFSEE
//
//  Created by Saagar Jha on 11/28/21.
//

import Foundation

@objc protocol HelperProtocol {
	func configuration() async throws -> Data
}
