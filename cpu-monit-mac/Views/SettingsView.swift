import SwiftUI

struct SettingsView: View {
    @ObservedObject var monitor: MonitorViewModel
    @StateObject private var loginItem = LoginItemController()
    @State private var selectedRefreshInterval: TimeInterval = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SettingsHeader()

            VStack(alignment: .leading, spacing: 12) {
                Text("Monitoring")
                    .font(.headline)

                Picker("Refresh interval", selection: $selectedRefreshInterval) {
                    Text("Every second").tag(TimeInterval(1))
                    Text("Every 2 seconds").tag(TimeInterval(2))
                    Text("Every 5 seconds").tag(TimeInterval(5))
                }
                .pickerStyle(.segmented)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Background")
                    .font(.headline)

                Toggle("Launch at login", isOn: $loginItem.isEnabled)
                    .onChange(of: loginItem.isEnabled) { _, isEnabled in
                        loginItem.setEnabled(isEnabled)
                    }

                Text("SystemPulse stays active in the menu bar without appearing in the Dock.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let errorMessage = loginItem.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 390)
        .onAppear {
            selectedRefreshInterval = monitor.refreshInterval
            loginItem.refreshStatus()
        }
        .onChange(of: selectedRefreshInterval) { _, interval in
            monitor.updateRefreshInterval(interval)
        }
    }
}

private struct SettingsHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("SystemPulse")
                    .font(.title3.weight(.semibold))
                Text("Settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
