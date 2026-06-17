//
//  HealthKitService.swift
//  MotivationRun
//

import HealthKit
import Foundation

class HealthKitService {
    static let shared = HealthKitService()
    private init() {}  // [FIX HIGH-002] singleton 보호

    private let store = HKHealthStore()

    // [FIX CRITICAL-001] 강제 언래핑 제거 → lazy + compactMap
    private lazy var readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let dist = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) { types.insert(dist) }
        if let cal  = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)    { types.insert(cal) }
        if let step = HKObjectType.quantityType(forIdentifier: .stepCount)              { types.insert(step) }
        if let hr   = HKObjectType.quantityType(forIdentifier: .heartRate)              { types.insert(hr) }
        return types
    }()

    // MARK: - HealthKit 사용 가능 여부

    func isAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - 권한 요청 이력 (읽기 권한은 API로 확인 불가 → UserDefaults 캐시 사용)

    func hasRequestedAuthorization() -> Bool {
        UserDefaults.standard.bool(forKey: "hkAuthRequested")
    }

    // MARK: - 권한 요청

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isAvailable() else { completion(false); return }
        store.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                // 권한 다이얼로그를 통과했음을 기록 (granted/denied 여부와 무관)
                UserDefaults.standard.set(true, forKey: "hkAuthRequested")
            }
            if let error = error {
                print("❌ [HealthKit] 권한 요청 오류: \(error.localizedDescription)")
            }
            DispatchQueue.main.async { completion(success) }
        }
    }

    // MARK: - 이번 달 러닝 통계 수집

    func fetchMonthlyRunningStats(completion: @escaping (Bool) -> Void) {
        guard isAvailable() else { completion(false); return }

        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)

        // [FIX CRITICAL-002] calendar.date 강제 언래핑 제거
        guard let startOfMonth = calendar.date(from: components),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            print("❌ [HealthKit] 날짜 계산 실패")
            DispatchQueue.main.async { completion(false) }
            return
        }

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            // [FIX HIGH-003] end를 now → startOfNextMonth (당월 전체 범위)
            HKQuery.predicateForSamples(withStart: startOfMonth, end: startOfNextMonth, options: .strictStartDate),
            HKQuery.predicateForWorkouts(with: .running)
        ])

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let self = self, let workouts = samples as? [HKWorkout], error == nil else {
                print("❌ [HealthKit] 워크아웃 조회 실패: \(error?.localizedDescription ?? "unknown")")
                DispatchQueue.main.async { completion(false) }
                return
            }

            let sourcePref = SharedDataManager.shared.getWorkoutSourcePreference()
            let filtered = workouts.filter { sourcePref.allows(bundleID: $0.sourceRevision.source.bundleIdentifier) }

            var sessions: [RunSession] = []
            var totalDistanceM = 0.0
            var totalCalories = 0.0
            var totalDurationSec = 0.0
            var totalSteps = 0
            var heartRateSum = 0.0
            var heartRateCount = 0

            for workout in filtered {
                let distanceM   = self.distanceMeters(from: workout)
                let kcal        = self.energyKcal(from: workout)
                let durationMin = workout.duration / 60

                totalDistanceM  += distanceM
                totalCalories   += kcal
                totalDurationSec += workout.duration

                totalSteps += self.stepCount(from: workout)
                if let hr = self.avgHeartRate(from: workout) {
                    heartRateSum += hr
                    heartRateCount += 1
                }

                sessions.append(RunSession(
                    id: UUID(),
                    hkWorkoutID: workout.uuid,
                    date: workout.startDate,
                    distanceKm: distanceM / 1000,
                    calories: kcal,
                    durationMinutes: durationMin
                ))
            }

            let totalKm = totalDistanceM / 1000
            let totalDurationMin = totalDurationSec / 60
            let avgHR: Double? = heartRateCount > 0 ? heartRateSum / Double(heartRateCount) : nil

            let remainingDays = max(
                calendar.dateComponents([.day], from: now, to: startOfNextMonth).day ?? 1,
                1
            )

            print("🏃 [HealthKit] 집계: \(String(format: "%.1f", totalKm))km | \(Int(totalCalories))kcal | \(String(format: "%.0f", totalDurationMin))분 (\(filtered.count)회)")

            let stats = MonthlyStats(
                year:                 components.year  ?? calendar.component(.year, from: now),
                month:                components.month ?? calendar.component(.month, from: now),
                totalDistanceKm:      totalKm,
                totalCalories:        totalCalories,
                totalDurationMinutes: totalDurationMin,
                goalType:             SharedDataManager.shared.getGoalType(),
                goalTarget:           SharedDataManager.shared.getGoalTarget(),
                lastSyncTime:         now,
                activitiesCount:      filtered.count,
                sessions:             sessions,
                totalSteps:           totalSteps > 0 ? totalSteps : nil,
                avgHeartRateBpm:      avgHR
            )

            SharedDataManager.shared.saveMonthlyStats(stats)
            DispatchQueue.main.async { completion(true) }
        }

        store.execute(query)
    }

    // MARK: - 전체 러닝 기록 수집 (Log 탭용)

    func fetchAllRunningSessions(completion: @escaping ([RunSession]) -> Void) {
        guard isAvailable() else { completion([]); return }

        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            guard let self = self, let workouts = samples as? [HKWorkout], error == nil else {
                print("❌ [HealthKit] 전체 러닝 조회 실패: \(error?.localizedDescription ?? "unknown")")
                DispatchQueue.main.async { completion([]) }
                return
            }

            let sourcePref = SharedDataManager.shared.getWorkoutSourcePreference()
            let filtered = workouts.filter { sourcePref.allows(bundleID: $0.sourceRevision.source.bundleIdentifier) }

            let sessions: [RunSession] = filtered.map { workout in
                RunSession(
                    id: UUID(),
                    hkWorkoutID: workout.uuid,
                    date: workout.startDate,
                    distanceKm: self.distanceMeters(from: workout) / 1000,
                    calories: self.energyKcal(from: workout),
                    durationMinutes: workout.duration / 60
                )
            }

            DispatchQueue.main.async { completion(sessions) }
        }

        store.execute(query)
    }

    // MARK: - 사용 가능한 러닝 소스 목록 조회 (Data Source Filter 설정 UI용)

    func fetchAvailableRunningSources(completion: @escaping ([(name: String, bundleID: String)]) -> Void) {
        guard isAvailable() else { completion([]); return }
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            let workouts = samples as? [HKWorkout] ?? []
            var seen = Set<String>()
            var sources: [(name: String, bundleID: String)] = []
            for w in workouts {
                let bid = w.sourceRevision.source.bundleIdentifier
                if seen.insert(bid).inserted {
                    let displayName = self.displayName(for: bid, fallback: w.sourceRevision.source.name)
                    sources.append((name: displayName, bundleID: bid))
                }
            }
            sources.sort { $0.name < $1.name }
            DispatchQueue.main.async { completion(sources) }
        }
        store.execute(query)
    }

    private func displayName(for bundleID: String, fallback: String) -> String {
        let nameMap: [String: String] = [
            "com.garmin.connect.mobile": "Garmin Connect",
            "com.garmin.fit": "Garmin",
            "com.strava.stravaride": "Strava",
            "com.apple.Health": "Apple Health",
            "com.apple.health": "Apple Health",
        ]
        return nameMap[bundleID] ?? fallback
    }

    // MARK: - 거리 추출 (iOS 16+ / 구버전 호환)

    private func distanceMeters(from workout: HKWorkout) -> Double {
        if #available(iOS 16.0, *),
           let qty = workout.statistics(for: HKQuantityType(.distanceWalkingRunning))?.sumQuantity() {
            return qty.doubleValue(for: .meter())
        }
        return workout.totalDistance?.doubleValue(for: .meter()) ?? 0
    }

    // MARK: - 칼로리 추출 (iOS 16+ / 구버전 호환)

    private func energyKcal(from workout: HKWorkout) -> Double {
        if #available(iOS 16.0, *),
           let qty = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity() {
            return qty.doubleValue(for: .kilocalorie())
        }
        return workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
    }

    // MARK: - 걸음 수 추출

    private func stepCount(from workout: HKWorkout) -> Int {
        if #available(iOS 16.0, *),
           let qty = workout.statistics(for: HKQuantityType(.stepCount))?.sumQuantity() {
            return Int(qty.doubleValue(for: .count()))
        }
        return 0
    }

    // MARK: - 평균 심박수 추출

    private func avgHeartRate(from workout: HKWorkout) -> Double? {
        if #available(iOS 16.0, *),
           let qty = workout.statistics(for: HKQuantityType(.heartRate))?.averageQuantity() {
            return qty.doubleValue(for: HKUnit(from: "count/min"))
        }
        return nil
    }
}
