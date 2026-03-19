//
//  ScanLimitManager.swift
//  Hair AI
//

import Foundation

class ScanLimitManager {

    static let shared = ScanLimitManager()

    private let scansKey         = "weekly_scans"
    private let weekStartKey     = "week_start_date"
    private let totalScansKey    = "total_scans_ever"
    private let maxScansPerWeek  = 3

    private init() {}

    // MARK: - Is first scan ever
    var isFirstScanEver: Bool {
        return UserDefaults.standard.integer(forKey: totalScansKey) == 0
    }

    // MARK: - Can scan this week
    var canScan: Bool {
        resetIfNewWeek()
        return scansThisWeek < maxScansPerWeek
    }

    var scansThisWeek: Int {
        resetIfNewWeek()
        return UserDefaults.standard.integer(forKey: scansKey)
    }

    var scansRemaining: Int {
        return max(0, maxScansPerWeek - scansThisWeek)
    }

    var totalScansEver: Int {
        return UserDefaults.standard.integer(forKey: totalScansKey)
    }

    var daysUntilReset: Int {
        guard let weekStart = UserDefaults.standard.object(forKey: weekStartKey) as? Date else {
            return 7
        }
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
        let days = Calendar.current.dateComponents([.day], from: Date(), to: nextWeek).day ?? 0
        return max(0, days)
    }

    // MARK: - Record a scan
    func recordScan() {
        resetIfNewWeek()
        let weekly = UserDefaults.standard.integer(forKey: scansKey)
        UserDefaults.standard.set(weekly + 1, forKey: scansKey)

        let total = UserDefaults.standard.integer(forKey: totalScansKey)
        UserDefaults.standard.set(total + 1, forKey: totalScansKey)
    }

    // MARK: - Reset if new week
    private func resetIfNewWeek() {
        let defaults = UserDefaults.standard
        if let weekStart = defaults.object(forKey: weekStartKey) as? Date {
            let daysSince = Calendar.current.dateComponents([.day], from: weekStart, to: Date()).day ?? 0
            if daysSince >= 7 {
                defaults.set(0, forKey: scansKey)
                defaults.set(Date(), forKey: weekStartKey)
            }
        } else {
            defaults.set(Date(), forKey: weekStartKey)
            defaults.set(0, forKey: scansKey)
        }
    }
}
