//
//  AVCodeReader.swift
//  SiteDishBezorgApp
//
//  Created by Arjan van der Laan on 01-05-18.
//  Copyright © 2018 Arjan developing. All rights reserved.
//

import AVFoundation

/**
 - description: QR Code reader
 
Sample implementation:
 
/// De videopreview view wordt gereed gemaakt voor tonen van
/// camerabeelden, en er wordt gecheckt of er camera(toegang)
/// aanwezig is. NB. Bij het wijzigen van camera-toegang in de instellingen
/// wordt de app door iOS afgesloten (SIGKILL)
override func viewDidLoad() {
    super.viewDidLoad()
    codeReader = AVCodeReader()
    
    codeReader.prepare(onSuccess: {
        DispatchQueue.main.async {
            // self.videolayer isa private var videoLayer: CALayer!
            self.videoLayer = self.codeReader.videoPreviewLayer
            self.videoLayer.frame = self.videoPreview.bounds
            self.videoPreview.layer.addSublayer(self.videoLayer)
            self.videoPreview.setNeedsLayout()
            self.startReadingQR()
        }
    }, onFail: {
        switch self.codeReader.setupResult {
        case .notAuthorized:
            DispatchQueue.main.async {
                let changePrivatySetting = "Je hebt toegang tot de camera geweigerd. Toegang tot de camera is nodig om QR codes te scannen. Pas je privacy instellingen aan."
                let alertController = UIAlertController(title: "Oeps!", message: changePrivatySetting, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Annuleren", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Instellingen",
                                                        style: .`default`, handler: { _ in
                                                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        case .configurationFailed:
            DispatchQueue.main.async {
                let alertMsg = "Er is iets misgegaan. Camera niet gevonden."
                let alertController = UIAlertController(title: "Oeps!", message: alertMsg, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        default:
            break
        }
    })
}

/// Begint met uitlezen van de camerabeelden. Bij een succesvolle uitlezing van
/// een QR code:
/// - Controleert het of het een URL is (niet urls zijn niet toegestaan)
/// - Toont het visuele indicaties van succes en laden (van url uit qr code)
/// - Geeft het hauptic feedback waar mogelijk
/// - Wordt de data achter de url geladen (moet json en `BestellingResponse` zijn)
/// - Wordt bij succes de modal gesloten
private func startReadingQR() {
    self.codeReader.startReading(completion: { (code: String) in
        DispatchQueue.main.async {
            // Do something with code
        }
    })
}
*/
class AVCodeReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: Properties
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    private let metadataObjectsQueue = DispatchQueue(label: "metadata objects queue", attributes: [], target: nil)
    
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    var setupResult: SessionSetupResult = .success

    var videoPreviewLayer : AVCaptureVideoPreviewLayer!

    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    private var didRead: ((String) -> Void)?
    
    // MARK: AVCapture...Delegate methods
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard
            let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = readableCode.stringValue else {
                return
        }
        
        // Vibrate
        //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        stopReading()
        
        didRead?(code)
    }
    
    // MARK: Initializer
    override init() {
        super.init()
    }
    
    internal func prepare(onSuccess: (() -> Void)?, onFail: (() -> Void)?) {
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [unowned self] (granted: Bool) in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
            // TODO: what now?
        }
        
        /* AVCaptureSession.startRunning() is a blocking call which can
         take a long time. Dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
            
            if self.setupResult == .success {
                onSuccess?()
            } else {
                onFail?()
            }
        }
    }
    
    // MARK: Capture session configuration
    private func configureSession() {
        if self.setupResult != .success {
            // TODO: what now?
            return
        }
        
        captureSession.beginConfiguration()
        
        do {
            
            // Can the device handle video?
            guard let videoDevice = AVCaptureDevice.default(for: .video) else {
                    // TODO: what now?
                    print("Could not get video device")
                    setupResult = .configurationFailed
                    captureSession.commitConfiguration()
                    return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice) // --> catch
            
            guard captureSession.canAddInput(videoDeviceInput) else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                captureSession.commitConfiguration()
                return
            }
            
            captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            let captureVideoPreview = AVCaptureVideoPreviewLayer(session: captureSession)
            captureVideoPreview.videoGravity = .resizeAspectFill
            captureVideoPreview.connection!.videoOrientation = .portrait
            self.videoPreviewLayer = captureVideoPreview
            
            // Start: set metadata
            let captureMetadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(captureMetadataOutput) else {
                print("Could not add metadata output to the session")
                setupResult = .configurationFailed
                captureSession.commitConfiguration()
                return
            }
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: metadataObjectsQueue)
            captureMetadataOutput.metadataObjectTypes = [.qr]
            // End: set metadata
            
        } catch let error {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.commitConfiguration()

    }

    // MARK: Read commands
    func startReading(completion: @escaping (String) -> Void) {
        print("Start reading")
        self.didRead = completion
        captureSession.startRunning()
    }
    
    private func stopReading() {
        print("Stop reading")
        captureSession.stopRunning()
    }
}
