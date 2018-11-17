//
//  CameraViewController.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 04/11/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
class CameraViewController: UIViewController {
    @IBOutlet weak var cameraPreview: UIView!
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize session an output variables this is necessary
        /*
        session = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        let camera = getDevice(position: .front)
        do {
            input = try AVCaptureDeviceInput(device: camera!)
        } catch let error as NSError {
            print(error)
            input = nil
        }
        if(session?.canAddInput(input!) == true){
            session?.addInput(input!)
            output?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            if(session?.canAddOutput(output!) == true){
                session?.addOutput(output!)
                previewLayer = AVCaptureVideoPreviewLayer(session: session!)
                previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                previewLayer?.frame = cameraPreview.bounds
                cameraPreview.layer.addSublayer(previewLayer!)
                session?.startRunning()
            }
        }
        
        */
        
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            let connection = videoOutput.connectionWithMediaType(AVMediaTypeVideo)
            if connection.supportsVideoOrientation {
                connection.videoOrientation = isFrontCamera ? AVCaptureVideoOrientation.LandscapeLeft : AVCaptureVideoOrientation.LandscapeRight
            }
            print("adding output")
            
        } else {
            print("Could not add front video output")
            return
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        
        
        
    }
    //Get the device (Front or Back)
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
}
