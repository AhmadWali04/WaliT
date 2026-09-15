import SwiftUI

struct ScanView: View {
    @Binding var isPresented: Bool
    let onCapture: () -> Void
    @State private var isCapturing = false

    private let tabs = ["DOCUMENT", "RECEIPT", "BATCH", "UPLOAD"]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                topBar

                Spacer()

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.accent, lineWidth: 3)
                        .frame(width: 260, height: 340)
                    Text("Align receipt within frame")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.bottom, -36)
                }

                Spacer()

                tabRow
                bottomBar
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "bolt.slash")
                Image(systemName: "gearshape")
            }
            .foregroundColor(.white)
        }
        .padding(.top, 12)
    }

    private var tabRow: some View {
        HStack(spacing: 24) {
            ForEach(tabs, id: \.self) { tab in
                VStack(spacing: 6) {
                    Text(tab)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(tab == "RECEIPT" ? .white : .white.opacity(0.5))
                    if tab == "RECEIPT" {
                        Rectangle().fill(Theme.accent).frame(width: 30, height: 2)
                    }
                }
            }
        }
        .padding(.bottom, 16)
    }

    private var bottomBar: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath").foregroundColor(.white)
            Spacer()
            Button {
                capture()
            } label: {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 4)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle().fill(isCapturing ? Color.gray : Color.white).frame(width: 60, height: 60)
                    )
            }
            .disabled(isCapturing)
            Spacer()
            Image(systemName: "keyboard").foregroundColor(.white)
        }
    }

    // For POC: bypasses the camera and triggers the Stripe simulated payment flow (Section 7).
    private func capture() {
        isCapturing = true
        onCapture()
        isPresented = false
    }
}
