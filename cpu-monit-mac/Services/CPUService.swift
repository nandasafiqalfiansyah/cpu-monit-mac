import Darwin
import Foundation

final class CPUService {
    private var previousTotal: UInt64?
    private var previousIdle: UInt64?

    func usage() -> Double {
        var info = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }

        let user = UInt64(info.cpu_ticks.0)
        let system = UInt64(info.cpu_ticks.1)
        let idle = UInt64(info.cpu_ticks.2)
        let nice = UInt64(info.cpu_ticks.3)
        let total = user + system + idle + nice

        defer {
            previousTotal = total
            previousIdle = idle
        }

        guard let previousTotal, let previousIdle else { return 0 }

        let totalDelta = total &- previousTotal
        let idleDelta = idle &- previousIdle
        guard totalDelta > 0 else { return 0 }

        let busyDelta = totalDelta > idleDelta ? totalDelta - idleDelta : 0
        return min(100, Double(busyDelta) / Double(totalDelta) * 100)
    }
}
