//
//  HapticManager.swift
//  DubDubGrub
//
//  Created by Maxim Bekmetov on 11.01.2023.
//

import UIKit

struct HapticManager {
    
    static func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
