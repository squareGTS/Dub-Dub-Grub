//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 10.01.2023.
//

import SwiftUI

extension AppTabView {
    
    final class AppTabViewModel: ObservableObject {
        @Published var isShowingOnboardView = false
        @AppStorage("hasSeenOnboardView") var hasSeenOnboardView = false {
            didSet { isShowingOnboardView = hasSeenOnboardView }
        }

        let kHasSeenOnboardView = "hasSeenOnboardView"
        
        func checkIfHasSeenOnboarding() {
            if !hasSeenOnboardView { hasSeenOnboardView = true }
        }
    }
}
