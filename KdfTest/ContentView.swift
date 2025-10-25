import SwiftUI

struct ContentView: View {
    @StateObject private var kdfService = KdfService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Komodo DeFi Framework")
                .font(.headline)

            // Version display or progress while loading
            HStack(alignment: .center, spacing: 8) {
                Text("Version:")
                    .bold()
                if let version = kdfService.version {
                    Text(version)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                    // Show a spinner while a fetch is in progress
                    if kdfService.isFetching {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                } else {
                    // If no version yet, show a spinner
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                Spacer()
                // RPC status indicator
                Circle()
                    .fill(kdfService.rpcUp ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(kdfService.rpcUp ? "RPC Up" : "RPC Down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Manual fetch button and counter
            HStack(spacing: 16) {
                Button(action: {
                    kdfService.manualFetch()
                }) {
                    Text("Fetch Now")
                }
                .buttonStyle(.borderedProminent)

                Text("Fetch count: \(kdfService.fetchCount)")
                    .font(.subheadline)
            }

            // Countdown until the next automatic fetch
            Text("Next fetch in: \(kdfService.secondsUntilNextFetch)s")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            // KMD coin controls
            Text("KMD Controls")
                .font(.headline)

            HStack(spacing: 16) {
                Button(action: {
                    kdfService.enableKmd()
                }) {
                    Text("Enable KMD")
                }
                .buttonStyle(.bordered)
                .disabled(kdfService.isKmdEnabled)

                Button(action: {
                    kdfService.disableKmd()
                }) {
                    Text("Disable KMD")
                }
                .buttonStyle(.bordered)
                .disabled(!kdfService.isKmdEnabled)
            }

            HStack(spacing: 16) {
                Button(action: {
                    kdfService.manualBalanceFetch()
                }) {
                    Text("Fetch Balance")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!kdfService.isKmdEnabled)

                Button(action: {
                    kdfService.copyKmdAddressToClipboard()
                }) {
                    Text("Copy Address")
                }
                .buttonStyle(.bordered)
                .disabled(!kdfService.isKmdEnabled || kdfService.kmdAddress == nil)
            }

            // Display the KMD enabled state, balance and address
            Text("KMD Enabled: \(kdfService.isKmdEnabled ? "Yes" : "No")")
                .font(.subheadline)
                .foregroundColor(.primary)

            if let balance = kdfService.kmdBalance {
                Text("KMD Balance: \(balance)")
                    .font(.subheadline)
            }
            if let addr = kdfService.kmdAddress {
                Text("KMD Address: \(addr)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Divider()

            // Foldable log views for KDF and application logs
            DisclosureGroup(isExpanded: .constant(true)) {
                ScrollView {
                    Text(kdfService.logs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                }
                .frame(maxHeight: 150)
                .border(Color.gray.opacity(0.4))
            } label: {
                Text("KDF Log")
                    .bold()
            }
            DisclosureGroup(isExpanded: .constant(true)) {
                ScrollView {
                    Text(kdfService.appLogs)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                }
                .frame(maxHeight: 150)
                .border(Color.gray.opacity(0.4))
            } label: {
                Text("App Log")
                    .bold()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            kdfService.start()
        }
        .onDisappear {
            // Do not stop mm2 here; allow background operation
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                // Begin background task to continue timers/fetching
                kdfService.beginBackgroundTask()
                // Use a 60-second interval when in background
                kdfService.updateFetchInterval(to: 60)
            case .active:
                // End the background task when returning to foreground
                kdfService.endBackgroundTask()
                // Restore the 10-second interval when active
                kdfService.updateFetchInterval(to: 10)
            default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
