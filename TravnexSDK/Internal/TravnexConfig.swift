
//
//  TravnexConfig.swift
//  Travnex_Ag_Component
//
//  Created by Dominic Thompson on 28/10/24.
//

import Foundation
import CoreLocation

struct TravnexConfig {
    let apiKey: String
    var travnexServiceUrl: String = "https://converse-api.travnex.com"
    
    struct ErrorMessage {
        static let microphonePermission = "Microphone permission is required to use Travnex Component"
        static let connectionFailed = "Failed to connect to Travnex Service"
        static let invalidToken = "Invalid conversation token"
        static let networkError = "Network error occurred"
    }
}

struct ConversationConfig: Codable {
    var userId: UInt
    var conversationToken: String
    var communicationChannel: String
    var geolocation: LocationData
    var locationInfo: String
    var sdrtnId: String
    var tourId:Int?
    var systemTourId:String?
    var tourInfo:String?
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    
    init(from location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}
