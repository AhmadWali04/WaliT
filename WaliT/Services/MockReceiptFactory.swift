import Foundation

// Hardcoded mock receipt templates (Section 7) used to produce realistic-looking receipts
// for the POC's simulated Stripe payment flow.
enum MockReceiptFactory {
    struct Template {
        let merchant: Merchant
        let lineItems: [LineItem]
    }

    static let paymentMethod = "Visa •••• 4242"

    static let templates: [Template] = [
        Template(
            merchant: Merchant(name: "Equator Coffees", address: "232 California St, San Francisco", category: .dining),
            lineItems: [
                LineItem(name: "Pour Over - Ethiopia", description: "Single Origin, Light Roast", amount: 6.50),
                LineItem(name: "Almond Croissant", description: "Freshly Baked", amount: 5.25),
                LineItem(name: "Oat Milk Latte", description: "Large 16oz", amount: 7.00),
            ]
        ),
        Template(
            merchant: Merchant(name: "Bi-Rite Market", address: "3639 18th St, San Francisco", category: .groceries),
            lineItems: [
                LineItem(name: "Organic Avocados", description: "Pack of 4", amount: 5.99),
                LineItem(name: "Sourdough Loaf", description: "Baked in-house", amount: 7.50),
                LineItem(name: "Whole Milk", description: "1 Gallon", amount: 4.25),
            ]
        ),
        Template(
            merchant: Merchant(name: "Muni Metro", address: "San Francisco Municipal Railway", category: .transport),
            lineItems: [
                LineItem(name: "Single Ride Fare", description: "Bus / Metro", amount: 2.75),
            ]
        ),
        Template(
            merchant: Merchant(name: "Best Buy", address: "1717 Harrison St, San Francisco", category: .electronics),
            lineItems: [
                LineItem(name: "USB-C Cable", description: "6ft Braided", amount: 14.99),
                LineItem(name: "Screen Protector", description: "Tempered Glass", amount: 9.99),
            ]
        ),
        Template(
            merchant: Merchant(name: "Walgreens", address: "135 Powell St, San Francisco", category: .health),
            lineItems: [
                LineItem(name: "Vitamin D3", description: "90 Softgels", amount: 11.49),
                LineItem(name: "Hand Sanitizer", description: "2oz Travel Size", amount: 3.29),
            ]
        ),
    ]

    static func randomReceipt() -> Template {
        templates.randomElement()!
    }
}
