//
//  HapticManager.swift
//  Financio
//
//  Created by Ariane on 21/05/2026.
//

import SwiftUI

struct HapticManager {
    
    /// A subtle, physical "click" (Great for toggles, pickers, or small buttons)
    static func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// A distinct vibration sequence (Great for Success, Warning, or Error events)
    static func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
