import Foundation
import IOKit.ps

final class BatteryService {
    func status() -> (level: Int?, charging: Bool) {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return (nil, false)
        }

        for source in sources {
            guard let description = IOPSGetPowerSourceDescription(snapshot, source)?
                .takeUnretainedValue() as? [String: Any],
                  let type = description[kIOPSTypeKey as String] as? String,
                  type == kIOPSInternalBatteryType else {
                continue
            }

            let currentCapacity = description[kIOPSCurrentCapacityKey as String] as? Int
            let maximumCapacity = description[kIOPSMaxCapacityKey as String] as? Int ?? 100
            let isCharging = description[kIOPSIsChargingKey as String] as? Bool ?? false

            guard let currentCapacity, maximumCapacity > 0 else {
                return (nil, isCharging)
            }

            let level = Int((Double(currentCapacity) / Double(maximumCapacity) * 100).rounded())
            return (level, isCharging)
        }

        return (nil, false)
    }
}
