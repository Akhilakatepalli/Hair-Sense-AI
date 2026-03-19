//
//  HealthKitService.swift
//  Hair AI
//

import HealthKit
import SwiftUI
import Combine

class HealthKitService: ObservableObject {

    static let shared = HealthKitService()
    private let store = HKHealthStore()

    @Published var isAuthorized = false
    @Published var sleepHours: Double = 0        // last night
    @Published var steps: Int = 0                // today
    @Published var heartRate: Double = 0         // latest bpm
    @Published var restingHeartRate: Double = 0  // resting bpm
    @Published var waterLiters: Double = 0       // today (litres)
    @Published var activeCalories: Double = 0    // today kcal
    @Published var bodyWeight: Double = 0        // latest kg
    @Published var hrvScore: Double = 0          // ms
    @Published var mindfulMinutes: Double = 0    // today

    // ── HealthKit type sets ──────────────────────────────────────────────

    private var readTypes: Set<HKObjectType> {
        var t = Set<HKObjectType>()
        let ids: [HKQuantityTypeIdentifier] = [
            .stepCount, .heartRate, .restingHeartRate,
            .activeEnergyBurned, .bodyMass, .heartRateVariabilitySDNN,
            .dietaryWater, .dietaryBiotin, .dietaryProtein
        ]
        ids.forEach { if let q = HKObjectType.quantityType(forIdentifier: $0) { t.insert(q) } }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { t.insert(sleep) }
        if let mind  = HKObjectType.categoryType(forIdentifier: .mindfulSession) { t.insert(mind) }
        return t
    }

    private var writeTypes: Set<HKSampleType> {
        var t = Set<HKSampleType>()
        if let w = HKQuantityType.quantityType(forIdentifier: .dietaryWater) { t.insert(w) }
        return t
    }

    // ── Authorization ────────────────────────────────────────────────────

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(false); return }
        store.requestAuthorization(toShare: writeTypes, read: readTypes) { success, _ in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success { self.fetchAll() }
                completion(success)
            }
        }
    }

    func fetchAll() {
        fetchSleep()
        fetchSteps()
        fetchHeartRate()
        fetchRestingHeartRate()
        fetchWater()
        fetchActiveCalories()
        fetchBodyWeight()
        fetchHRV()
        fetchMindfulness()
    }

    // ── Sleep ────────────────────────────────────────────────────────────

    func fetchSleep() {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -22, to: Calendar.current.startOfDay(for: now))!
        let pred = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let s = samples as? [HKCategorySample] else { return }
            let asleepValues: Set<Int> = [
                HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                HKCategoryValueSleepAnalysis.asleepREM.rawValue
            ]
            let total = s.filter { asleepValues.contains($0.value) }
                         .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            DispatchQueue.main.async { self.sleepHours = total / 3600.0 }
        }
        store.execute(q)
    }

    // ── Steps ────────────────────────────────────────────────────────────

    func fetchSteps() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, s, _ in
            DispatchQueue.main.async { self.steps = Int(s?.sumQuantity()?.doubleValue(for: .count()) ?? 0) }
        }
        store.execute(q)
    }

    // ── Heart Rate ───────────────────────────────────────────────────────

    func fetchHeartRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let start = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 1, sortDescriptors: [sort]) { _, s, _ in
            guard let sample = s?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async { self.heartRate = bpm }
        }
        store.execute(q)
    }

    func fetchRestingHeartRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return }
        let start = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 1, sortDescriptors: [sort]) { _, s, _ in
            guard let sample = s?.first as? HKQuantitySample else { return }
            let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async { self.restingHeartRate = bpm }
        }
        store.execute(q)
    }

    // ── Water ────────────────────────────────────────────────────────────

    func fetchWater() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, s, _ in
            DispatchQueue.main.async { self.waterLiters = s?.sumQuantity()?.doubleValue(for: .liter()) ?? 0 }
        }
        store.execute(q)
    }

    /// Log a glass of water (250 ml) to HealthKit
    func logWaterGlass() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        let quantity = HKQuantity(unit: .liter(), doubleValue: 0.25)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
        store.save(sample) { _, _ in DispatchQueue.main.async { self.fetchWater() } }
    }

    // ── Active Calories ──────────────────────────────────────────────────

    func fetchActiveCalories() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, s, _ in
            DispatchQueue.main.async { self.activeCalories = s?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0 }
        }
        store.execute(q)
    }

    // ── Body Weight ──────────────────────────────────────────────────────

    func fetchBodyWeight() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, s, _ in
            guard let sample = s?.first as? HKQuantitySample else { return }
            DispatchQueue.main.async { self.bodyWeight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo)) }
        }
        store.execute(q)
    }

    // ── HRV (stress proxy) ───────────────────────────────────────────────

    func fetchHRV() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        let start = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: 1, sortDescriptors: [sort]) { _, s, _ in
            guard let sample = s?.first as? HKQuantitySample else { return }
            let ms = sample.quantity.doubleValue(for: HKUnit(from: "ms"))
            DispatchQueue.main.async { self.hrvScore = ms }
        }
        store.execute(q)
    }

    // ── Mindfulness ──────────────────────────────────────────────────────

    func fetchMindfulness() {
        guard let type = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let q = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, s, _ in
            let total = (s ?? []).reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            DispatchQueue.main.async { self.mindfulMinutes = total / 60.0 }
        }
        store.execute(q)
    }

    // ── Computed insights ────────────────────────────────────────────────

    var sleepInsight: (emoji: String, text: String, color: Color) {
        switch sleepHours {
        case 7.5...:  return ("🌟", "Great sleep! Hair follicles are actively repairing tonight", Color(red: 0.20, green: 0.85, blue: 0.50))
        case 6..<7.5: return ("😴", "Decent sleep. Try for 7.5h+ to maximise growth hormone release", Color(red: 0.95, green: 0.75, blue: 0.15))
        case 0.01..<6: return ("⚠️", "Low sleep detected. Under 6h raises cortisol — linked to hair shedding", Color(red: 0.95, green: 0.40, blue: 0.30))
        default:      return ("💤", "No sleep data yet. Connect Apple Watch for automatic tracking", Color.white.opacity(0.50))
        }
    }

    var stepsInsight: (emoji: String, text: String) {
        switch steps {
        case 10000...: return ("🔥", "Amazing! 10K+ steps = excellent scalp blood circulation")
        case 7000..<10000: return ("👟", "Good activity! Exercise boosts blood flow to follicles")
        case 3000..<7000: return ("🚶", "Moderate activity. Try to reach 8K steps for hair health")
        default:       return ("🛋️", "Low activity today. Even a 20-min walk stimulates scalp circulation")
        }
    }

    var stressLevel: String {
        // HRV as stress proxy: higher = less stressed
        if hrvScore == 0 { return "Unknown" }
        if hrvScore > 60  { return "Low 😌" }
        if hrvScore > 30  { return "Moderate 😐" }
        return "High ⚠️"
    }

    var waterGlasses: Int { Int((waterLiters / 0.25).rounded()) }
}
