//
//  PlayerViewRepresentable.swift
//  BritaliansTV
//
//  Created by miqo on 12.11.23.
//

import UIKit
import AVKit
import SwiftUI
import AVFoundation
import GoogleInteractiveMediaAds
import Combine


struct PlayerViewRepresentabl: UIViewControllerRepresentable {
    var player: AVPlayer
    var adData: AdModel
    
    func makeUIViewController(context: Context) -> UIKitVideoPlayerViewController {
        let viewController = UIKitVideoPlayerViewController()
        viewController.player = player
        viewController.adData = adData
        //context.coordinator.startObserver()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIKitVideoPlayerViewController, context: Context) {
    }
    
    static func dismantleUIViewController(_ uiViewController: UIKitVideoPlayerViewController, coordinator: Coordinator) {
    }
}


class UIKitVideoPlayerViewController: UIViewController {
    private var playerViewController: AVPlayerViewController!
    
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var backupPlayerItem: AVPlayerItem!
    var adData: AdModel!
    
    var backupTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var remainingTime = 0
    var backupObserver: Any?
    var backupStatusObserver: NSKeyValueObservation?
    var cancellables: Set<AnyCancellable> = []
    
    var skipButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if let observer = backupObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        backupTimer.upstream.connect().cancel()
        cancellables.forEach({ $0.cancel() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black;
        setUpContentPlayer()
        setUpBackupView()
        setUpAdsLoader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.playerItem = player.currentItem!
        
        if let _ = adData.ad_url {
            requestAds()
        } else if let _ = adData.video_url {
            setUpBackupVideo()
        } else {
            playerViewController.player?.play()
        }
    }
    
    func setUpContentPlayer() {
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        showContentPlayer()
    }
    
    func showContentPlayer() {
        self.addChild(playerViewController)
        playerViewController.view.frame = self.view.bounds
        self.view.insertSubview(playerViewController.view, at: 0)
        playerViewController.didMove(toParent:self)
    }
    
    func hideContentPlayer() {
        playerViewController.willMove(toParent:nil)
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
    }
    
    func setUpBackupView() {
        skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.backgroundColor = .white
        skipButton.tintColor = .black
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(closeBackupPlayer), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.isHidden = true
        
        if let contentView = playerViewController.contentOverlayView {
            contentView.addSubview(skipButton)
            NSLayoutConstraint.activate([
                skipButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
                skipButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
                skipButton.widthAnchor.constraint(equalToConstant: 100)
            ])
        }
    }
    
    func setUpBackupVideo() {
        if let backupURL = URL(string: self.adData.video_url!) {
            self.backupPlayerItem = AVPlayerItem(url: backupURL)
            print("ad Iterval: \(adData.ad_interval!)")
            
            backupTimer
                .sink { [weak self] _ in
                    self?.updateTimer()
                }
                .store(in: &cancellables)
            
            playBackupItem()
        }
    }
    
    @objc
    func playBackupItem() {
        if player.currentItem! != backupPlayerItem {
            playerViewController.showsPlaybackControls = false
            
            print("playng backup Item \(backupPlayerItem.duration.seconds)")
            
            player.pause()
            player.replaceCurrentItem(with: backupPlayerItem)
            player.seek(to: .zero)
            
            player.play()
            self.skipButton.isHidden = false
            
            backupObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: backupPlayerItem,
                queue: nil
            ) { [weak self] _ in
                guard let self = self else { return }
                self.closeBackupPlayer()
            }
        }
    }
    
    @objc
    func closeBackupPlayer() {
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
        
        backupStatusObserver?.invalidate()
        
        skipButton.isHidden = true
        playerViewController.showsPlaybackControls = true
        remainingTime = adData.ad_interval! * 60 // 60 
    }
    
    func updateTimer() {
        if player?.rate == 1.0 {
            remainingTime -= 1
            if remainingTime <= 0 {
                playBackupItem()
            }
        } else {
            print("Player is paused. \(remainingTime)")
        }
    }
    
    func setUpAdsLoader() {
        let settings = IMASettings()
        settings.enableBackgroundPlayback = true
        settings.autoPlayAdBreaks = true
        //settings.SameAppKeyEnabled = false
        
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader.delegate = self
    }
    
    func requestAds() {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.view, viewController: self)
        let request = IMAAdsRequest(
            adTagUrl: adData.ad_url!,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
    }
}

extension UIKitVideoPlayerViewController: IMAAdsLoaderDelegate {
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        adsManager.initialize(with: nil)
        
        print("adCuePoints: \(adsManager.adCuePoints)")
        print("adPlaybackInfo: \(adsManager.adPlaybackInfo)")
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: " + (adErrorData.adError.message ?? " _ "))
        showContentPlayer()
        playerViewController.player?.play()
    }
}

extension UIKitVideoPlayerViewController: IMAAdsManagerDelegate {
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        print("AdsManager error: " + (error.message ?? " _ "))
        showContentPlayer()
        playerViewController.player?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        playerViewController.player?.pause()
        hideContentPlayer()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        showContentPlayer()
        playerViewController.player?.play()
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        print("adsManager Event type: \(event.typeString)")
        
        if event.type == IMAAdEventType.LOADED {
            adsManager.start()
        }
    }
}
