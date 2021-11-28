//
//  SourceEditorCommand.swift
//  Extension
//
//  Created by Saagar Jha on 11/28/21.
//

import Foundation
import SwiftFormat
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
	static let supportedUTIs = [
		"com.apple.dt.playground",
		"public.swift-source",
		"com.apple.dt.playgroundpage",
	]

	lazy var connection: NSXPCConnection = {
		let connection = NSXPCConnection(serviceName: Bundle.init(for: Self.self).bundleIdentifier!.replacingOccurrences(of: "Extension", with: "Helper"))
		connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
		connection.resume()
		return connection
	}()

	deinit {
		connection.invalidate()
	}

	func perform(with invocation: XCSourceEditorCommandInvocation) async throws {
		let buffer = invocation.buffer

		guard Self.supportedUTIs.contains(buffer.contentUTI) else {
			return
		}

		var configuration: Configuration
		if let data = try? await (connection.remoteObjectProxy as! HelperProtocol).configuration(),
			let _configuration = try? JSONDecoder().decode(Configuration.self, from: data)
		{
			configuration = _configuration
		} else {
			configuration = Configuration()
		}

		configuration.tabWidth = buffer.tabWidth
		if buffer.usesTabsForIndentation {
			configuration.indentation = .tabs(1)
		} else {
			configuration.indentation = .spaces(buffer.indentationWidth)
		}
		let formatter = SwiftFormatter(configuration: configuration)
		var result = ""
		try formatter.format(source: invocation.buffer.completeBuffer, assumingFileURL: nil, selection: .infinite, to: &result)
		buffer.completeBuffer = result
	}
}
