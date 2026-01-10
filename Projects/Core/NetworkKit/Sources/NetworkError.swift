import Foundation

public enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingFailed
    case requestFailed
    case unknown

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingFailed, .decodingFailed),
             (.requestFailed, .requestFailed),
             (.unknown, .unknown):
            return true
        case (.httpError(let lhsCode, _), .httpError(let rhsCode, _)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
