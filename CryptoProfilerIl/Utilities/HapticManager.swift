//
//  HapticManager.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import Foundation
import SwiftUI

class HapticManager {
    static private let generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
