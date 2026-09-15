import SwiftUI

struct ReceiptDetailView: View {
    @StateObject private var viewModel: ReceiptDetailViewModel
    let chain: [Block]
    @Environment(\.dismiss) private var dismiss

    init(block: Block, chain: [Block]) {
        _viewModel = StateObject(wrappedValue: ReceiptDetailViewModel(block: block))
        self.chain = chain
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                merchantHeader

                HStack(alignment: .top) {
                    detailColumn(title: "DATE & TIME", value: viewModel.block.displayDateTime)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("CATEGORY").font(.caption2.weight(.semibold)).foregroundColor(.secondary)
                        CategoryPill(category: viewModel.block.merchant.category)
                    }
                }

                Divider()

                VStack(spacing: 12) {
                    ForEach(viewModel.block.lineItems) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name).font(.subheadline.weight(.semibold))
                                Text(item.description).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                        }
                    }
                }

                Divider()

                VStack(spacing: 8) {
                    totalsRow(label: "Subtotal", value: viewModel.block.subtotal)
                    totalsRow(label: "Tax", value: viewModel.block.tax)
                    HStack {
                        Text("Total").font(.headline)
                        Spacer()
                        Text(viewModel.block.total, format: .currency(code: "USD"))
                            .font(.title3.weight(.bold))
                            .foregroundColor(Theme.accent)
                    }
                }

                actionsCard
                transactionContextCard
                memoCard

                ActionButton(title: "Edit Receipt", style: .filled) {}
            }
            .padding(16)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.verify(against: chain)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text("Receipt").font(.headline)
            Spacer()
            HStack(spacing: 16) {
                Image(systemName: "square.and.arrow.up")
                Image(systemName: "ellipsis")
            }
        }
        .foregroundColor(.primary)
    }

    private var merchantHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle().fill(Color(white: 0.9)).frame(width: 56, height: 56)
                Image(systemName: "storefront").foregroundColor(.secondary)
            }
            Text(viewModel.block.merchant.name).font(.title2.weight(.bold))
            Text("\(viewModel.block.merchant.address.uppercased()) · \(viewModel.block.transactionId.uppercased())")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func detailColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2.weight(.semibold)).foregroundColor(.secondary)
            Text(value).font(.subheadline)
        }
    }

    private func totalsRow(label: String, value: Double) -> some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value, format: .currency(code: "USD"))
        }
        .font(.subheadline)
    }

    private var actionsCard: some View {
        VStack(spacing: 10) {
            ActionButton(title: "Export as PDF", style: .filled) {}
            ActionButton(title: "Share with Accountant", style: .outlined) {}
            ActionButton(title: "Flag for Review", style: .outlinedDestructive) {}
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
    }

    private var transactionContextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(viewModel.block.paymentMethod, systemImage: "creditcard")
            Label(viewModel.block.merchant.address, systemImage: "mappin.and.ellipse")
            VerifiedBadge(isVerified: viewModel.isVerified)
        }
        .font(.subheadline)
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
    }

    private var memoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Internal Memo").font(.subheadline.weight(.semibold))
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.memo)
                    .frame(height: 80)
                if viewModel.memo.isEmpty {
                    Text("Add a note about this expense…")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
    }
}
