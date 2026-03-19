//
//
//  ScanHistoryManager.swift
//  Hair AI
//

import UIKit

struct ScanRecord: Codable {
    let date: Date
    let score: Int
    let condition: String
    let density: String
    let scalpHealth: String
    let hairLossRisk: String
    let recommendations: [String]
    let dietTips: [String]
    let imageData: Data?
}

class ScanHistoryManager {

    static let shared = ScanHistoryManager()
    private let historyKey = "scan_history"
    private init() {}

    // MARK: - Save scan
    func saveScan(result: HairAnalysisResult, image: UIImage?) {
        var history = getAllScans()

        let imageData = image?.jpegData(compressionQuality: 0.5)
        let record = ScanRecord(
            date:            Date(),
            score:           result.overallScore,
            condition:       result.condition,
            density:         result.density,
            scalpHealth:     result.scalpHealth,
            hairLossRisk:    result.hairLossRisk,
            recommendations: result.recommendations,
            dietTips:        result.dietTips,
            imageData:       imageData
        )

        history.append(record)

        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    // MARK: - Get all scans
    func getAllScans() -> [ScanRecord] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let scans = try? JSONDecoder().decode([ScanRecord].self, from: data) else {
            return []
        }
        return scans
    }

    // MARK: - Get first scan
    func getFirstScan() -> ScanRecord? {
        return getAllScans().first
    }

    // MARK: - Get last scan
    func getLastScan() -> ScanRecord? {
        return getAllScans().last
    }

    // MARK: - Get first scan image
    func getFirstScanImage() -> UIImage? {
        guard let data = getFirstScan()?.imageData else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Total scans count
    var totalScans: Int {
        return getAllScans().count
    }
}
