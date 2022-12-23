//
//  DubDubGrubApp.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 21.12.2022.
//

import SwiftUI

@main
struct DubDubGrubApp: App {
    let locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(locationManager)
        }
    }
}
