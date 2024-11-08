//
//  TravnexService.swift
//  TravnexSDK-Preview
//
//  Created by Dominic Thompson on 11/4/24.
//

import Foundation
import CoreLocation



class TravnexService {

    /**
        Fetches the conversation configuration token for a given user, tour, and location.

        This asynchronous function constructs a URL request to the Travnex service to fetch a conversation token.
        It sends a POST request with the user, tour, and location details in the request body, and expects a JSON response containing the conversation configuration.

        - Parameters:
        - user: The identifier for the user.
        - tour: The identifier for the tour.
        - location: The CLLocation object representing the user's current location.
        - travnexConfig: The configuration object containing the Travnex service URL and API key.

        - Returns: A `ConversationConfig` object containing the conversation configuration details.

        - Throws:
        - `TravnexError.invalidURL` if the URL string is invalid.
        - `TravnexError.invalidResponse` if the response is not an HTTP response.
        - `TravnexError.networkError` if the HTTP status code is not 200.
        - `TravnexError.invalidToken` if the JSON response does not contain a valid conversation configuration.
        - Any other errors thrown by `JSONSerialization` or `URLSession`.

        - Example usage:
        ```swift
        do {
            let conversationConfig = try await TranvexConversationConfigService.fetchConversationConfig(
                for: "user123",
                in: 1,
                at: CLLocation(latitude: 37.7749, longitude: -122.4194),
                config: travnexConfig
            )
            print("Conversation configuration: \(conversationConfig)")
        } catch {
            print("Failed to fetch conversation configuration: \(error)")
        }
            ```
    */

     static func fetchTourConversationConfig(
        for user: String,
        in tour: UInt,
        at location: CLLocation,
        config travnexConfig: TravnexConfig
     ) async throws -> ConversationConfig {
        guard let url = URL(string: "\(travnexConfig.travnexServiceUrl)/conversation/tour/config") else {
            throw TravnexError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(travnexConfig.apiKey, forHTTPHeaderField: "Travnex-API-Key")
        
        let parameters: [String: Any] = [
            "userId": user,
            "tourId": tour,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TravnexError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw TravnexError.networkError("Status code: \(httpResponse.statusCode)")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            throw TravnexError.invalidToken
        }

        let decoder = JSONDecoder()

        do {
            let conversationConfig = try decoder.decode(ConversationConfig.self, from: jsonData)
            return conversationConfig
        } catch {
            throw TravnexError.invalidToken
        }


        // guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
        //       let conversationToken = json["conversationToken"] as? String,
        //       let channelName = json["channelName"] as? String,
        //       let userId = UInt(user) else {
        //     throw TravnexError.invalidResponse
        // }
        
        // return ConversationConfig(
        //     userId: userId,
        //     conversationToken: conversationToken,
        //     communicationChannel: channelName,
        //     geolocation: LocationData(from: location),
        //     locationInfo: "Tour: \(tour)",
        //     sdrtnId: travnexConfig.apiKey
        // )
                

    }
    
    
    static func fetchConversationConfig(
       for user: String,
       at location: CLLocation,
       config travnexConfig: TravnexConfig
    ) async throws -> ConversationConfig {
       guard let url = URL(string: "\(travnexConfig.travnexServiceUrl)/conversation/config") else {
           throw TravnexError.invalidURL
       }
       
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       request.setValue(travnexConfig.apiKey, forHTTPHeaderField: "Travnex-API-Key")
       
       let parameters: [String: Any] = [
           "userId": user,
           "latitude": location.coordinate.latitude,
           "longitude": location.coordinate.longitude
       ]
       
       request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
       
       let (data, response) = try await URLSession.shared.data(for: request)
       
       guard let httpResponse = response as? HTTPURLResponse else {
           throw TravnexError.invalidResponse
       }
       
       guard httpResponse.statusCode == 200 else {
           throw TravnexError.networkError("Status code: \(httpResponse.statusCode)")
       }

       guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
           throw TravnexError.invalidToken
       }

       let decoder = JSONDecoder()

       do {
           let conversationConfig = try decoder.decode(ConversationConfig.self, from: jsonData)
           return conversationConfig
       } catch {
           throw TravnexError.invalidToken
       }


       // guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
       //       let conversationToken = json["conversationToken"] as? String,
       //       let channelName = json["channelName"] as? String,
       //       let userId = UInt(user) else {
       //     throw TravnexError.invalidResponse
       // }
       
       // return ConversationConfig(
       //     userId: userId,
       //     conversationToken: conversationToken,
       //     communicationChannel: channelName,
       //     geolocation: LocationData(from: location),
       //     locationInfo: "Tour: \(tour)",
       //     sdrtnId: travnexConfig.apiKey
       // )
               

   }
    
    /**
        Starts a conversation using the provided conversation token and Travnex configuration.

        This asynchronous function constructs a URL request to the Travnex service to start a conversation.
        It sends a POST request with the conversation token in the Authorization header and expects a successful HTTP response.

        - Parameters:
        - conversationToken: The token used to authenticate and start the conversation.
        - travnexConfig: The configuration object containing the Travnex service URL and other necessary settings.

        - Returns: A boolean value indicating whether the conversation was successfully started.

        - Throws:
        - `TravnexError.invalidURL` if the URL string is invalid.
        - `TravnexError.invalidResponse` if the response is not an HTTP response.
        - `TravnexError.conversationError` if the HTTP status code is not 200, with a message indicating the failure reason.
        - Any other errors thrown by `URLSession`.

        - Example usage:
        ```swift
        do {
            let success = try await TranvexConversationConfigService.startConversation(
                conversationToken: "your_conversation_token",
                config: travnexConfig
            )
            if success {
                print("Conversation started successfully.")
            }
        } catch {
            print("Failed to start conversation: \(error)")
        }
            ```
    */

    static func startConversation(conversationConfig: ConversationConfig, config travnexConfig: TravnexConfig) async throws -> Bool {
        guard let url = URL(string: "\(travnexConfig.travnexServiceUrl)/conversation/start") else {
            throw TravnexError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(travnexConfig.apiKey, forHTTPHeaderField: "Travnex-API-Key")
        
       
        let jsonData = try JSONEncoder().encode(conversationConfig)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Serialized JSON: \(jsonString)")
        }
//
//        do {
//            let configDictionary = conversationConfigToDictionary(conversationConfig)
//            let jsonData = try JSONSerialization.data(withJSONObject: configDictionary, options: [])
//
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("Serialized JSON: \(jsonString)")
//            }
////            request.httpBody = try JSONSerialization.data(withJSONObject: jsonData)
//        } catch {
//            print("Error serializing ConversationConfig: \(error)")
//        }
        
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TravnexError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw TravnexError.conversationError("Failed to start conversation. Status: \(httpResponse.statusCode)")
        }
        
        return true
    }


    /**
        Ends a conversation using the provided conversation token and Travnex configuration.

        This asynchronous function constructs a URL request to the Travnex service to end a conversation.
        It sends a POST request with the conversation token in the Authorization header and expects a successful HTTP response.

        - Parameters:
        - conversationToken: The token used to authenticate and end the conversation.
        - travnexConfig: The configuration object containing the Travnex service URL and other necessary settings.

        - Returns: A boolean value indicating whether the conversation was successfully ended.

        - Throws:
        - `TravnexError.invalidURL` if the URL string is invalid.
        - `TravnexError.invalidResponse` if the response is not an HTTP response.
        - `TravnexError.conversationError` if the HTTP status code is not 200, with a message indicating the failure reason.
        - Any other errors thrown by `URLSession`.

        - Example usage:
        ```swift
        do {
            let success = try await TranvexConversationConfigService.endConversation(
                conversationToken: "your_conversation_token",
                config: travnexConfig
            )
            if success {
                print("Conversation ended successfully.")
            }
        } catch {
            print("Failed to end conversation: \(error)")
        }
            ```
    */
    
    static func endConversation(conversationConfig: ConversationConfig, config travnexConfig: TravnexConfig) async throws -> Bool {
        guard let url = URL(string: "\(travnexConfig.travnexServiceUrl)/conversation/end") else {
            throw TravnexError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(travnexConfig.apiKey, forHTTPHeaderField: "Travnex-API-Key")
        
//        let parameters = try JSONEncoder().encode(conversationConfig)
        
        let parameters: [String: Any] = [
            "sdrtnId": conversationConfig.sdrtnId,
            "communicationChannel": conversationConfig.communicationChannel
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TravnexError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw TravnexError.conversationError("Failed to end conversation. Status: \(httpResponse.statusCode)")
        }
        
        return true
    }
    
    static func conversationConfigToDictionary(_ config: ConversationConfig) -> [String: Any] {
            return [
                "userId": config.userId,
                "conversationToken": config.conversationToken,
                "communicationChannel": config.communicationChannel,
                "geolocation": [
                    "latitude": config.geolocation.latitude,
                    "longitude": config.geolocation.longitude
                ],
                "locationInfo": config.locationInfo,
                "sdrtnId": config.sdrtnId
            ]
        }

}

