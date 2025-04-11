import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidRequest
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingError(underlying: Error)
    case unknown(description: String?)
}
