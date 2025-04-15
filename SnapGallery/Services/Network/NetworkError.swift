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

extension NetworkError {
    var alertMessage: String {
        switch self {
        case .invalidURL:
            return "Неверный URL."
        case .invalidRequest:
            return "Неверный запрос."
        case .noConnection:
            return "Отсутствует подключение к интернету."
        case .timeout:
            return "Превышено время ожидания ответа от сервера."
        case .serverError(let statusCode):
            return "Ошибка сервера. Код: \(statusCode)."
        case .invalidResponse:
            return "Некорректный ответ от сервера."
        case .decodingError(let underlying):
            return "Ошибка обработки данных: \(underlying.localizedDescription)"
        case .unknown(let description):
            return description ?? "Неизвестная ошибка."
        }
    }
}
