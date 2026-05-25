//
//  NotificationManager.swift
//  Financio
//
//  Created by Ariane on 16/05/2026.
//

import Foundation
import UserNotifications

@Observable
class NotificationManager {
    
    // A shared instance so the whole app uses the same manager
    static let shared = NotificationManager()
    
    // Tracks whether the user has given us permission
    var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // 1. THE PERMISSION GATE
    // Asks iOS to pop up the "Financio would like to send you notifications" alert.
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        // We are asking for permission to show alerts, play sounds, and update the app badge
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Checks if the user previously gave permission (e.g., when the app launches)
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // 2. THE SCHEDULING ENGINE
    // Takes a recurring transaction and schedules an iOS alert for its due date.
    func scheduleNotification(for recurring: RecurringTransaction) {
        guard isAuthorized else { return }
        
        // Step A: Describe what the notification will look like
        let content = UNMutableNotificationContent()
        content.title = "Payment Due: \(recurring.title)"
        
        // Format the amount cleanly
        let formattedAmount = String(format: "$%.2f", recurring.amount) // We'll simplify currency for the engine
        content.body = "Your \(recurring.frequency.rawValue.lowercased()) transaction of \(formattedAmount) is scheduled for today."
        content.sound = .default
        
        // Step B: Define exactly WHEN it should trigger.
        // We will trigger it at 9:00 AM on the `nextDate`.
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: recurring.nextDate)
        dateComponents.hour = 9 // 9 AM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Step C: Package it into a request and hand it to iOS
        // We use the transaction's ID as the identifier so we can cancel it later if needed!
        let request = UNNotificationRequest(
            identifier: recurring.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // 3. THE CLEANUP ENGINE
    // If the user deletes or pauses a recurring rule, we must cancel its pending notification.
    func cancelNotification(for recurring: RecurringTransaction) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [recurring.id.uuidString])
    }
}
