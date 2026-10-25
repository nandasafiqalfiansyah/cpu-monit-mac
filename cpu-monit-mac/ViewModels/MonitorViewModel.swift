import Combine
import Foundation

@MainActor
final class MonitorViewModel: ObservableObject {
    @Published private(set) var metrics = SystemMetrics()
    @Published private(set) var refreshInterval: TimeInterval

    private let cpuService = CPUService()
    private let memoryService = MemoryService()
    private let networkService = NetworkService()
    private let batteryService = BatteryService()
    private var timer: Timer?

    init() {
        let savedInterval = UserDefaults.standard.double(forKey: Self.refreshIntervalKey)
        refreshInterval = Self.validatedRefreshInterval(savedInterval)

        refresh()
        startMonitoring()
    }

    func refresh() {
        let cpuUsage = cpuService.usage()
        let memory = memoryService.usage()
        let network = networkService.rates()
        let battery = batteryService.status()

        metrics = SystemMetrics(
            cpuUsage: cpuUsage,
            usedMemory: memory.used,
            totalMemory: memory.total,
            downloadBytesPerSecond: network.download,
            uploadBytesPerSecond: network.upload,
            batteryLevel: battery.level,
            isCharging: battery.charging
        )
    }

    func updateRefreshInterval(_ interval: TimeInterval) {
        let newInterval = Self.validatedRefreshInterval(interval)
        guard refreshInterval != newInterval else { return }

        refreshInterval = newInterval
        UserDefaults.standard.set(newInterval, forKey: Self.refreshIntervalKey)

        timer?.invalidate()
        timer = nil
        startMonitoring()
        refresh()
    }

    private func startMonitoring() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    private static func validatedRefreshInterval(_ interval: TimeInterval) -> TimeInterval {
        [1.0, 2.0, 5.0].contains(interval) ? interval : 2.0
    }

    private static let refreshIntervalKey = "refreshInterval"

    deinit {
        timer?.invalidate()
    }
}
