import AppKit
import SwiftUI

struct MonitorView: View {
    @ObservedObject var monitor: MonitorViewModel
    @State private var isShowingSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MonitorHeader(
                cpuUsage: monitor.metrics.cpuUsage,
                refresh: monitor.refresh,
                showSettings: { isShowingSettings = true }
            )

            MetricGrid(
                cpuUsage: monitor.metrics.cpuUsage,
                memoryUsage: monitor.metrics.memoryUsage,
                usedMemory: monitor.metrics.usedMemory,
                totalMemory: monitor.metrics.totalMemory
            )

            NetworkRatesView(
                downloadRate: monitor.metrics.downloadBytesPerSecond,
                uploadRate: monitor.metrics.uploadBytesPerSecond
            )

            BatteryStatusView(
                level: monitor.metrics.batteryLevel,
                isCharging: monitor.metrics.isCharging
            )

            Divider()

            HStack {
                Label(
                    "Updates every \(Int(monitor.refreshInterval)) seconds",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(18)
        .frame(width: 370)
        .background(.regularMaterial)
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(monitor: monitor)
        }
    }
}

private struct MonitorHeader: View {
    let cpuUsage: Double
    let refresh: () -> Void
    let showSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("SystemPulse")
                    .font(.headline)

                Text("System monitor")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(cpuUsage, format: .number.precision(.fractionLength(0)))
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.cyan)
                .accessibilityLabel("CPU usage \(Int(cpuUsage)) percent")

            HStack(spacing: 2) {
                Button(action: refresh) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh metrics")
                .accessibilityLabel("Refresh metrics")

                Button(action: showSettings) {
                    Image(systemName: "gearshape")
                }
                .help("Open settings")
                .accessibilityLabel("Open settings")
            }
            .buttonStyle(.borderless)
        }
    }
}

private struct MetricGrid: View {
    let cpuUsage: Double
    let memoryUsage: Double
    let usedMemory: UInt64
    let totalMemory: UInt64

    var body: some View {
        HStack(spacing: 12) {
            MetricCard(
                title: "CPU",
                valueText: "\(Int(cpuUsage.rounded()))%",
                progress: cpuUsage / 100,
                systemImage: "cpu",
                tint: .cyan
            )

            MetricCard(
                title: "Memory",
                valueText: "\(memorySize(usedMemory)) / \(memorySize(totalMemory))",
                progress: memoryUsage / 100,
                systemImage: "memorychip",
                tint: .purple
            )
        }
    }

    private func memorySize(_ bytes: UInt64) -> String {
        ByteCountFormatter.string(
            fromByteCount: Int64(clamping: bytes),
            countStyle: .memory
        )
    }
}

private struct MetricCard: View {
    let title: LocalizedStringKey
    let valueText: String
    let progress: Double
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(tint)

            Text(valueText)
                .font(.headline)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            ProgressView(value: min(max(progress, 0), 1))
                .tint(tint)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct NetworkRatesView: View {
    let downloadRate: Double
    let uploadRate: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Label("Network", systemImage: "network")
                .font(.headline)

            HStack(spacing: 12) {
                NetworkRateRow(
                    title: "Download",
                    systemImage: "arrow.down.circle.fill",
                    rate: downloadRate,
                    tint: .blue
                )

                NetworkRateRow(
                    title: "Upload",
                    systemImage: "arrow.up.circle.fill",
                    rate: uploadRate,
                    tint: .orange
                )
            }
        }
        .padding(14)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct NetworkRateRow: View {
    let title: LocalizedStringKey
    let systemImage: String
    let rate: Double
    let tint: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(formatRate(rate))
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatRate(_ bytesPerSecond: Double) -> String {
        let value = max(bytesPerSecond, 0)

        switch value {
        case 1_000_000...:
            return String(format: "%.2f MB/s", value / 1_000_000)
        case 1_000...:
            return String(format: "%.1f KB/s", value / 1_000)
        default:
            return String(format: "%.0f B/s", value)
        }
    }
}

private struct BatteryStatusView: View {
    let level: Int?
    let isCharging: Bool

    var body: some View {
        HStack {
            Label("Battery", systemImage: batterySymbol)
                .font(.subheadline.weight(.medium))

            Spacer()

            if let level {
                Text("\(level)%")
                    .monospacedDigit()

                if isCharging {
                    Label("Charging", systemImage: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Text("Not available")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var batterySymbol: String {
        guard let level else { return "battery.0" }
        return "battery.\(min(max((level + 12) / 25 * 25, 0), 100))"
    }
}
