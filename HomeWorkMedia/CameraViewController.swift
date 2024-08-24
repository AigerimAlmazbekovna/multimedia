//
//  CameraViewController.swift
//  HomeWorkMedia
//
//  Created by Айгерим on 24.08.2024.
//


    import UIKit
    import AVFoundation

    final class CameraViewController: UIViewController {
        // Сессия
        private var session: AVCaptureSession!
        // Устройство захвата видео сигнала
        private var frontCamera: AVCaptureDevice!
        // Входные данные
        private var input: AVCaptureDeviceInput!
        // Превью входных данных после конвертации в нужный формат
        private var previewLayer: AVCaptureVideoPreviewLayer!
        // Готовые выходные данные
        private var output: AVCaptureVideoDataOutput!
        
        private var isPhotoTaken = false
        
        private lazy var captureImageButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .white
            button.tintColor = .white
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Camera", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            return button
        }()
        
        private lazy var captureImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            makeLayout()
            customizeView()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            checkPermission()
            startSession()
        }
        
        private func checkPermission() {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { success in
                        print(success)
                    }
                case .restricted:
                    print("restricted")
                case .denied:
                    print("denied")
                case .authorized:
                    print("authorized")
            }
        }
        
        private func startSession() {
            session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = .photo
            configureInputs()
            configurePreviews()
            configureOutputs()
            session.commitConfiguration()
            session.startRunning()
        }
        
        private func configureInputs() {
    //        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            // builtInDualWideAngleCamera - 2 камеры
            // builtInTripleCamera - 3 камеры
            frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            
            do {
                input = try AVCaptureDeviceInput(device: frontCamera)
                session.addInput(input)
            } catch {
                print("Error")
            }
        }
        
        // Отображаем входной видеопоток данных на preview layer
        private func configurePreviews() {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspect
            view.layer.insertSublayer(previewLayer, at: 0)
            previewLayer.frame = view.layer.frame
        }
        
        // входные данные -> делегату
        private func configureOutputs() {
            output = AVCaptureVideoDataOutput()
            // чтобы не загружать главный поток, создаем другую очередь
            let queue = DispatchQueue(label: "video", qos: .userInitiated)
            output.setSampleBufferDelegate(self, queue: queue)
            session.addOutput(output)
            output.connections.first?.videoOrientation = .portrait
        }
        
        private func customizeView() {
            view.backgroundColor = .black
        }
        
        private func makeLayout() {
            view.addSubview(captureImageButton)
            view.addSubview(captureImageView)
            
            NSLayoutConstraint.activate([
                captureImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                captureImageButton.heightAnchor.constraint(equalToConstant: 50),
                captureImageButton.widthAnchor.constraint(equalToConstant: 50),
                captureImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            
            NSLayoutConstraint.activate([
                captureImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                captureImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
                captureImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
                captureImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                captureImageView.heightAnchor.constraint(equalToConstant: 150)
            ])
        }
        
        @objc
        func buttonAction() {
            isPhotoTaken = true
        }
        
    }

    extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard isPhotoTaken,
                  let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvImageBuffer: buffer)
            let image = UIImage(ciImage: ciImage)
            DispatchQueue.main.async {
                self.captureImageView.image = image
                self.isPhotoTaken = false
            }
        }
    }
