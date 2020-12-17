//
//  OfficeViewController.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import UIKit
import SpriteKit
import TwilioVideo
import Firebase



class OfficeViewController: UIViewController, VideoCallDelegate {
    
    var videoCallSize: CGFloat = 150
    
    //Video Call SKD Variables
    var accessToken: String?
    var roomName: String?
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var participantUsername: String?
    var myView: VideoView!
    var friendView: VideoView!
    
    
    override func loadView() {
        self.view = SKView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        print(UIScreen.main.bounds.width)
        print(UIScreen.main.bounds.height)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoView()
        let scene = OfficeScene(size: view.bounds.size)
        scene.videoDelegate = self
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    func setupVideoView() {
        myView = VideoView(frame: CGRect.zero, delegate: self)
        self.view.addSubview(myView)
        myView.translatesAutoresizingMaskIntoConstraints = false
        myView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -10-videoCallSize/2).isActive = true
        myView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        myView.widthAnchor.constraint(equalToConstant: videoCallSize).isActive = true
        myView.heightAnchor.constraint(equalToConstant: videoCallSize).isActive = true
        myView.isHidden = true

        setupRemoteVideoView()
        friendView.isHidden = true
    }
    
    func enableCall(participant:String) {
        setupVideoView()
        myView.isHidden = false
        friendView.isHidden = false
        roomName = Constants.officeName
        #if targetEnvironment(simulator)
            self.myView!.removeFromSuperview()
        #else
            self.startPreview()
        #endif
        self.accessToken = Constants.accessToken
        self.connect()
//        getToken {
//            print(self.accessToken)
//            self.connect()
//        }
    }
    
    func disableCall(participant:String) {
        
        myView.isHidden = true
        if let room = self.room {
            room.disconnect()
        }
    }
    
    
    func getToken(completion: @escaping () -> Void) {
        functions.httpsCallable("createToken").call(["username": currUser.userData.name,"roomName": roomName!]) { (result, error) in
            print(result)
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
            }
            if let token = result?.data as? String {
                self.accessToken = token
                completion()
            }
        }
    }
}

extension OfficeViewController {
    func startPreview() {
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)

        if (frontCamera != nil || backCamera != nil) {

            let options = CameraSourceOptions { (builder) in
                // To support building with Xcode 10.x.
                #if XCODE_1100
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                }
                #endif
            }
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(options: options, delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
            
            self.myView!.contentMode = .scaleAspectFill;
            localVideoTrack!.addRenderer(self.myView!)
            logMessage(messageText: "Video track created")

            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                let tap = UITapGestureRecognizer(target: self, action: #selector(OfficeViewController.flipCamera))
                self.myView!.addGestureRecognizer(tap)
            }

            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                } else {
                    self.myView!.shouldMirror = (captureDevice.position == .front)
                }
            }
        }
        else {
            self.logMessage(messageText:"No front or back capture device found!")
        }
    }
    
    
    func connect() {
        self.prepareLocalMedia()

        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = ConnectOptions(token: self.accessToken!) { (builder) in

            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()

            // Use the preferred audio codec
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

            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
            if let roomName = self.roomName {
                builder.roomName = roomName
            }
            
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }
    
    func setupRemoteVideoView() {
        // Creating `VideoView` programmatically
        self.friendView = VideoView(frame: CGRect.zero, delegate: self)

        self.view.insertSubview(self.friendView!, at: 0)
        self.friendView!.contentMode = .scaleAspectFill;
        
        friendView.translatesAutoresizingMaskIntoConstraints = false
        friendView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 10+videoCallSize/2).isActive = true
        friendView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        friendView.widthAnchor.constraint(equalToConstant: videoCallSize).isActive = true
        friendView.heightAnchor.constraint(equalToConstant: videoCallSize).isActive = true

    }
    
    @objc func flipCamera() {
        var newDevice: AVCaptureDevice?

        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }

            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        self.logMessage(messageText: "Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.myView!.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }
    
    func prepareLocalMedia() {

        // We will share local audio and video when we connect to the Room.

        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")

            if (localAudioTrack == nil) {
                logMessage(messageText: "Failed to create audio track")
            }
        }

        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            self.startPreview()
        }
   }
    
    func cleanupRemoteParticipant() {
        if ((self.remoteParticipant) != nil) {
            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(self.friendView!)
                self.friendView?.isHidden = true
                self.friendView?.removeFromSuperview()
                self.friendView = nil
            }
        }
        self.remoteParticipant = nil
    }

    func logMessage(messageText: String) {
        NSLog(messageText)
    }
    
    
}



// MARK:- RoomDelegate
extension OfficeViewController : RoomDelegate {
    func roomDidConnect(room: Room) {
        // At the moment, this example only supports rendering one Participant at a time.

        logMessage(messageText: "connected to room \(room.name)")
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        logMessage(messageText: "Disconnected from room \(room.name), error = \(String(describing: error))")

        self.cleanupRemoteParticipant()
        self.room = nil
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        logMessage(messageText: "Failed to connect to room with error = \(String(describing: error))")
        self.room = nil
    }

    func roomIsReconnecting(room: Room, error: Error) {
        logMessage(messageText: "Reconnecting to room \(room.name), error = \(String(describing: error))")
    }

    func roomDidReconnect(room: Room) {
        logMessage(messageText: "Reconnected to room \(room.name)")
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }
       logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        if (self.remoteParticipant == participant) {
            cleanupRemoteParticipant()
        }
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
}



// MARK:- RemoteParticipantDelegate
extension OfficeViewController : RemoteParticipantDelegate {

    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.

        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
    }

    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.

        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }

    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.

        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
    }

    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has stopped sharing the audio Track.

        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }

    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's video Track. We will start receiving the
        // remote Participant's video frames now.

        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")

        if (self.remoteParticipant == participant) {
            setupRemoteVideoView()
            videoTrack.addRenderer(self.friendView!)
        }
    }

    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.

        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")

        if (self.remoteParticipant == participant) {
            videoTrack.removeRenderer(self.friendView!)
            self.friendView?.removeFromSuperview()
            self.friendView = nil
        }

        
    }

    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.

        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }

    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.

        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }

    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
    }

    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
    }

    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }

    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }

    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }

    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
    
}

// MARK:- VideoViewDelegate
extension OfficeViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK:- CameraSourceDelegate
extension OfficeViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
    }
    
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        if (self.localVideoTrack != nil) {
            self.localVideoTrack?.isEnabled = false
        }
    }
    func cameraSourceInterruptionEnded(source: CameraSource) {
        if (self.localVideoTrack != nil) {
            self.localVideoTrack?.isEnabled = true
        }
    }
}
