import SwiftUI

@main
struct SystemPulseApp: App {
    @StateObject private var monitor = MonitorViewModel()

    var body: some Scene {
        MenuBarExtra {
            MonitorView(monitor: monitor)
        } label: {
            Label(
                "CPU \(monitor.metrics.cpuUsage, format: .number.precision(.fractionLength(0)))%",
                systemImage: "gauge.with.dots.needle.50percent"
            )
        }
        .menuBarExtraStyle(.window)
    }
}
