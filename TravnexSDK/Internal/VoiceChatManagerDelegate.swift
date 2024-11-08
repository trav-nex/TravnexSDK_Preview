//
//  VoiceChatManagerDelegate.swift
//  TravnexSDK-Preview
//
//  Created by Saba Moseshvili on 11/4/24.
//


//
//  VoiceChatManager.swift
//  Travnex_Ag_Component
//
//  Created by Dominic Thompson on 28/10/24.
//

import AgoraRtcKit
import AVFoundation
import CoreLocation

protocol VoiceChatManagerDelegate: AnyObject {
    func voiceChatManager(_ manager: VoiceChatManager, didChangeConnectionState state: VoiceChatConnectionState)
    func voiceChatManager(_ manager: VoiceChatManager, didReceiveError error: Error)
    func voiceChatManager(_ manager: VoiceChatManager, didUpdateMicrophoneState isMuted: Bool)
    func voiceChatManager(_ manager: VoiceChatManager, remoteParticipantMuted isMuted: Bool)
}

enum VoiceChatConnectionState {
    case disconnected
    case connecting
    case connected(remoteUserId: UInt?)
    case failed(Error)
}

enum VoiceChatError: LocalizedError {
    case notInitialized
    case invalidConfiguration
    case microphonePermissionDenied
    case connectionFailed(String)
    case engineError(AgoraErrorCode)
    
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Voice chat engine not initialized"
        case .invalidConfiguration:
            return "Invalid voice chat configuration"
        case .microphonePermissionDenied:
            return TravnexConfig.ErrorMessage.microphonePermission
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .engineError(let code):
            return "Engine error: \(code.rawValue)"
        }
    }
}

class VoiceChatManager: NSObject {
    // MARK: - Properties
    
    static let shared = VoiceChatManager()
    
    private var isLocalAudioMuted: Bool = false
    private var agoraKit: AgoraRtcEngineKit?
    private var currentChannel: String?
    private var remoteParticipantId: UInt?
    private var conversationConfig: ConversationConfig?
    private var travnexConfig: TravnexConfig?
    
    private(set) var connectionState: VoiceChatConnectionState = .disconnected {
        didSet {
            delegate?.voiceChatManager(self, didChangeConnectionState: connectionState)
        }
    }
    
    weak var delegate: VoiceChatManagerDelegate?
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
//        setupAudioSession()
    }
    
    // MARK: - Public Methods
    
    func initializeVoiceChat(
        userId: String,
        tourId: UInt,
        location: CLLocation,
        travnexConfig: TravnexConfig
    ) async throws {
        connectionState = .connecting
        
        do {
            // 1. Fetch configuration
            let config = try await TravnexService.fetchTourConversationConfig(
                for: userId,
                in: tourId,
                at: location,
                config: travnexConfig
            )
            
            // 2. Initialize Agora engine
            setupAgoraKit(with: config.sdrtnId)
            
            // 3. Store config for later use
            self.conversationConfig = config
            self.travnexConfig = travnexConfig
            
            // 4. Start conversation
            try await startConversation()
            
        } catch {
            connectionState = .failed(error)
            throw error
        }
    }
    
    func muteLocalAudio(){
        agoraKit?.muteLocalAudioStream(true)
        isLocalAudioMuted = true
    }
    
    func unMuteLocalAudio(){
        agoraKit?.muteLocalAudioStream(false)
        isLocalAudioMuted = false
    }
    
    func checkIfLocalAudioIsMuted() -> Bool {
        return isLocalAudioMuted
    }
    
    func toggleMicrophone() {
        guard let agoraKit = agoraKit else { return }
        let isMuted = isLocalAudioMuted
        agoraKit.muteLocalAudioStream(!isMuted)
        delegate?.voiceChatManager(self, didUpdateMicrophoneState: !isMuted)
    }
    
    func endConversation() async throws {
        guard let config = conversationConfig else { return }
        guard let travnexConfig = travnexConfig else { return }
        
        do {
            let ended = try await TravnexService.endConversation(
                conversationConfig: config,
                config: travnexConfig
            )
            
            if ended {
                await leaveChannel()
            }
        } catch {
            connectionState = .failed(error)
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session setup failed with error: \(error.localizedDescription)")
            delegate?.voiceChatManager(self, didReceiveError: error)
        }
    }
    
    private func setupAgoraKit(with sdrtnId: String) {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: sdrtnId, delegate: self)
        configureAgoraEngine()
        if agoraKit != nil {
            print("SDRTN Initialization Successful")
        }else{
            print("SDRTN Initialization Failed")
        }
    }
    
    private func configureAgoraEngine() {
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setClientRole(.broadcaster)
        agoraKit?.enableAudioVolumeIndication(250, smooth: 3, reportVad: true)
    }
    
    private func startConversation() async throws {
        guard let config = conversationConfig else {
            throw VoiceChatError.invalidConfiguration
        }
        guard let travnexConfig = travnexConfig else {
            throw VoiceChatError.invalidConfiguration
        }
        
//        guard let agoraKit = agoraKit else {
//            throw VoiceChatError.notInitialized
//        }
        
        guard await checkMicrophonePermission() else {
            throw VoiceChatError.microphonePermissionDenied
        }
        
        do {
            let started = try await TravnexService.startConversation(
                conversationConfig: config,
                config: travnexConfig
            )
            
            if started {
                try await joinChannel()
            } else {
                throw VoiceChatError.connectionFailed("Failed to start conversation")
            }
        } catch {
            connectionState = .failed(error)
            throw error
        }
    }
    
    private func joinChannel() async throws {
        guard let config = conversationConfig else {
            throw VoiceChatError.invalidConfiguration
        }
        
        let options = AgoraRtcChannelMediaOptions()
        options.channelProfile = .liveBroadcasting
        options.clientRoleType = .broadcaster
        options.publishMicrophoneTrack = true
        options.autoSubscribeAudio = true
        
        let result = agoraKit?.joinChannel(
            byToken: config.conversationToken,
            channelId: config.communicationChannel,
            uid: config.userId,
            mediaOptions: options
        )
        
        guard result == 0 else {
//            print("Failed to connect user to channel: \(result)")
            throw VoiceChatError.connectionFailed("Failed to join channel")
        }
        
        currentChannel = config.communicationChannel
    }
    
    private func leaveChannel() async {
        agoraKit?.leaveChannel(nil)
        currentChannel = nil
        remoteParticipantId = nil
        conversationConfig = nil
        connectionState = .disconnected
        AgoraRtcEngineKit.destroy()
    }
    
    private func checkMicrophonePermission() async -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }
}

// MARK: - AgoraRtcEngineDelegate

extension VoiceChatManager: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        connectionState = .connected(remoteUserId: nil)
        print("Successfully joined channel: \(channel), uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        remoteParticipantId = uid
        connectionState = .connected(remoteUserId: uid)
        print("Remote participant joined: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if uid == remoteParticipantId {
            remoteParticipantId = nil
            connectionState = .connected(remoteUserId: nil)
        }
        print("Remote participant left: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        let error = VoiceChatError.engineError(errorCode)
        connectionState = .failed(error)
        delegate?.voiceChatManager(self, didReceiveError: error)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioMuted muted: Bool, byUid uid: UInt) {
        if uid == remoteParticipantId {
            delegate?.voiceChatManager(self, remoteParticipantMuted: muted)
        }
    }
}
