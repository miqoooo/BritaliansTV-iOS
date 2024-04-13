//
//  BritaliansTVApp.swift
//  BritaliansTV
//
//  Created by miqo on 06.11.23.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                //UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct BritaliansTVApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var playerVM = PlayerVM()
    @StateObject var appVM = ApplicationVM()
    @StateObject var mainPageVM = MainPageVM()
    @StateObject var contentVM = ContentVM()
    
    init() {
        UITabBar.appearance().barTintColor = UIColor.black
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(hex: "#0F0F1E")
                    .ignoresSafeArea(.all)
                
                MainPage()
                    .opacity(appVM.dataLoaded ? 1 : 0)
                
                SplashScreen()
                    .opacity(appVM.dataLoaded ? 0 : 1)
            }
            .animation(.default, value: appVM.dataLoaded)
            .ignoresSafeArea(.all)
            .environmentObject(appVM)
            .environmentObject(playerVM)
            .environmentObject(contentVM)
            .environmentObject(mainPageVM)
        }
    }

    
    @ViewBuilder
    func SplashScreen() -> some View {
        VStack(alignment: .center) {
            Image("appLogo")
                .resizable()
                .scaledToFit()
        }
        .padding(.horizontal, 30)
    }
}
