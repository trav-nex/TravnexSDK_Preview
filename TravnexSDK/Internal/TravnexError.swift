
//
//  TravnexError.swift
//  Travnex_Ag_Component
//
//  Created by Dominic Thompson on 29/10/24.
//

import Foundation

enum TravnexError: LocalizedError {
    case notInitialized
    case invalidConfiguration
    case networkError(String)
    case locationError(String)
    case voiceAssistantError(String)
    case invalidURL
    case invalidResponse
    case invalidToken
    case conversationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Travnex SDK is not initialized"
        case .invalidConfiguration:
            return "Invalid SDK configuration"
        case .networkError(let message):
            return "Network error: \(message)"
        case .locationError(let message):
            return "Location error: \(message)"
        case .voiceAssistantError(let message):
            return "Voice Assistant error: \(message)"
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidToken:
            return "Invalid conversation token"
        case .conversationError(let message):
            return "Conversation error: \(message)"
        }

    }
}

public class TravnexLogger {
    static func log(_ message: String, level: LogLevel = .info) {
        #if DEBUG
        print("TravnexSDK [\(level.rawValue)]: \(message)")
        #endif
    }
    
    enum LogLevel: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }
}

