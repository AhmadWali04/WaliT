import Foundation

enum ReceiptAPIError: LocalizedError {
    case invalidResponse(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let status):
            return "WaliT API returned status \(status)"
        }
    }
}

// Talks to the local Node/Express API from Section 8 (localhost:3000).
final class ReceiptAPIService {
    static let shared = ReceiptAPIService()

    private let baseURL = URL(string: "http://localhost:3000")!
    private let session = URLSession.shared

    func fetchReceipts() async throws -> [Block] {
        let (data, response) = try await session.data(from: baseURL.appendingPathComponent("receipts"))
        try Self.checkOK(response)
        return try JSONDecoder().decode([Block].self, from: data)
    }

    func fetchReceipt(id: String) async throws -> Block {
        let (data, response) = try await session.data(from: baseURL.appendingPathComponent("receipts/\(id)"))
        try Self.checkOK(response)
        return try JSONDecoder().decode(Block.self, from: data)
    }

    func verifyChain() async throws -> ChainVerification {
        let (data, response) = try await session.data(from: baseURL.appendingPathComponent("receipts/verify"))
        try Self.checkOK(response)
        return try JSONDecoder().decode(ChainVerification.self, from: data)
    }

    func postReceipt(_ payload: NewBlockPayload) async throws -> Block {
        var request = URLRequest(url: baseURL.appendingPathComponent("receipts"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)
        try Self.checkOK(response)
        return try JSONDecoder().decode(Block.self, from: data)
    }

    private static func checkOK(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw ReceiptAPIError.invalidResponse(status)
        }
    }
}
