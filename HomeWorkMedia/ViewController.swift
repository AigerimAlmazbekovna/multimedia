//
//  ViewController.swift
//  HomeWorkMedia
//
//  Created by Айгерим on 23.08.2024.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    private var audioPlayer: AVAudioPlayer!
    
    private let systemSounds: [String : SystemSoundID] = ["SMSReceived" : 1003, "CalendarAlert" : 1005, "MailReceived" : 1000, "LowPower" : 1006]
    
    private var counter = 0
    private let videoURL: URL = {
        let path = Bundle.main.path(forResource: "trailer", ofType: "mp4")!
        return URL(filePath: path)
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Аили - Сильная Девочка.mp3"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "playBtnImage"), for: .normal)
        btn.addTarget(self, action: #selector(tapOnPlay), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var showCamerBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Камера", for: .normal)
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(tapOnCamera), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioPlayer()
        makeLayout()
    }
    
    // MARK: - I Play music
    // Обращаемся по адресу нахождения аудиофайла
    private func setupAudioPlayer() {
        guard let musicURL = Bundle.main.url(forResource: "Аили - Сильная Девочка.mp3", withExtension: "mp3") else { return }
        // do потому что конструкция метода contentsOf может вернуть ошибку
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: musicURL)
            setupAudioSession()
        } catch {
            print("Error")
        }
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Error")
        }
    }
    
    private func playMusic() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            playBtn.setImage(UIImage(named: "playBtnImage"), for: .normal)
        } else {
            audioPlayer.play()
            playBtn.setImage(UIImage(named: "pauseBtnImage"), for: .normal)
        }
    }
    
    // MARK: - II Play system sounds
    private func playSystemSounds() {
        let currentSoundID = Array(systemSounds.values)[counter]
        let currentSoundName = Array(systemSounds.keys)[counter]
        AudioServicesPlaySystemSound(currentSoundID)
        nameLabel.text = currentSoundName
        
        if counter == systemSounds.count - 1 {
            counter = 0
        } else {
            counter += 1
        }
    }
    
    // MARK: - III Play video
    
    private func createVideoPlayer() {
        let player = AVPlayer(url: videoURL)
        let controller = AVPlayerViewController()
        controller.player = player
//        present(controller, animated: true)
        // Для запуска видео сразу
        present(controller, animated: true) {
            player.play()
        }
    }
    
    // MARK: - IV Доступ к микрофону
    private func audioPermission() {
        // Нужен еще пермишн прописать в info
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Доступ разрешен")
            } else {
                print("Доступ запрещен")
            }
        }
    }
    
    // для Камеры
    // AVCaptureDevice
    
    // для Галлереи
    // PHPhotoLibrary
    
    // Контакты
    // CNContactStore
    
    // Локации
    // CLLocationManager
    
    // MARK: - Action
    @objc
    private func tapOnPlay() {
//        playMusic()
//        playSystemSounds()
//        createVideoPlayer()
        audioPermission()
    }
    
    @objc
    private func tapOnCamera() {
        let vc = CameraViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    

    private func makeLayout() {
        view.addSubview(nameLabel)
        view.addSubview(playBtn)
        view.addSubview(showCamerBtn)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            playBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playBtn.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40),
            playBtn.heightAnchor.constraint(equalToConstant: 60),
            playBtn.widthAnchor.constraint(equalToConstant: 60),
            
            showCamerBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            showCamerBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

