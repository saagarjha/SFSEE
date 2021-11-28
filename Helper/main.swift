//
//  main.swift
//  SFSEE
//
//  Created by Saagar Jha on 11/28/21.
//

import Foundation

class Helper: HelperProtocol {
	func configuration() async throws -> Data {
		return try Data(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".swift-format"))
	}
}

class Service: NSObject, NSXPCListenerDelegate {
	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
		newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
		newConnection.exportedObject = Helper()
		newConnection.resume()
		return true
	}
}

let service = Service()
let listener = NSXPCListener.service()
listener.delegate = service
listener.resume()
