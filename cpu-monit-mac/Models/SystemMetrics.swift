import Foundation

struct SystemMetrics: Equatable {
    var cpuUsage: Double = 0
    var usedMemory: UInt64 = 0
    var totalMemory: UInt64 = 0
    var downloadBytesPerSecond: Double = 0
    var uploadBytesPerSecond: Double = 0
    var batteryLevel: Int?
    var isCharging = false

    var memoryUsage: Double {
        guard totalMemory > 0 else { return 0 }
        return Double(usedMemory) / Double(totalMemory) * 100
    }
}
