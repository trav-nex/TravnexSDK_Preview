

//
//  TranvexComponentViewController.swift
//  Travnex_Ag_Component
//
//  Created by Dominic Thompson on 28/10/24.
//

import UIKit
import AVFoundation
import CoreLocation


class TravnexComponentViewController: UIViewController {
    // MARK: - Properties
    private let voiceChatManager = VoiceChatManager.shared
    private let travnexConfig: TravnexConfig
    private var locationManager: CLLocationManager?
    private let userId: String
    private let tourId: UInt
    private var isListening = false
    
    // MARK: - UI Components
    private lazy var mainContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var speakerIndicatorView: SpeakerIndicatorView = {
        let view = SpeakerIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var controlsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 40
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    //Mark - Bottom Controls
    
    private lazy var bottomControls: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [chatModeButton, micButton, pocketModeButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 60
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
        
    }()
    
    private lazy var chatModeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "keyboard", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(chatModeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var micButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "mic.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var subtitlesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CC", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.tintColor = .white
        button.addTarget(self, action: #selector(subtitlesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pocketModeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "iphone.radiowaves.left.and.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(pocketModeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    //Mode states
    private var isChatModeActive = false
    private var isPocketModeActive = false
    
    
    // MARK: - Initialization
    init(config:TravnexConfig, userId: String, tourId: UInt) {
        self.travnexConfig = config
        self.userId = userId
        self.tourId = tourId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        setupVoiceChat()
    }

    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        // Add main container
        view.addSubview(mainContainer)
        
        // Add components to main container
        mainContainer.addSubview(closeButton)
        mainContainer.addSubview(loadingIndicator)
        mainContainer.addSubview(speakerIndicatorView)
        mainContainer.addSubview(contentLabel)
//        mainContainer.addSubview(controlsStack)
        mainContainer.addSubview(bottomControls)
        
        // Add controls to stack
//        controlsStack.addArrangedSubview(micButton)
//        controlsStack.addArrangedSubview(subtitlesButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: view.topAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            speakerIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speakerIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            speakerIndicatorView.widthAnchor.constraint(equalToConstant: 120),
            speakerIndicatorView.heightAnchor.constraint(equalToConstant: 120),
            
            contentLabel.topAnchor.constraint(equalTo: speakerIndicatorView.bottomAnchor, constant: 24),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
//            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            controlsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
//            controlsStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32)
            
            bottomControls.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomControls.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            bottomControls.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32)
        ])
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func setupVoiceChat() {
        voiceChatManager.delegate = self
        loadingIndicator.startAnimating()
        
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            initializeVoiceChat()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showLocationPermissionAlert()
        @unknown default:
            break
        }
    }
    
    // MARK: - Private Methods
    private func initializeVoiceChat() {
        guard let location = locationManager?.location else {
            showError("Unable to determine location")
            return
        }
        
        Task {
            do {
                try await voiceChatManager.initializeVoiceChat(
                    userId: userId,
                    tourId: tourId,
                    location: location,
                    travnexConfig: travnexConfig
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.speakerIndicatorView.isHidden = false
                    self?.contentLabel.text = "Connected to tour guide"
                }
                
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.loadingIndicator.stopAnimating()
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Access Required",
            message: "Please enable location access in Settings to use the tour guide feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Action Methods
    @objc private func closeButtonTapped() {
        Task {
            do {
                try await voiceChatManager.endConversation()
            } catch {
                print("Error ending conversation: \(error.localizedDescription)")
            }
            dismiss(animated: true)
        }
    }
    
    @objc private func micButtonTapped() {
        voiceChatManager.toggleMicrophone()
    }
    
    @objc private func subtitlesButtonTapped() {
        // Implement subtitles functionality
    }
    
    @objc private func chatModeButtonTapped() {
        animateButtonPress(chatModeButton)
        isChatModeActive.toggle()
        updateChatModeState()
        
        if isChatModeActive {
            activateChatMode()
        }else{
            deactivateChatMode()
        }
    }
    
    @objc private func pocketModeButtonTapped() {
        animateButtonPress(pocketModeButton)
        isPocketModeActive.toggle()
        updatePocketModeState()
        
        if isPocketModeActive {
            activatePocketMode()
        }else{
            deactivatePocketMode()
        }
    }
    
    // Mode Handlers
    private func activateChatMode() {
        chatModeButton.tintColor = .systemGreen
        //Other Implementatin Details
    }
    
    private func deactivateChatMode() {
        chatModeButton.tintColor = .white
    }
    
    private func activatePocketMode() {
        pocketModeButton.tintColor = .systemGreen
        
    }
    
    private func deactivatePocketMode() {
        pocketModeButton.tintColor = .white
    }
    
    private func updateChatModeState() {
        UIView.animate(withDuration: 0.2){
            self.chatModeButton.tintColor = self.isChatModeActive ? .systemGreen : .white
        }
    }
    
    private func updatePocketModeState() {
        UIView.animate(withDuration: 0.2){
            self.pocketModeButton.tintColor = self.isPocketModeActive ? .systemGreen : .white
        }
    }
    
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX:0.9, y: 0.9)
        }){ _ in
            UIView.animate(withDuration: 0.1){
                button.transform = .identity
            }
           
        }
        UIView.animate(withDuration: 0.2){
            button.transform = .identity
        }
    }
}


protocol TravnexModeDelegate: AnyObject {
    func didSwitchToChatMode(_ isActive: Bool)
    func didSwitchToPocketMode(_ isActive: Bool)
}
// MARK: - CLLocationManagerDelegate
extension TravnexComponentViewController: CLLocationManagerDelegate {
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedWhenInUse, .authorizedAlways:
//            initializeVoiceChat()
//        case .denied, .restricted:
//            showLocationPermissionAlert()
//        default:
//            break
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError("Unable to determine location: \(error.localizedDescription)")
    }
}

// MARK: - VoiceChatManagerDelegate
extension TravnexComponentViewController: VoiceChatManagerDelegate {
    func voiceChatManager(_ manager: VoiceChatManager, didChangeConnectionState state: VoiceChatConnectionState) {
      
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .connected(let remoteUserId):
                self?.speakerIndicatorView.setState(.active)
                if let remoteUserId = remoteUserId {
                    self?.contentLabel.text = "Connected with tour guide (\(remoteUserId))"
                }
            case .connecting:
                self?.speakerIndicatorView.setState(.connecting)
                self?.contentLabel.text = "Connecting to tour guide..."
            case .disconnected:
                self?.speakerIndicatorView.setState(.inactive)
                self?.contentLabel.text = "Disconnected from tour guide"
            case .failed(let error):
                self?.speakerIndicatorView.setState(.error)
                self?.showError(error.localizedDescription)
                
            }
        }
    }
    
    func voiceChatManager(_ manager: VoiceChatManager, didReceiveError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showError(error.localizedDescription)
        }
    }
    
    func voiceChatManager(_ manager: VoiceChatManager, didUpdateMicrophoneState isMuted: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.micButton.tintColor = isMuted ? .systemRed : .white
        }
    }
    
    func voiceChatManager(_ manager: VoiceChatManager, remoteParticipantMuted isMuted: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.speakerIndicatorView.setState(isMuted ? .inactive : .active)
        }
    }
}

// MARK: - SpeakerIndicatorView
class SpeakerIndicatorView: UIView {
    enum State {
        case inactive
        case connecting
        case active
        case error
    }
    
    private let circleLayer = CAShapeLayer()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Setup circle layer
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 4
        layer.addSublayer(circleLayer)
        
        // Setup icon
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            iconImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
        
        setState(.inactive)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2 - circleLayer.lineWidth,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        
        circleLayer.path = path.cgPath
        circleLayer.frame = bounds
    }
    
    func setState(_ state: State) {
        switch state {
        case .inactive:
            circleLayer.strokeColor = UIColor.gray.cgColor
            iconImageView.image = UIImage(systemName: "waveform")
            iconImageView.tintColor = .gray
            stopPulsing()
            
        case .connecting:
            circleLayer.strokeColor = UIColor.yellow.cgColor
            iconImageView.image = UIImage(systemName: "waveform")
            iconImageView.tintColor = .yellow
            startPulsing()
            
        case .active:
            circleLayer.strokeColor = UIColor.systemGreen.cgColor
            iconImageView.image = UIImage(systemName: "waveform.circle.fill")
            iconImageView.tintColor = .systemGreen
            startPulsing()
            
        case .error:
            circleLayer.strokeColor = UIColor.red.cgColor
            iconImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
            iconImageView.tintColor = .red
            stopPulsing()
        }
    }
    
    private func startPulsing() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 0.95
        pulseAnimation.toValue = 1.05
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        layer.add(pulseAnimation, forKey: "pulsing")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 1.0
        opacityAnimation.fromValue = 0.7
        opacityAnimation.toValue = 1.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        layer.add(opacityAnimation, forKey: "opacity")
    }
    
    private func stopPulsing() {
        layer.removeAllAnimations()
    }
}

// MARK: - Example Usage Implementation
//class ExampleViewController: UIViewController {
//    private lazy var startTourButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = .systemBlue
//        button.setTitle("Start Tour Guide", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 25
//        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
//        button.addTarget(self, action: #selector(startTourButtonTapped), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//    
//    private func setupUI() {
//        view.addSubview(startTourButton)
//        
//        NSLayoutConstraint.activate([
//            startTourButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            startTourButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
//            startTourButton.widthAnchor.constraint(equalToConstant: 200),
//            startTourButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//    
//    @objc private func startTourButtonTapped() {
//        let travnexVC = TravnexComponentViewController(
//            apiKey: "your-api-key",
//            userId: "user123",
//            tourId: 12345
//        )
//        present(travnexVC, animated: true)
//    }
//}

// MARK: - Additional Helper Extensions
//extension TravnexComponentViewController {
//    func updateContentStatus(_ text: String) {
//        UIView.transition(with: contentLabel, duration: 0.3, options: .transitionCrossDissolve) {
//            self.contentLabel.text = text
//        }
//    }
//    
//    func handleBackgroundAudioInterruption() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleAudioSessionInterruption),
//            name: AVAudioSession.interruptionNotification,
//            object: nil
//        )
//    }
//    
//    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
//        guard let userInfo = notification.userInfo,
//              let typeValue = userInfo[AVAudioSession.interruptionNotification.rawValue] as? UInt,
//              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
//            return
//        }
//        
//        switch type {
//        case .began:
//            // Audio session interrupted
//            updateContentStatus("Audio interrupted")
//            speakerIndicatorView.setState(.inactive)
//            
//        case .ended:
//            guard let optionsValue = userInfo[AVAudioSession.interruptionNotification.rawValue] as? UInt else { return }
//            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//            
//            if options.contains(.shouldResume) {
//                // Audio session can resume
//                updateContentStatus("Resuming audio...")
//                Task {
//                    // Attempt to reconnect if needed
//                    try? await voiceChatManager.initializeVoiceChat(
//                        userId: userId,
//                        tourId: tourId,
//                        location: locationManager?.location ?? CLLocation(),
//                        travnexConfig: travnexConfig
//                    )
//                }
//            }
//            
//        @unknown default:
//            break
//        }
//    }
//}

extension UIView {
    func findTravnexHostViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        }else if let nextResponder = self.next as? UIView{
            return nextResponder.findTravnexHostViewController()
        }else {
            return nil
        }
    }
}
