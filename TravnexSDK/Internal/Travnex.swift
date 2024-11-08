//
//  TravnexSDK.swift
//  TravnexSDK-Preview
//
//  Created by Saba Moseshvili on 11/6/24.
//


//
//  TravnexSDK.swift
//  Travnex_Ag_Component
//
//  Created by Dominic Thompson on 28/10/24.
//

import Foundation
import UIKit
import AVFoundation
import CoreLocation
//import AgoraRtcKit
import ObjectiveC


public class Travnex {
    public static let shared = Travnex()
    
    public struct Configuration {
        let t_config: TravnexConfig
        public let theme: Theme
        
        public init(apiKey: String, serviceUrl: String = "https://converse-api.trav-nex.com", theme: Theme = .default) {
            self.t_config = TravnexConfig(apiKey: apiKey, travnexServiceUrl: serviceUrl)
            self.theme = theme
        }
    }
    
    public struct Theme {
        public let primaryColor: UIColor
        public let backgroundColor: UIColor
        public let textColor: UIColor
        public let iconColor: UIColor
        
        public static let `default` = Theme(
            primaryColor: UIColor(red: 182/255, green: 213/255, blue: 45/255, alpha: 1.0),
            backgroundColor: .black.withAlphaComponent(0.6),
            textColor: .white,
            iconColor: .white
        )
        
        public init(primaryColor: UIColor, backgroundColor: UIColor, textColor: UIColor, iconColor: UIColor) {
            self.primaryColor = primaryColor
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.iconColor = iconColor
        }
    }
    
    private var configuration: Configuration?
    
    private init(){}
    
    //MARK: Public Methods
    
    ///Initialize the SDK with configuration
    /// - Parameter configuration: SDK configuration options
    public func initialize(with configuration: Configuration){
        self.configuration = configuration
    }
    
    public func presentVoiceAssistant(from viewController: UIViewController, userId: String, tourId: UInt){
        guard let config = configuration else {
            TravnexLogger.log(TravnexError.notInitialized.errorDescription ?? "Not Initialized", level: .error)
            return
        }
        
        let travnexVC = TravnexComponentViewController(config: config.t_config, userId: userId, tourId: tourId)
        viewController.present(travnexVC, animated: true)
    }
    
    @discardableResult
    public func addTravnexButton(to view: UIView,
                                 position:TravnexButton.Position = .bottomRight,
                                 userId:String,
                                 tourId:UInt) -> TravnexButton{
        let button = view.addTravnexButton(position: position)
        button.addTarget(self, action: #selector(travnexButtonTapped(_:)), for: .touchUpInside)
        button.userId = userId
        button.tourId = tourId
        return button
    }
    
    @objc private func travnexButtonTapped(_ button: TravnexButton){
        guard let viewController = button.findTravnexHostViewController() else { return }
        presentVoiceAssistant(from: viewController,
                              userId: button.userId ?? "",
                              tourId: button.tourId ?? 0)
        
    }
    
    
}

extension TravnexButton {
    fileprivate var userId: String? {
        get { objc_getAssociatedObject(self, &AssociatedKey.userId) as? String}
        set { objc_setAssociatedObject(self, &AssociatedKey.userId, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    fileprivate var tourId: UInt? {
        get {objc_getAssociatedObject(self, &AssociatedKey.tourId) as? UInt}
        set {objc_setAssociatedObject(self, &AssociatedKey.tourId, newValue, .OBJC_ASSOCIATION_RETAIN)}
    }
    
    private struct AssociatedKey {
        static var userId = "userId"
        static var tourId = "tourId"
    }
}
