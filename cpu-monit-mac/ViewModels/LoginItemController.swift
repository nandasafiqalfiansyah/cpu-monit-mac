import Combine
import ServiceManagement

@MainActor
final class LoginItemController: ObservableObject {
    @Published var isEnabled = false
    @Published private(set) var errorMessage: String?

    init() {
        refreshStatus()
    }

    func refreshStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        errorMessage = nil

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        refreshStatus()
    }
}
