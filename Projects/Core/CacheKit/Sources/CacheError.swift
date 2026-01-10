import Foundation

/// 캐시 에러
public enum CacheError: Error, Sendable {
    case notFound
    case expired
    case encodingFailed
    case decodingFailed
    case diskWriteFailed
    case diskReadFailed
    case invalidData
    
    public var localizedDescription: String {
        switch self {
        case .notFound:
            return "캐시를 찾을 수 없습니다."
        case .expired:
            return "캐시가 만료되었습니다."
        case .encodingFailed:
            return "데이터 인코딩에 실패했습니다."
        case .decodingFailed:
            return "데이터 디코딩에 실패했습니다."
        case .diskWriteFailed:
            return "디스크 쓰기에 실패했습니다."
        case .diskReadFailed:
            return "디스크 읽기에 실패했습니다."
        case .invalidData:
            return "잘못된 데이터입니다."
        }
    }
}

