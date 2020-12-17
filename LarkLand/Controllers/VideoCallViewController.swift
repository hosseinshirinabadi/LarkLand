////
////  VideoCallViewController.swift
////  LarkLand
////
////  Created by Hossein on 12/17/20.
////
//
//
//import UIKit
//import TwilioVideo
//
//class VideoCallViewController: UIViewController {
//
//    // MARK:- View Controller Members
//
//    // Video SDK components
//    var accessToken: String?
//    var roomName: String?
//    var room: Room?
//    var camera: CameraSource?
//    var localVideoTrack: LocalVideoTrack?
//    var localAudioTrack: LocalAudioTrack?
//    var remoteParticipant: RemoteParticipant?
//    var participantUsername: String?
//    var participantID: String?
//    var previewView: VideoView?
//    var remoteView: VideoView?
//
//
//    // MARK:- UIViewController
//
//    override func viewDidLoad() {
//
//        super.viewDidLoad()
//
//        createViewComponents()
//        setupView()
//        setupConstraints()
//
//        self.startPreview()
//        connect()
//
//    }
//
//    func createViewComponents() {
//
//        previewView = VideoView(frame: CGRect.zero, delegate: self)
//        previewView?.layer.borderWidth = 3
//
//    }
//
//    func setupView() {
//
//        self.view.backgroundColor = .white
//        self.view.addSubview(previewView!)
//
//    }
//
//    func makeButton(backgroundColor: UIColor, title: String? = nil, titleColor: UIColor? = nil, titleFont: UIFont? = nil, cornerRadius: CGFloat) -> UIButton {
//        let button = UIButton()
//        button.backgroundColor = backgroundColor
//        button.setTitle(title, for: .normal)
//        button.setTitleColor(titleColor, for: .normal)
//        button.titleLabel?.font = titleFont
//        button.layer.cornerRadius = cornerRadius
//        button.clipsToBounds = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }
//
//    func makeLabel(font: UIFont, text: String? = nil, textColor color: UIColor, alignment: NSTextAlignment) -> UILabel {
//        let label = UILabel()
//        label.font = font
//        label.textColor = color
//        label.text = text
//        label.textAlignment = alignment
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }
//
//    func showProfileInfo() {
//        profilePhotoButton.isHidden = !showProfile
//        participantLabel.isHidden = !showProfile
//        backgroundLabel.isHidden = !showProfile
//        remoteView?.isHidden = showProfile
//    }
//
//    func changeButtonImageColor(button: UIButton, color: UIColor) {
//        let imageView = button.imageView
//        imageView?.image = button.imageView?.image?.withRenderingMode(.alwaysTemplate)
//        imageView?.tintColor = color
//    }
//
//    override var prefersHomeIndicatorAutoHidden: Bool {
//        return self.room != nil
//    }
//
//
//    // MARK:- IBActions
//    func connect() {
//        // Configure access token either from server or manually.
//        // If the default wasn't changed, try fetching from server.
//
//        // Prepare local media which we will share with Room Participants.
//        self.prepareLocalMedia()
//
//        // Preparing the connect options with the access token that we fetched (or hardcoded).
//        let connectOptions = ConnectOptions(token: accessToken!) { (builder) in
//
//            // Use the local media that we prepared earlier.
//            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
//            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
//
//            // Use the preferred audio codec
//            if let preferredAudioCodec = Settings.shared.audioCodec {
//                builder.preferredAudioCodecs = [preferredAudioCodec]
//            }
//
//            // Use the preferred video codec
//            if let preferredVideoCodec = Settings.shared.videoCodec {
//                builder.preferredVideoCodecs = [preferredVideoCodec]
//            }
//
//            // Use the preferred encoding parameters
//            if let encodingParameters = Settings.shared.getEncodingParameters() {
//                builder.encodingParameters = encodingParameters
//            }
//
//            // Use the preferred signaling region
//            if let signalingRegion = Settings.shared.signalingRegion {
//                builder.region = signalingRegion
//            }
//
//            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
//            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
//            if let roomName = self.roomName {
//                builder.roomName = roomName
//            }
//
//        }
//
//        // Connect to the Room using the options we provided.
//        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
//        self.showRoomUI(inRoom: true)
//    }
//
//    func setupRemoteVideoView() {
//        // Creating `VideoView` programmatically
//        self.remoteView = VideoView(frame: CGRect.zero, delegate: self)
//
//        self.view.insertSubview(self.remoteView!, at: 0)
//
//        // `VideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
//        // scaleAspectFit is the default mode when you create `VideoView` programmatically.
//        self.remoteView!.contentMode = .scaleAspectFill;
//
//        let centerX = NSLayoutConstraint(item: self.remoteView!,
//                                         attribute: NSLayoutConstraint.Attribute.centerX,
//                                         relatedBy: NSLayoutConstraint.Relation.equal,
//                                         toItem: self.view,
//                                         attribute: NSLayoutConstraint.Attribute.centerX,
//                                         multiplier: 1,
//                                         constant: 0);
//        self.view.addConstraint(centerX)
//        let centerY = NSLayoutConstraint(item: self.remoteView!,
//                                         attribute: NSLayoutConstraint.Attribute.centerY,
//                                         relatedBy: NSLayoutConstraint.Relation.equal,
//                                         toItem: self.view,
//                                         attribute: NSLayoutConstraint.Attribute.centerY,
//                                         multiplier: 1,
//                                         constant: 0);
//        self.view.addConstraint(centerY)
//        let width = NSLayoutConstraint(item: self.remoteView!,
//                                       attribute: NSLayoutConstraint.Attribute.width,
//                                       relatedBy: NSLayoutConstraint.Relation.equal,
//                                       toItem: self.view,
//                                       attribute: NSLayoutConstraint.Attribute.width,
//                                       multiplier: 1,
//                                       constant: 0);
//        self.view.addConstraint(width)
//        let height = NSLayoutConstraint(item: self.remoteView!,
//                                        attribute: NSLayoutConstraint.Attribute.height,
//                                        relatedBy: NSLayoutConstraint.Relation.equal,
//                                        toItem: self.view,
//                                        attribute: NSLayoutConstraint.Attribute.height,
//                                        multiplier: 1,
//                                        constant: 0);
//        self.view.addConstraint(height)
//
////        let blurEffect = UIBlurEffect(style: .dark)
////        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
////        blurredEffectView.frame = remoteView!.bounds
////        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        view.addSubview(blurredEffectView)
//    }
//
//    @objc func micPressed(_sender: Any) {
//        if (self.localAudioTrack != nil) {
//            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
//
//            // Update the button title
//            if (self.localAudioTrack?.isEnabled == true) {
//                self.micButton.setImage(UIImage(named: "mute-audio"), for: .normal)
//            } else {
//                self.micButton.setImage(UIImage(named: "unmute-audio"), for: .normal)
//            }
//        }
//    }
//    @objc func videoPressed(_sender: Any) {
//            if (self.localVideoTrack != nil) {
//                self.localVideoTrack?.isEnabled = !(self.localVideoTrack?.isEnabled)!
//
//                // Update the button title
//                if (self.localVideoTrack?.isEnabled == true) {
//                    self.videoButton.setImage(UIImage(named: "mute-video"), for: .normal)
//                } else {
//                    self.videoButton.setImage(UIImage(named: "unmute-video"), for: .normal)
//                }
//            }
//        }
//
//    @objc func disconnectPressed(_sender: Any) {
//        if let room = self.room {
//            room.disconnect()
//            logMessage(messageText: "Attempting to disconnect from room \(room.name)")
//            if (notification) {
//                currUser.sendNotification(userID: participantID!, title: "", body: currUser.getCurrUserLabel() + " left the room")
//            }
//            self.dismiss(animated: true, completion: nil)
////            self.navigationController?.popViewController(animated: true)
//        }
//
//    }
//
//
//    // MARK:- Private
//    func startPreview() {
//        if PlatformUtils.isSimulator {
//            return
//        }
//        let frontCamera = CameraSource.captureDevice(position: .front)
//        let backCamera = CameraSource.captureDevice(position: .back)
//
//        if (frontCamera != nil || backCamera != nil) {
//
//            let options = CameraSourceOptions { (builder) in
//                // To support building with Xcode 10.x.
//                #if XCODE_1100
//                if #available(iOS 13.0, *) {
//                    // Track UIWindowScene events for the key window's scene.
//                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
//                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
//                }
//                #endif
//            }
//            // Preview our local camera track in the local video preview view.
//            camera = CameraSource(options: options, delegate: self)
//            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
//
//            // Add renderer to video track for local preview
//            localVideoTrack!.addRenderer(self.previewView!)
//            logMessage(messageText: "Video track created")
//
//            if (frontCamera != nil && backCamera != nil) {
//                // We will flip camera on tap.
//                let tap = UITapGestureRecognizer(target: self, action: #selector(VideoCallViewController.flipCamera))
//                self.previewView!.addGestureRecognizer(tap)
//            }
//
//            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
//                if let error = error {
//                    self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
//                } else {
//                    self.previewView!.shouldMirror = (captureDevice.position == .front)
//                }
//            }
//        }
//        else {
//            self.logMessage(messageText:"No front or back capture device found!")
//        }
//    }
//
//    @objc func flipCamera() {
//        var newDevice: AVCaptureDevice?
//
//        if let camera = self.camera, let captureDevice = camera.device {
//            if captureDevice.position == .front {
//                newDevice = CameraSource.captureDevice(position: .back)
//            } else {
//                newDevice = CameraSource.captureDevice(position: .front)
//            }
//
//            if let newDevice = newDevice {
//                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
//                    if let error = error {
//                        self.logMessage(messageText: "Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
//                    } else {
//                        self.previewView!.shouldMirror = (captureDevice.position == .front)
//                    }
//                }
//            }
//        }
//    }
//
//    func prepareLocalMedia() {
//
//        // We will share local audio and video when we connect to the Room.
//
//        // Create an audio track.
//        if (localAudioTrack == nil) {
//            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")
//
//            if (localAudioTrack == nil) {
//                logMessage(messageText: "Failed to create audio track")
//            }
//        }
//
//        // Create a video track which captures from the camera.
//        if (localVideoTrack == nil) {
//            self.startPreview()
//        }
//   }
//
//    // Update our UI based upon if we are in a Room or not
//    func showRoomUI(inRoom: Bool) {
//        self.micButton.isHidden = !inRoom
//        self.disconnectButton.isHidden = !inRoom
//        self.navigationController?.setNavigationBarHidden(inRoom, animated: true)
//        UIApplication.shared.isIdleTimerDisabled = inRoom
//
//        // Show / hide the automatic home indicator on modern iPhones.
//        if #available(iOS 11.0, *) {
//            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
//        }
//        messageLabel.isHidden = true
//    }
//
//    func cleanupRemoteParticipant() {
//        if ((self.remoteParticipant) != nil) {
//            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
//                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
//                remoteVideoTrack?.removeRenderer(self.remoteView!)
//                self.remoteView?.removeFromSuperview()
//                self.remoteView = nil
//            }
//        }
//        self.remoteParticipant = nil
//    }
//
//    func logMessage(messageText: String) {
//        NSLog(messageText)
//        messageLabel.text = messageText
//    }
//}
//
//// MARK:- RoomDelegate
//extension VideoCallViewController : RoomDelegate {
//    func roomDidConnect(room: Room) {
//        // At the moment, this example only supports rendering one Participant at a time.
//
//        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity ?? "")")
//
//        if (room.remoteParticipants.count > 0) {
//            self.remoteParticipant = room.remoteParticipants[0]
//            notification = false
//            self.remoteParticipant?.delegate = self
//
//            showProfile = false
//            showProfileInfo()
//
//        }
//        if (notification) {
//            currUser.sendNotification(userID: self.participantID!, title: "", body: currUser.getCurrUserLabel() + " is waiting for you in the room")
//        }
//    }
//
//    func roomDidDisconnect(room: Room, error: Error?) {
//        logMessage(messageText: "Disconnected from room \(room.name), error = \(String(describing: error))")
//
//        self.cleanupRemoteParticipant()
//        self.room = nil
//
//        self.showRoomUI(inRoom: false)
//    }
//
//    func roomDidFailToConnect(room: Room, error: Error) {
//        logMessage(messageText: "Failed to connect to room with error = \(String(describing: error))")
//        self.room = nil
//
//        self.showRoomUI(inRoom: false)
//    }
//
//    func roomIsReconnecting(room: Room, error: Error) {
//        logMessage(messageText: "Reconnecting to room \(room.name), error = \(String(describing: error))")
//    }
//
//    func roomDidReconnect(room: Room) {
//        logMessage(messageText: "Reconnected to room \(room.name)")
//    }
//
//    func participantDidConnect(room: Room, participant: RemoteParticipant) {
//        if (self.remoteParticipant == nil) {
//            self.remoteParticipant = participant
//            self.remoteParticipant?.delegate = self
//        }
//        currUser.setLastCall(participant: self.participantUsername!)
//        notification = false
//
//        showProfile = false
//        showProfileInfo()
//
//       logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
//    }
//
//    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
//        if (self.remoteParticipant == participant) {
//            cleanupRemoteParticipant()
//        }
//        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
//
//        showProfile = true
//        showProfileInfo()
//    }
//}
//
//
//
//// MARK:- RemoteParticipantDelegate
//extension VideoCallViewController : RemoteParticipantDelegate {
//
//    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
//        // Remote Participant has offered to share the video Track.
//
//        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
//
//        showProfile = false
//        showProfileInfo()
//    }
//
//    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
//        // Remote Participant has stopped sharing the video Track.
//
//        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
//
//        showProfile = true
//        showProfileInfo()
//    }
//
//    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
//        // Remote Participant has offered to share the audio Track.
//
//        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
//    }
//
//    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
//        // Remote Participant has stopped sharing the audio Track.
//
//        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
//    }
//
//    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
//        // We are subscribed to the remote Participant's video Track. We will start receiving the
//        // remote Participant's video frames now.
//
//        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
//
//        if (self.remoteParticipant == participant) {
//            setupRemoteVideoView()
//            videoTrack.addRenderer(self.remoteView!)
//        }
//    }
//
//    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
//        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
//        // remote Participant's video.
//
//        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")
//
//        if (self.remoteParticipant == participant) {
//            videoTrack.removeRenderer(self.remoteView!)
//            self.remoteView?.removeFromSuperview()
//            self.remoteView = nil
//        }
//
//
//    }
//
//    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
//        // We are subscribed to the remote Participant's audio Track. We will start receiving the
//        // remote Participant's audio now.
//
//        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
//    }
//
//    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
//        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
//        // remote Participant's audio.
//
//        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
//    }
//
//    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
//
//        showProfile = false
//        showProfileInfo()
//
//        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
//    }
//
//    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
//        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
//
//        showProfile = true
//        showProfileInfo()
//    }
//
//    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
//        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
//    }
//
//    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
//        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
//    }
//
//    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
//        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
//    }
//
//    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
//        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
//    }
//
//}
//
//// MARK:- VideoViewDelegate
//extension VideoCallViewController : VideoViewDelegate {
//    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
//        self.view.setNeedsLayout()
//    }
//}
//
//// MARK:- CameraSourceDelegate
//extension VideoCallViewController : CameraSourceDelegate {
//    func cameraSourceDidFail(source: CameraSource, error: Error) {
//        logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
//    }
//
//    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
//        if (self.localVideoTrack != nil) {
//            self.localVideoTrack?.isEnabled = false
//        }
//    }
//    func cameraSourceInterruptionEnded(source: CameraSource) {
//        if (self.localVideoTrack != nil) {
//            self.localVideoTrack?.isEnabled = true
//        }
//    }
//}
//
//// MARK: - Setting Constraints
//extension VideoCallViewController {
//
//    private func setupConstraints() {
//    previewView!.translatesAutoresizingMaskIntoConstraints = false
//        let bounds = UIScreen.main.bounds
//        let height = bounds.size.height //896
//        let width = bounds.size.width // 414
//
//    NSLayoutConstraint.activate([
//
//        disconnectButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
//        disconnectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: height * (-30 / height)),
//        disconnectButton.heightAnchor.constraint(equalToConstant: height * (50 / height)),
//        disconnectButton.widthAnchor.constraint(equalToConstant: width * (50 / width)),
//        micButton.leadingAnchor.constraint(equalTo: disconnectButton.trailingAnchor, constant: width * (15 / width)),
//        micButton.centerYAnchor.constraint(equalTo: disconnectButton.centerYAnchor, constant: 0),
////            micButton.bottomAnchor.constraint(equalTo: disconnectButton.topAnchor, constant: width * (-10 / width)),
//        micButton.widthAnchor.constraint(equalToConstant: width * (50 / width)),
//        micButton.heightAnchor.constraint(equalToConstant: height * (50 / height)),
//        videoButton.trailingAnchor.constraint(equalTo: disconnectButton.leadingAnchor, constant: width * (-15 / width)),
//        videoButton.centerYAnchor.constraint(equalTo: disconnectButton.centerYAnchor, constant: 0),
//        videoButton.widthAnchor.constraint(equalToConstant: width * (50 / width)),
//        videoButton.heightAnchor.constraint(equalToConstant: height * (50 / height)),
//        previewView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: width * (-10 / width)),
//        previewView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: height * (15 / height)),
//        previewView!.widthAnchor.constraint(equalToConstant: width * (100 / width)),
//        previewView!.heightAnchor.constraint(equalToConstant: height * (140 / height)),
//        messageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
//        messageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
//        messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
//
//        profilePhotoButton.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: -20),
//        profilePhotoButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
//        profilePhotoButton.widthAnchor.constraint(equalToConstant: profilePhotoSize),
//        profilePhotoButton.heightAnchor.constraint(equalToConstant: profilePhotoSize),
//        participantLabel.topAnchor.constraint(equalTo: profilePhotoButton.bottomAnchor, constant: 10),
//        participantLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
//
//        backgroundLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//        backgroundLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//        backgroundLabel.topAnchor.constraint(equalTo: self.view.topAnchor),
//        backgroundLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//
//        ])
//    }
//}
