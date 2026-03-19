//
//  NotificationService.swift
//  Hair AI
//

import UserNotifications
import SwiftUI
import Combine

struct NotificationSetting: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String
    var isEnabled: Bool
    let scheduleFn: () -> Void
}

class NotificationService: ObservableObject {

    static let shared = NotificationService()

    @AppStorage("notif_water")       var notifWater      = true
    @AppStorage("notif_sleep")       var notifSleep      = true
    @AppStorage("notif_morning")     var notifMorning    = true
    @AppStorage("notif_vitamin")     var notifVitamin    = true
    @AppStorage("notif_oil")         var notifOil        = true
    @AppStorage("notif_scan")        var notifScan       = true
    @AppStorage("notif_scalp")       var notifScalp      = true
    @AppStorage("notif_stress")      var notifStress     = true

    @Published var isPermissionGranted = false

    // ── Permission ───────────────────────────────────────────────────────

    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted { self.scheduleAll() }
                completion(granted)
            }
        }
    }

    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    // ── Schedule all active ──────────────────────────────────────────────

    func scheduleAll() {
        cancelAll()
        if notifWater   { scheduleWaterReminders() }
        if notifSleep   { scheduleSleepReminder() }
        if notifMorning { scheduleMorningRoutine() }
        if notifVitamin { scheduleVitaminReminder() }
        if notifOil     { scheduleOilReminder() }
        if notifScan    { scheduleScanReminder() }
        if notifScalp   { scheduleScalpReminder() }
        if notifStress  { scheduleStressCheckIn() }
    }

    // ── Water — every 2 hours from 8 AM to 8 PM ──────────────────────────

    func scheduleWaterReminders() {
        let messages = [
            "Hydration time! 💧 Your scalp needs water just like a plant 🌱",
            "Drink up! 💧 Dehydration causes hair follicles to shrink 😱",
            "Water break! 💧 8 glasses a day keeps the hair loss away 🙌",
            "Stay hydrated! 💧 Healthy hair starts from the inside 🌊",
            "Time for water! 💧 Your hair is 25% water — keep it topped up! 🥤",
            "Hydration check! 💧 Dull, dry hair? Drink more water first 🌿",
            "One more glass! 💧 Almost at your 8-glass goal 🏆",
        ]
        let hours = [8, 10, 12, 14, 16, 18, 20]
        for (i, hour) in hours.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "💧 Hydration Reminder"
            content.body = messages[i % messages.count]
            content.sound = .default
            content.categoryIdentifier = "WATER"
            var dc = DateComponents(); dc.hour = hour; dc.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let req = UNNotificationRequest(identifier: "water_\(hour)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(req)
        }
    }

    // ── Bedtime — 10 PM ──────────────────────────────────────────────────

    func scheduleSleepReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🌙 Bedtime = Hair Growth Time"
        content.body = "Growth hormone peaks during deep sleep — your follicles are about to get their best nourishment! Sweet dreams 😴✨"
        content.sound = .default
        var dc = DateComponents(); dc.hour = 22; dc.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "sleep_reminder", content: content, trigger: trigger))
    }

    // ── Morning routine — 7 AM ───────────────────────────────────────────

    func scheduleMorningRoutine() {
        let messages = [
            "Rise & shine! 🌅 Start your hair day right — gentle comb, no heat, no tight hairstyles ✨",
            "Good morning! ☀️ Don't forget: detangle from ends to roots, not root to tip 🌿",
            "Morning! 🌸 Protect your hair today — silk pillowcase saved you from breakage last night! 💤",
            "New day! 🌻 Apply a drop of argan oil to ends before styling — instant shine 🌟",
            "Good morning! 🌈 Remember: wet hair is fragile — be extra gentle today 💧",
            "Rise! 🌄 Scalp massage for 2 minutes in the shower = better than coffee for hair growth ☕",
            "Morning glory! 🌺 This week's hair goal: no heat styling — let it breathe 💨",
        ]
        let day = Calendar.current.component(.weekday, from: Date())
        let content = UNMutableNotificationContent()
        content.title = "🌅 Good Morning, Hair Goals!"
        content.body = messages[day % messages.count]
        content.sound = .default
        var dc = DateComponents(); dc.hour = 7; dc.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "morning_routine", content: content, trigger: trigger))
    }

    // ── Vitamins — 9 AM ─────────────────────────────────────────────────

    func scheduleVitaminReminder() {
        let content = UNMutableNotificationContent()
        content.title = "💊 Vitamin Time!"
        content.body = "Take your Biotin, Vitamin D, and Iron supplements now — the building blocks for thick, strong hair 🌱"
        content.sound = .default
        var dc = DateComponents(); dc.hour = 9; dc.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "vitamin_reminder", content: content, trigger: trigger))
    }

    // ── Oil treatment — Mon, Wed, Fri at 7 PM ────────────────────────────

    func scheduleOilReminder() {
        let oils = ["🌿 Rosemary oil", "🥥 Coconut oil", "🫒 Argan oil"]
        let days = [2, 4, 6] // Mon, Wed, Fri
        for (i, weekday) in days.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "🌿 Oil Treatment Tonight!"
            content.body = "\(oils[i]) massage tonight! Apply to scalp, leave 20 min, then shampoo out. Consistency = results 💪"
            content.sound = .default
            var dc = DateComponents(); dc.weekday = weekday; dc.hour = 19; dc.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            UNUserNotificationCenter.current().add(
                UNNotificationRequest(identifier: "oil_\(weekday)", content: content, trigger: trigger))
        }
    }

    // ── Weekly scan — Sunday 10 AM ───────────────────────────────────────

    func scheduleScanReminder() {
        let content = UNMutableNotificationContent()
        content.title = "📊 Weekly Hair Scan!"
        content.body = "Track your progress! Open Hair Sense AI and do your weekly scan — see how your hair health is improving 💆‍♀️"
        content.sound = .default
        var dc = DateComponents(); dc.weekday = 1; dc.hour = 10; dc.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "weekly_scan", content: content, trigger: trigger))
    }

    // ── Scalp massage — Tue, Thu, Sat at 8 PM ───────────────────────────

    func scheduleScalpReminder() {
        let content = UNMutableNotificationContent()
        content.title = "💆‍♀️ 5-Minute Scalp Massage!"
        content.body = "Just 5 minutes of scalp massage daily can increase hair thickness by 15%! Do it now while watching TV 📺"
        content.sound = .default
        let days = [3, 5, 7] // Tue, Thu, Sat
        for weekday in days {
            var dc = DateComponents(); dc.weekday = weekday; dc.hour = 20; dc.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            UNUserNotificationCenter.current().add(
                UNNotificationRequest(identifier: "scalp_\(weekday)", content: content, trigger: trigger))
        }
    }

    // ── Stress check-in — 2 PM ──────────────────────────────────────────

    func scheduleStressCheckIn() {
        let content = UNMutableNotificationContent()
        content.title = "🧘 Stress Check-in"
        content.body = "High stress = high cortisol = hair shedding. Take 3 deep breaths right now. Your hair will thank you 🌿"
        content.sound = .default
        var dc = DateComponents(); dc.hour = 14; dc.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "stress_checkin", content: content, trigger: trigger))
    }

    // ── Instant notification (for testing or alerts) ─────────────────────

    func sendInstantTip(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
