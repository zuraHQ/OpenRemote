import SwiftUI

// TODO: Replace with RevenueCat paywall once SDK is added
// 1. Add SPM package: https://github.com/RevenueCat/purchases-ios-spm
// 2. Import RevenueCatUI and use PaywallView(displayCloseButton: true)

struct SupportPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "heart.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("Support OpenRemote")
                    .font(.title2.bold())

                Text("Help keep the project alive with a small donation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Text("Paywall coming soon")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
