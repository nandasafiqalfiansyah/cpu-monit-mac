import Darwin
import Foundation

final class NetworkService {
    private var previousCounters: [String: InterfaceCounters] = [:]
    private var previousSampleDate = Date()

    func rates() -> (download: Double, upload: Double) {
        let currentCounters = interfaceCounters()
        let now = Date()
        let elapsed = now.timeIntervalSince(previousSampleDate)

        defer {
            previousCounters = currentCounters
            previousSampleDate = now
        }

        guard elapsed > 0, !previousCounters.isEmpty else {
            return (0, 0)
        }

        var received: UInt64 = 0
        var sent: UInt64 = 0

        for (name, current) in currentCounters {
            guard let previous = previousCounters[name],
                  current.received >= previous.received,
                  current.sent >= previous.sent else {
                continue
            }

            received += current.received - previous.received
            sent += current.sent - previous.sent
        }

        return (Double(received) / elapsed, Double(sent) / elapsed)
    }

    private func interfaceCounters() -> [String: InterfaceCounters] {
        var addresses: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&addresses) == 0, let firstAddress = addresses else {
            return [:]
        }

        defer { freeifaddrs(addresses) }

        var counters: [String: InterfaceCounters] = [:]
        var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddress

        while let address = cursor {
            let interface = address.pointee

            defer { cursor = interface.ifa_next }

            guard let namePointer = interface.ifa_name,
                  let dataPointer = interface.ifa_data,
                  let socketAddress = interface.ifa_addr,
                  socketAddress.pointee.sa_family == UInt8(AF_LINK),
                  (interface.ifa_flags & UInt32(IFF_UP)) != 0 else {
                continue
            }

            let name = String(cString: namePointer)

            guard !name.hasPrefix("lo"),
                  !name.hasPrefix("utun"),
                  !name.hasPrefix("awdl"),
                  !name.hasPrefix("llw") else {
                continue
            }

            let data = dataPointer.assumingMemoryBound(to: if_data.self).pointee
            counters[name] = InterfaceCounters(
                received: UInt64(data.ifi_ibytes),
                sent: UInt64(data.ifi_obytes)
            )
        }

        return counters
    }
}

private struct InterfaceCounters {
    let received: UInt64
    let sent: UInt64
}
