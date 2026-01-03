import Foundation

/// 네트워크 서비스 프로토콜
public protocol NetworkServiceProtocol: Sendable {
    func request<T: NetworkRequest>(_ request: T) async throws -> T.Response
}

/// URLSession 기반 네트워크 서비스
public actor NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let interceptor: (any RequestInterceptor)?
    private let decoder: JSONDecoder
    
    public init(
        session: URLSession = .shared,
        interceptor: (any RequestInterceptor)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.interceptor = interceptor
        self.decoder = decoder
    }
    
    public func request<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        return try await performRequest(request, retryCount: 0)
    }
    
    private func performRequest<T: NetworkRequest>(_ request: T, retryCount: Int) async throws -> T.Response {
        // URLRequest 생성
        var urlRequest = try request.makeURLRequest()
        
        // 인터셉터 적용
        if let interceptor = interceptor {
            urlRequest = try await interceptor.adapt(urlRequest)
        }
        
        do {
            // 네트워크 요청 실행
            let (data, response) = try await session.data(for: urlRequest)
            
            // 응답 검증
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // 상태 코드 확인
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }
            
            // 데이터 디코딩
            do {
                let decoded = try decoder.decode(T.Response.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingFailed(error)
            }
            
        } catch {
            // 재시도 로직
            if let interceptor = interceptor,
               await interceptor.retry(urlRequest, error: error, retryCount: retryCount) {
                return try await performRequest(request, retryCount: retryCount + 1)
            }
            
            // 에러 변환
            if let networkError = error as? NetworkError {
                throw networkError
            } else if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    throw NetworkError.timeout
                case .notConnectedToInternet, .networkConnectionLost:
                    throw NetworkError.networkUnavailable
                default:
                    throw NetworkError.unknown(urlError)
                }
            } else {
                throw NetworkError.unknown(error)
            }
        }
    }
}

/// Multipart Form Data 지원
public extension NetworkService {
    func uploadMultipart<T: NetworkRequest>(
        _ request: T,
        data: Data,
        name: String,
        fileName: String,
        mimeType: String
    ) async throws -> T.Response {
        var urlRequest = try request.makeURLRequest()
        
        // Multipart boundary 생성
        let boundary = UUID().uuidString
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Multipart body 생성
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        // 인터셉터 적용
        if let interceptor = interceptor {
            urlRequest = try await interceptor.adapt(urlRequest)
        }
        
        // 요청 실행
        let (responseData, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        return try decoder.decode(T.Response.self, from: responseData)
    }
}

