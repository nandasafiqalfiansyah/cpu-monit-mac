import Darwin
import Foundation

final class MemoryService {
    func usage() -> (used: UInt64, total: UInt64) {
        let total = UInt64(ProcessInfo.processInfo.physicalMemory)

        var statistics = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &statistics) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (0, total)
        }

        let availablePages = UInt64(statistics.free_count)
            + UInt64(statistics.inactive_count)
            + UInt64(statistics.speculative_count)
        let available = min(total, availablePages * UInt64(vm_page_size))

        return (total - available, total)
    }
}
