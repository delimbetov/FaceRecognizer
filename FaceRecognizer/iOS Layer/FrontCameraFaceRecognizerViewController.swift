//
//  FrontCameraFaceRecognizerViewController.swift
//  FaceRecognizer
//
//  Created by Кирилл Делимбетов on 22.03.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

class FrontCameraFaceRecognizerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
	
	// MARK: Outlets
	@IBOutlet weak var imageView: UIImageView!
	
	// MARK: public interface
	// checks if permissions needed by app are acquired
	func checkPermission() {
		checkCameraAuthorization { [weak weakSelf = self] authorized in
			if authorized {
				debugPrint("authorized")
				
				if weakSelf?.captureSession.isRunning == false {
					weakSelf?.startCamera()
				} else {
					debugPrint("capture session is running")
				}
			} else {
				//that's not the kind of program where you might deny camera access and expect it to work somehow
				weakSelf?.alertUserAboutLackOfPermission()
			}
		}
	}
	
	// MARK: UIViewController
	override func viewDidAppear(_ animated: Bool) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			debugPrint("Couldn't set itself to appdelegate")
			return
		}
		
		appDelegate.rootViewController = self
		statusBarHidden = true
	}
	
	override var prefersStatusBarHidden: Bool {
		return statusBarHidden
	}
	
	// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
	// .global queue
	func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
			debugPrint("Couldn't get pixel buffer")
			return
		}
		
		guard let recognizer = faceRecognizer else {
			debugPrint("recognizer is not properly instantiated")
			return
		}
		
		// get UIImage from pixelBuffer
		let cameraImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
		guard let cgImage = convertCIImageToCGImage(inputImage: cameraImage) else {
			debugPrint("couldn't convert CIImage to CGImage")
			return
		}
		let image = UIImage(cgImage: cgImage)
		
		// get UIImage with recognized faces
		let imageWithRecognizedFaces = recognizer.recognizeFaces(on: image)
		
		// set UIImage to imageView on main thread
		DispatchQueue.main.async {
			self.imageView.image = imageWithRecognizedFaces
		}
	}
	
	// MARK: Private
	// alert about lack of camera permission and let user jump to settings to fix it
	private func alertUserAboutLackOfPermission() {
		let alertController = UIAlertController(title: "No camera permission", message: "To recognize faces App needs access to camera. You may go to Settings/FaceRecognizer to allow it", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
		let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { (_) -> Void in
			guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
				debugPrint("Chose to go to settings")
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
					debugPrint("Settings opened: \(success)") // Prints true
				})
			}
		}
		
		alertController.addAction(settingsAction)
		present(alertController, animated: true, completion: nil)
	}
	
	private func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
		switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
		case .authorized:
			//The user has previously granted access to the camera.
			completionHandler(true)
			
		case .notDetermined:
			// The user has not yet been presented with the option to grant video access so request access.
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { success in
				completionHandler(success)
			})
			
		case .denied:
			// The user has previously denied access.
			completionHandler(false)
			
		case .restricted:
			// The user doesn't have the authority to request access e.g. parental restriction.
			completionHandler(false)
		}
	}
	
	private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
		let context = CIContext(options: nil)
		
		return context.createCGImage(inputImage, from: inputImage.extent)
	}
	
	// configures capture session and starts it
	private func startCamera() {
		debugPrint("startCamera");
		//configure input
		guard let frontCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) else {
			debugPrint("Couldn't get frontCamera. This is iOS 10 based API and all ios 10 devices have front camera. It means no permissions")
			return
		}
		
		guard let videoInput = try? AVCaptureDeviceInput(device: frontCamera) else {
			debugPrint("Unable to obtain video input for default camera.")
			return
		}
		
		guard captureSession.canAddInput(videoInput) else {
			debugPrint("Can't add videoInput")
			return
		}
		
		//configure output
		//video output
		let videoOutput = AVCaptureVideoDataOutput()
		
		videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .default))
		
		guard captureSession.canAddOutput(videoOutput) else {
			debugPrint("Can't add videoOutput")
			return
		}
		
		// Configure the session.
		captureSession.beginConfiguration()
		captureSession.sessionPreset = AVCaptureSessionPresetHigh
		captureSession.addInput(videoInput)
		captureSession.addOutput(videoOutput)
		videoOutput.connection(withMediaType: AVMediaTypeVideo).videoOrientation = .portrait
		videoOutput.connection(withMediaType: AVMediaTypeVideo).isVideoMirrored = true
		captureSession.commitConfiguration()
		
		// start session
		captureSession.startRunning()
	}
	
	// MARK: Private data
	private struct Constant {
		static let statusBarHidingAnimateDuration = 2.0
	}
	
	private let captureSession = AVCaptureSession()
	private let faceRecognizer = OpenCVRecognizer()
	private var statusBarHidden = false {
		didSet {
			UIView.animate(withDuration: Constant.statusBarHidingAnimateDuration) { [weak weakSelf = self] in
				weakSelf?.setNeedsStatusBarAppearanceUpdate()
			}
		}
	}
}
