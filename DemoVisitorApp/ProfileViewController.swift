//
//  ProfileViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 17/04/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import CropViewController
import AVFoundation
import Kingfisher
class ProfileViewController: BaseviewController, UINavigationControllerDelegate {
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var canvasImage: UIImageView!
    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    var format : DateFormatter!
    
    @IBOutlet weak var doneProfileButton: UIButton!
    @IBOutlet weak var takeProfileButton: UIButton!
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput : AVCaptureStillImageOutput?
    var videoConnection : AVCaptureConnection? // find video connection
    
    var imageOrientation: UIImageOrientation?
    
    var startTime = TimeInterval()
    var timer = Timer()
    var snapTime:Double = 5
    var takingPhoto = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasImage.layer.borderWidth = 1
        canvasImage.layer.masksToBounds = false
        canvasImage.layer.borderColor = UIColor.white.cgColor
        canvasImage.layer.cornerRadius = canvasImage.frame.height/2
        canvasImage.clipsToBounds = true
        
        cameraView.layer.borderWidth = 1
        cameraView.layer.masksToBounds = false
        cameraView.layer.borderColor = UIColor.white.cgColor
        cameraView.layer.cornerRadius = canvasImage.frame.height/2
        cameraView.clipsToBounds = true
        
        self.countdown.isHidden = true
        
        self.takeProfileButton.isHidden = true
        self.doneProfileButton.isHidden = true
        
        
        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            
            if activationDetails.logoURL != "" {
                let url = URL(string: activationDetails.logoURL!)
                ImageCache.default.removeImage(forKey: "logoKey")
                let resource = ImageResource(downloadURL: url!, cacheKey: "logoKey")
                companyLogo.kf.setImage(with: resource)
            }else {
                ImageCache.default.removeImage(forKey: "logoKey")
                companyLogo.image = nil
            }
            self.view.backgroundColor = activationDetails.appBackgroundColor()
            
        }
        
        self.setupCam()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.setRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "thankyouSegue" {
            let theDestination = (segue.destination as! ThankyouViewController)
            let jsonData = sender as!  JSON
            theDestination.thankYorResponse = jsonData
        }
    }
    
    @IBAction func retakeButtonClick(_ sender: Any) {
        self.takingPhoto = false
        self.cameraView.isHidden = false
        self.canvasImage.isHidden = true
        self.clickProfilePicture()
        
    }
    
    @IBAction func doneButtonClick(_ sender: Any) {
        self.doneProfileButton.isHidden = true
        self.takeProfileButton.isHidden = true
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        
        var loginDict = [String: Any]()
        
        var deviceID = ""
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            deviceID = deviceInfo.deviceUniqueId!
            loginDict = ["a":"save-visitor" ,
                         "deviceid":deviceInfo.deviceUniqueId!,
                         "formdata": VisitorsDetailsManager.shared.finalUserData]
            
        }
        
        DataManager.postUserData(userDetailDict: loginDict, deviceID: deviceID, closure: {Result in
            
            switch Result {
            case .success(let userData):
                
                print(userData)
                
                if userData["response"]["status"].stringValue == VisitorError.resposeCode105.rawValue {
                    self.performSegue(withIdentifier: "thankyouSegue", sender: userData)
                }
                
                break
            case .failure(let errorMessage):
                
                print(errorMessage)
                
                break
            }
        })
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            DispatchQueue.main.async {
                self.clickProfilePicture()
            }
            
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                    
                    DispatchQueue.main.async {
                        self.clickProfilePicture()
                    }
                    
                } else {
                    //access denied
                }
            })
        }
        
        
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func clickProfilePicture() {
        
        self.takeProfileButton.isHidden = true
        self.doneProfileButton.isHidden = true
        
        self.countdown.isHidden = false
        if self.takingPhoto {
            return
        }
        
        self.takingPhoto = true
        self.countdown.alpha = 0.6
        
        let aSelector : Selector = #selector(ProfileViewController.updateTime)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        self.startTime = Date.timeIntervalSinceReferenceDate
        self.countdown.text = "5"
    }
    
    
    // Timer for photo click
    @objc func updateTime() {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        var elapsedTime = currentTime - startTime
        let seconds = snapTime - elapsedTime
        
        if seconds > 0 {
            
            elapsedTime -= TimeInterval(seconds)
            self.countdown.isHidden = false
            self.countdown.text = "\(Int(seconds+1))"
            
        } else {
            
            self.countdown.isHidden = true
            timer.invalidate()
            
            
            // we are ready to save some photos
            // setup still OutPut to save
            if let stillOutput = self.stillImageOutput {
                
                // we do this on another thread so we don't hang the UI
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    
                    for connection in stillOutput.connections {
                        // find a matching input port
                        for port in (connection as AnyObject).inputPorts! {
                            // and matching type
                            if (port as AnyObject).mediaType == AVMediaType.video {
                                self.videoConnection = connection as? AVCaptureConnection
                                break
                            }
                        }
                        if self.videoConnection != nil {
                            break // for connection
                        }
                    }
                    
                    if self.videoConnection != nil {
                        
                        // found the video connection, let's get the image
                        let _ = stillOutput.connection(with: AVMediaType.video)
                        stillOutput.captureStillImageAsynchronously(from: self.videoConnection!) {
                            (imageSampleBuffer:CMSampleBuffer!, _) in
                            
                            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
//                            self.didTakePhoto(imageData!)
                            self.cameraView.isHidden = true
                            self.canvasImage.isHidden = false
//                            self.canvasImage.image = UIImage(data: imageData!)
                            
                            if let image = UIImage(data: imageData!) {
                                
                                if let orientation = self.imageOrientation {
                                    
                                    let updatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: orientation)
                                    
                                    self.canvasImage.image = updatedImage
                                    self.takeProfileButton.isHidden = false
                                    self.doneProfileButton.isHidden = false
                                    
//                                    UIImageWriteToSavedPhotosAlbum(updatedImage, nil, nil, nil)
                                    
                                    
                                    
                                    if let imageData = updatedImage.jpeg(.lowest) {
                                        let profileBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                                        
                                        VisitorsDetailsManager.shared.finalUserData.updateValue(profileBase64, forKey: "profileBase64")
                                    }
                                    
                                    
                                    
                                } else {
                                    
                                    self.canvasImage.image = image
                                    if let imageData = image.jpeg(.lowest) {
                                        let profileBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                                        
                                        VisitorsDetailsManager.shared.finalUserData.updateValue(profileBase64, forKey: "profileBase64")
                                    }
//                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                }
                                
                                self.canvasImage.contentMode = .scaleAspectFill
                                
                                
                            }
                            
                            
                            
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    //Update clock every second
    @objc func updateClock() {
        let now = NSDate()
        
        self.dateTimeLabel.text =  format.string(from: now as Date)
    }
    
    func setupCam() {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        if let availabeDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone,
                                                                                .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices as? [AVCaptureDevice] {
            
            
            for device in availabeDevices {
                captureDevice = device as AVCaptureDevice
                if captureDevice != nil {
                    print("Capture device found")
                    
                    beginSession()
                }
            }
        }
    }
    
    
    func beginSession() {
        
        configureDevice()
        stillImageOutput = AVCaptureStillImageOutput()
        let outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
        stillImageOutput!.outputSettings = outputSettings
        
        // add output to session
        if captureSession.canAddOutput(stillImageOutput!) {
            captureSession.addOutput(stillImageOutput!)
        }
        
        do {
            
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice!))
        } catch let error as NSError{
            
            print("error: \(error.localizedDescription)")
        }
        
        // create camera preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.previewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
        
        self.previewLayer?.bounds = self.cameraView.bounds
        self.cameraView.layer.addSublayer(previewLayer!)
        
        // set rotation
        self.setRotation()
        
        captureSession.startRunning()
    }
    
    // TODO: clean this
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            //device.focusMode = .Locked
            device.unlockForConfiguration()
        }
        
    }
    
    @objc func setRotation() {
        
        let device = UIDevice.current
        
        if (device.orientation == UIDeviceOrientation.landscapeLeft){
            print("landscape left")
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            imageOrientation = UIImageOrientation.downMirrored
            
        } else if (device.orientation == UIDeviceOrientation.landscapeRight){
            print("landscape right")
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            imageOrientation = UIImageOrientation.upMirrored
            
        } else if (device.orientation == UIDeviceOrientation.portrait){
            print("Portrait")
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            imageOrientation = UIImageOrientation.leftMirrored
            
        } else if (device.orientation == UIDeviceOrientation.portraitUpsideDown){
            print("Portrait UD")
            previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            imageOrientation = UIImageOrientation.rightMirrored
            
        }
    }
    
}
