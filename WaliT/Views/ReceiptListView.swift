import SwiftUI

struct ReceiptListView: View {
    @StateObject private var viewModel = ReceiptListViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "Recent"
    @State private var showScan = false

    private let filters = ["Recent", "Stores", "Category", "Date"]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                filterChips
                    .padding(.top, 12)

                HStack {
                    Text("Recent Receipts").font(.headline)
                    Spacer()
                    Text("View All").font(.subheadline).foregroundColor(Theme.accent)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                content

                bottomBar
            }

            scanFAB
        }
        .navigationDestination(for: Block.self) { block in
            ReceiptDetailView(block: block, chain: viewModel.blocks)
        }
        .sheet(isPresented: $showScan) {
            ScanView(isPresented: $showScan) {
                Task { await viewModel.scanReceipt() }
            }
        }
        .task {
            await viewModel.loadReceipts()
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
            Spacer()
        } else if let error = viewModel.errorMessage {
            Spacer()
            Text(error)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        } else if filteredBlocks.isEmpty {
            Spacer()
            Text("No receipts yet — tap Scan Receipt to simulate a tap-to-pay.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredBlocks) { block in
                        NavigationLink(value: block) {
                            ReceiptCard(block: block)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .padding(.bottom, 90)
            }
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
            Spacer()
            Text("WaliT").font(.title3.weight(.bold))
            Spacer()
            Circle().fill(Color(white: 0.85)).frame(width: 32, height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("Search for merchant or amount…", text: $searchText)
        }
        .padding(12)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Text(filter)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Color.black : Theme.card)
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .clipShape(Capsule())
                        .onTapGesture { selectedFilter = filter }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var scanFAB: some View {
        Button {
            showScan = true
        } label: {
            Image(systemName: viewModel.isScanning ? "hourglass" : "camera.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding(18)
                .background(Circle().fill(Color.black))
                .shadow(radius: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 96)
        .disabled(viewModel.isScanning)
    }

    private var bottomBar: some View {
        HStack {
            bottomBarItem(icon: "house", label: "Home", isActive: false)
            Spacer()
            bottomBarItem(icon: "doc.text", label: "Receipts", isActive: true)
            Spacer()
            bottomBarItem(icon: "chart.bar", label: "Analytics", isActive: false)
            Spacer()
            bottomBarItem(icon: "gearshape", label: "Settings", isActive: false)
        }
        .padding(.horizontal, 32)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Theme.card)
        .overlay(alignment: .top) {
            Rectangle().fill(Color(white: 0.9)).frame(height: 0.5)
        }
    }

    private func bottomBarItem(icon: String, label: String, isActive: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .black : .secondary)
            Text(label)
                .font(.caption2)
                .foregroundColor(isActive ? .black : .secondary)
            if isActive {
                Rectangle().fill(Theme.accent).frame(width: 20, height: 2)
            }
        }
    }

    private var filteredBlocks: [Block] {
        let sorted = viewModel.blocks.sorted { $0.blockIndex > $1.blockIndex }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.merchant.name.localizedCaseInsensitiveContains(searchText) || String($0.total).contains(searchText)
        }
    }
}
