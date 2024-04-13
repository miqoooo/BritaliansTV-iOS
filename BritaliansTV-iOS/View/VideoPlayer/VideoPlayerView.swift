//
//  VideoPlayerView.swift
//  BritaliansTV
//
//  Created by miqo on 12.11.23.
//

import SwiftUI
import AVKit

class PlayerVM: ObservableObject {
    var player = AVPlayer()
    var adData: AdModel? = nil
    
    private var statusObserver: NSKeyValueObservation? = nil
    private var isLoaded: Bool = false
    
    func load(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        self.player.play()
    }
    
    func reset() {
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
    }
}

struct VideoPlayerView: View {
    @EnvironmentObject var playerVM: PlayerVM
    var url: URL
    
    init(url: URL) {
        //self.url = URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!
        self.url = url
    }
    
    var body: some View {
        PlayerViewRepresentabl(player: playerVM.player, adData: playerVM.adData!)
            .onAppear {
                self.playerVM.load(url: url)
            }
            .onAppear {
                AppDelegate.orientationLock = .landscape
            }.onDisappear {
                AppDelegate.orientationLock = .portrait
            }
            .edgesIgnoringSafeArea(.all)
    }
}

