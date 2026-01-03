import Foundation

/// 네트워크 에러 정의
public enum NetworkError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case noData
    case timeout
    case networkUnavailable
    case unknown(Error)
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .statusCode(let code):
            return "서버 에러 (상태 코드: \(code))"
        case .decodingFailed(let error):
            return "데이터 디코딩 실패: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "데이터 인코딩 실패: \(error.localizedDescription)"
        case .noData:
            return "데이터가 없습니다."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .networkUnavailable:
            return "네트워크 연결을 확인해주세요."
        case .unknown(let error):
            return "알 수 없는 에러: \(error.localizedDescription)"
        }
    }
}

