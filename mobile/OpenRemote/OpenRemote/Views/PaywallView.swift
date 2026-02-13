import SwiftUI
import RevenueCatUI

struct SupportPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView(displayCloseButton: true)
            .onPurchaseCompleted { _ in
                dismiss()
            }
            .onRestoreCompleted { _ in
                dismiss()
            }
    }
}
