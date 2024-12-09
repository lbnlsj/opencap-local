//
//  CameraViewController.swift
//  OpenCap
//
//  Created by Nik on 05.09.2022.
//

import UIKit
import Alamofire
import SwiftUI
import SwiftMessages
import Reachability
import AVFoundation
import CoreMotion

final class CameraViewController: UIViewController {
    weak var timer: Timer?

    let cameraController = CameraController()
    var previewView: UIView!
    var previousStatus = "ready"
    var squareView: UXQRMiddleSquareView?
    var instructionView: InstructionView?
    var bottomActivityView: BottomActivityView?
    let reachability = try! Reachability()
    var connectionErrorView: MessageView?
    var portraitLockWarningView: MessageView?
    var progressDownload: UIProgressView = UIProgressView(progressViewStyle: .default)
    let uploadingVideoAlertController = UIAlertController(title: " ", message: " ", preferredStyle: .alert)

    var currentInstructionType: InstructionTextType = .scan
    var isScannedQR = false
    var shouldPresentInstructionView = true
    var motionManager: CMMotionManager!
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: self.cameraController.captureSession)
    }
    
    override func viewDidLoad() {
        addCoreMotion()
        cameraController.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true

        let localURL = URL(fileURLWithPath: "file.txt")
        try? "Some string".write(to: localURL, atomically: true, encoding: .utf8)
                
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                      repeats: true,
                                     block: { [weak self] timer in
            guard let sesssionStatusUrl = self?.cameraController.sessionStatusUrl,
                  let url = URL(string: sesssionStatusUrl) else { return }
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                //print(String(data: data, encoding: .utf8)!)
                //print(String(self!.cameraController.sessionStatusUrl))
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dictionary = json as? [String: Any] {
                    
                    if let video = dictionary["url"] as? String {
                        self!.cameraController.videoUrlNew = video
                    }
                    if let video = dictionary["video"] as? String {
                        self!.cameraController.videoLink = video
                    }
                    if let lenspos = dictionary["lenspos"] as? Float {
                        self!.cameraController.lensPosition = lenspos
                    }
                    if let trial = dictionary["trial"] as? String {
                        self!.cameraController.trialLink = trial
                    }
                    if let status = dictionary["status"] as? String {
                        print(status)
                        if (self!.previousStatus != status && status == "recording")
                        {
                            var frameRate = Int32(60)
                            if let desiredFrameRate = dictionary["framerate"] as? Int32 {
                                frameRate = desiredFrameRate
                            }
                            self?.cameraController.recordVideo(frameRate: frameRate)
                        }
                        if (self!.previousStatus != status && status == "uploading")
                        {
                            self?.cameraController.stopRecording()
                        }
                        if self?.previousStatus == "uploading" && status == "ready" {
                            print("Canceled or finished uploading!")
                            self?.cameraController.stopUploadingVideo()
                        }
                        self?.previousStatus = status
                    }
                    if let newSession = dictionary["newSessionURL"] as? String {
                        self?.cameraController.sessionStatusUrl = newSession + "?device_id=" + UIDevice.current.identifierForVendor!.uuidString
                        print("Switched session to" + String(self!.cameraController.sessionStatusUrl))
                    }
                    
                }
                // if no "status" continue
                // if data["status"] == "recording" then start recording
                // if data["status"] == "uploading" then stop recording and submit the video
            }
            
            task.resume()
        })

        view.backgroundColor = appBlue
//        previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

        previewView = Device.IS_IPHONE ? UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)) :
                                       UIView(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 160))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)
        UIView.setAnimationsEnabled(false)

        prepareCamera()
        addInstructionView(for: .portrait)
        addBottomActivityView()
        addSquareView()
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(rotated),
                                            name: UIDevice.orientationDidChangeNotification,
                                            object: nil)
        
        // Add observer for AVCaptureSession runtime errors
        NotificationCenter.default.addObserver(forName: .AVCaptureSessionRuntimeError, object: self.cameraController.captureSession, queue: nil) { notification in
            // Handle the runtime error
            if let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError {
                let errorMessage = "AVCaptureSession runtime error: \(error.localizedDescription)"
                print(errorMessage)
                self.presentErrorAlert(with: errorMessage)
//                FirebaseErrorLogger.shared.logError(with: .captureSession, message: errorMessage)
            }
        }
        
   
    }
    
    func presentUploadingAlert() {
        DispatchQueue.main.async {
            self.progressDownload.setProgress(0, animated: true)
            self.progressDownload.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
            self.progressDownload.progressTintColor = appBlue
            self.uploadingVideoAlertController.view.addSubview(self.progressDownload)
            self.uploadingVideoAlertController.title = "Uploading video 0%"
            self.uploadingVideoAlertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.black
            self.uploadingVideoAlertController.view.tintColor = UIColor.white
            self.present(self.uploadingVideoAlertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func rotated() {
        Device.currentDeviceOrientation = UIDevice.current.orientation
        switch UIDevice.current.orientation {
        case .portrait:
            print("portrait")
            if shouldPresentInstructionView {
                self.instructionView?.removeFromSuperview()
                addInstructionView(for: .portrait)
                updateInstructionViewText(for: .portrait)
                removeInstructionView()
            }

            removeBottomActivityView()
            addBottomActivityView()
        case .portraitUpsideDown:
            print("portraitUpsideDown")
            if shouldPresentInstructionView {
                self.instructionView?.removeFromSuperview()
                addInstructionView(for: .portraitUpsideDown)
                updateInstructionViewText(for: .portraitUpsideDown)
                removeInstructionView()
            }
            removeBottomActivityView()
            addBottomActivityView()
            bottomActivityView?.logoImageView?.rotate(angle: 180)
            bottomActivityView?.actionsButton?.rotate(angle: 180)
        case .landscapeLeft:
            print("landscapeLeft")
            if shouldPresentInstructionView {
                self.instructionView?.removeFromSuperview()
                addInstructionView(for: .landscapeLeft)
                updateInstructionViewText(for: .landscapeLeft)
                removeInstructionView()
            }
            removeBottomActivityView()
            addBottomActivityView()
            bottomActivityView?.logoImageView?.rotate(angle: 90)
            bottomActivityView?.actionsButton?.rotate(angle: 90)
        case .landscapeRight:
            print("landscapeRight")
            if shouldPresentInstructionView {
                self.instructionView?.removeFromSuperview()
                addInstructionView(for: .landscapeRight)
                updateInstructionViewText(for: .landscapeRight)
                removeInstructionView()
            }
            removeBottomActivityView()
            addBottomActivityView()
            bottomActivityView?.logoImageView?.rotate(angle: -90)
            bottomActivityView?.actionsButton?.rotate(angle: -90)
        default :
            return
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNetworkObserver()
    }
    
    func setupNetworkObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
          do{
            try reachability.startNotifier()
          }catch{
            print("could not start reachability notifier")
          }
    }
    
    func prepareCamera() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:
          print("Reachable via WiFi")
          self.dismissSwiftMessage(with: .noInternetConnection)
      case .cellular:
          print("Reachable via Cellular")
          self.dismissSwiftMessage(with: .noInternetConnection)
      case .unavailable:
          self.presentNoInternetConnectionError()
        print("Network not reachable")
      }
    }
    
    func presentNoInternetConnectionError() {
        connectionErrorView = MessageView.viewFromNib(layout: .cardView)
        connectionErrorView?.id = AlertMessagesIds.noInternetConnection.rawValue
        guard let connectionErrorView = connectionErrorView else {
            return
        }

        connectionErrorView.configureTheme(.error)
        connectionErrorView.button?.isHidden = true
        connectionErrorView.configureDropShadow()
        connectionErrorView.configureContent(title: "", body: "Device no longer connected to server, verify your internet connection")
        connectionErrorView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (connectionErrorView.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: connectionErrorView)
    }
    
    func presentPortraitLockWarningMessage() {
        portraitLockWarningView = MessageView.viewFromNib(layout: .cardView)
        portraitLockWarningView?.id = AlertMessagesIds.portraitLockWarning.rawValue
        guard let portraitLockWarningView = portraitLockWarningView else {
            return
        }
        
        portraitLockWarningView.configureTheme(.warning)
        portraitLockWarningView.button?.isHidden = true
        portraitLockWarningView.configureDropShadow()
        portraitLockWarningView.configureContent(title: "", body: "Warning: turn off Portrait Orientation Lock on your device to record a video with the phone rotated.")
        portraitLockWarningView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (portraitLockWarningView.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: portraitLockWarningView)
    }
    
    func dismissSwiftMessage(with id: AlertMessagesIds) {
         SwiftMessages.hide(id: id.rawValue)
    }
    
    func addSquareView() {
        squareView = UXQRMiddleSquareView(frame: CGRect.zero)
        guard let squareView = squareView else {
            return
        }
        squareView.center = self.view.center
        squareView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin]

        self.view.addSubview(squareView)
    }
    
    func removeSquareView() {
        squareView?.removeFromSuperview()
    }
    
    func addInstructionView(for orientation: UIDeviceOrientation) {
        switch UIDevice.current.orientation {
        case .portrait:
            instructionView = InstructionView(frame: CGRect.init(x: self.view.frame.width * 0.1, y: 84, width: self.view.frame.width * 0.8, height: self.view.frame.height / 5))
        case .portraitUpsideDown:
            print("portraitUpsideDown")
            instructionView = InstructionView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 5))
        case .landscapeLeft:
            print("landscapeLeft")
            let div: CGFloat = Device.IS_IPHONE ? 6 : 6
            instructionView = InstructionView(frame: CGRect.init(x: 200, y: self.view.frame.midY, width: self.view.frame.height * 0.7, height: self.view.frame.height*0.5 / div), label: true)
            instructionView?.center = CGPoint(x: self.view.frame.maxX-50, y: self.view.frame.midY)
            instructionView?.rotate(angle: 90)
            instructionView?.addLabel()
        case .landscapeRight:
            let div: CGFloat = Device.IS_IPHONE ? 6 : 6
            instructionView = InstructionView(frame: CGRect.init(x: 200, y: self.view.frame.midY, width: self.view.frame.height * 0.7, height: self.view.frame.height*0.5 / div), label: true)
            instructionView?.center = CGPoint(x: self.view.frame.minX+50, y: self.view.frame.midY)
            instructionView?.rotate(angle: -90)
            instructionView?.addLabel()
            print("landscapeRight")
        default :
            instructionView = InstructionView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 5))
        }
        instructionView!.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleTopMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin]

        guard let instructionView = instructionView else {
            return
        }
        self.view.addSubview(instructionView)
    }
    
    func removeInstructionView() {
        guard currentInstructionType != .scan  else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.instructionView?.removeFromSuperview()
            self.shouldPresentInstructionView = false
        }
    }
    
    func updateInstructionViewText(for orientation: UIDeviceOrientation? = nil) {
        if currentInstructionType == .scan {
            instructionView?.titleLabel?.text = orientation == .landscapeLeft || orientation == .landscapeRight ? InstructionTextType.scanFullText.rawValue : InstructionTextType.scan.rawValue
        } else {
            instructionView?.titleLabel?.text = currentInstructionType.rawValue
        }
    }
    
    func addBottomActivityView() {
        bottomActivityView = BottomActivityView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-100, width: UIScreen.main.bounds.size.width, height: 100))

        bottomActivityView?.delegate = self
        
        guard let bottomActivityView = bottomActivityView else {
            return
        }
        self.view.addSubview(bottomActivityView)
    }
    
    func removeBottomActivityView() {
        bottomActivityView?.removeFromSuperview()
    }
    
    func presentErrorAlert(with message: String?) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CameraViewController: CameraControllerDelegate {
    func uploadingVideoStarted() {
        presentUploadingAlert()
    }
    
    func uploadingVideoCanceled() {
        DispatchQueue.main.async {
            self.uploadingVideoAlertController.dismiss(animated: true)
        }
    }
    
    func updateUploadingProgress(progress: Double) {
        DispatchQueue.main.async {
            let progressString = String(format: "%.0f", progress * 100)
            self.uploadingVideoAlertController.title = "Uploading video \(progressString)%"
            self.progressDownload.setProgress(Float(progress), animated: true)
        }
    }
    
    func didFinishUploadingVideo() {
        DispatchQueue.main.async {
            self.uploadingVideoAlertController.dismiss(animated: true)
        }
    }
    
    func didScanQRCode() {
        currentInstructionType = .mountDevice
        updateInstructionViewText()
        removeSquareView()
        removeInstructionView()
    }
    
    func didFailedUploadingVideo(with message: String?) {
        uploadingVideoAlertController.dismiss(animated: true)
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                alert.dismiss(animated: true, completion: nil)
            }
            
        }
    }
}

extension CameraViewController: BottomActivityViewDelegate {
    func didTapActionButton() {
        let alert = UIAlertController(title: "", message: "Please select an option", preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
           
           alert.addAction(UIAlertAction(title: "Start a new session", style: .default , handler:{ (UIAlertAction)in
               print("User click Start a new session")
               DispatchQueue.main.async {
                   self.cameraController.sessionStatusUrl = "https://api.opencap.ai"
                   self.cameraController.setAutoFocus()
                   self.timer?.invalidate()
                   
                   let viewController = CameraViewController()
                   viewController.modalPresentationStyle = .fullScreen
                   self.present(viewController, animated: true)
               }
           }))
        
           alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
               print("User click Dismiss button")
           }))
        
           self.present(alert, animated: true, completion: {
               print("completion block")
           })
    }
}

extension CameraViewController {

    func updateVideoOrientation(orientaion: AVCaptureVideoOrientation) {
        guard let videoPreviewLayer = self.cameraController.previewLayer else {
                return
            }
            guard videoPreviewLayer.connection!.isVideoOrientationSupported else {
                print("isVideoOrientationSupported is false")
                return
            }
            let videoOrientation: AVCaptureVideoOrientation = orientaion
            videoPreviewLayer.frame = view.layer.frame
            videoPreviewLayer.connection?.videoOrientation = videoOrientation
            videoPreviewLayer.removeAllAnimations()
    }
    
    func addCoreMotion() {
        let splitAngle:Double = 0.75
        let updateTimer:TimeInterval = 2

        motionManager = CMMotionManager()
        motionManager?.gyroUpdateInterval = updateTimer
        motionManager?.accelerometerUpdateInterval = updateTimer

        var orientationLast    = UIInterfaceOrientation(rawValue: 0)!

        motionManager?.startAccelerometerUpdates(to: (OperationQueue.current)!, withHandler: {
            (acceleroMeterData, error) -> Void in
            if error == nil {

                let acceleration = (acceleroMeterData?.acceleration)!
                var orientationNew = UIInterfaceOrientation(rawValue: 0)!

                if acceleration.x >= splitAngle {
                    orientationNew = .landscapeLeft
                }
                else if acceleration.x <= -(splitAngle) {
                    orientationNew = .landscapeRight
                }
                else if acceleration.y <= -(splitAngle) {
                    orientationNew = .portrait
                }
                else if acceleration.y >= splitAngle {
                    orientationNew = .portraitUpsideDown
                }

                if orientationNew != orientationLast && orientationNew != .unknown{
                    orientationLast = orientationNew
                    self.deviceOrientationChanged(orinetation: orientationNew)
                }
            }
            else {
                print("error : \(error!)")
            }
        })
    }
    
    func deviceOrientationChanged(orinetation: UIInterfaceOrientation) {
        if orinetation.isLandscape && UIDevice.current.orientation.isPortrait {
            presentPortraitLockWarningMessage()
        } else {
            dismissSwiftMessage(with: .portraitLockWarning)
        }
     }
}



