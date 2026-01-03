import Foundation

/// 요청/응답 인터셉터 프로토콜
public protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func retry(_ request: URLRequest, error: any Error, retryCount: Int) async -> Bool
}

/// 기본 인터셉터 구현
public actor DefaultRequestInterceptor: RequestInterceptor {
    private let maxRetryCount: Int
    private let retryableStatusCodes: Set<Int>
    
    public init(maxRetryCount: Int = 3, retryableStatusCodes: Set<Int> = [408, 500, 502, 503, 504]) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatusCodes = retryableStatusCodes
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request
        // 여기에 공통 헤더 추가, 인증 토큰 추가 등의 로직 구현 가능
        return adaptedRequest
    }
    
    public func retry(_ request: URLRequest, error: any Error, retryCount: Int) async -> Bool {
        // 최대 재시도 횟수 체크
        guard retryCount < maxRetryCount else { return false }
        
        // NetworkError 타입 체크
        if let networkError = error as? NetworkError {
            switch networkError {
            case .statusCode(let code):
                // 재시도 가능한 상태 코드인 경우
                if retryableStatusCodes.contains(code) {
                    // 지수 백오프 (exponential backoff)
                    let delay = pow(2.0, Double(retryCount))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return true
                }
            case .timeout, .networkUnavailable:
                // 타임아웃이나 네트워크 불가 시 재시도
                let delay = pow(2.0, Double(retryCount))
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return true
            default:
                break
            }
        }
        
        return false
    }
}

/// 인증 토큰 인터셉터
public actor AuthInterceptor: RequestInterceptor {
    private var accessToken: String?
    private let tokenProvider: @Sendable () async throws -> String?
    
    public init(tokenProvider: @Sendable @escaping () async throws -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request
        
        // 토큰이 없으면 새로 가져오기
        if accessToken == nil {
            accessToken = try await tokenProvider()
        }
        
        // Authorization 헤더 추가
        if let token = accessToken {
            adaptedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return adaptedRequest
    }
    
    public func retry(_ request: URLRequest, error: any Error, retryCount: Int) async -> Bool {
        // 401 Unauthorized인 경우 토큰 갱신 후 재시도
        if let networkError = error as? NetworkError,
           case .statusCode(401) = networkError,
           retryCount < 1 {
            // 토큰 갱신
            accessToken = try? await tokenProvider()
            return accessToken != nil
        }
        
        return false
    }
}

