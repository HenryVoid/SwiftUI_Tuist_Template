import Foundation

/// 네트워크 요청을 정의하는 프로토콜
public protocol NetworkRequest: Sendable {
    associatedtype Response: Decodable & Sendable
    
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
}

public extension NetworkRequest {
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
    var timeout: TimeInterval { 30.0 }
    
    /// URLRequest 생성
    func makeURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL + path)
        
        // Query parameters 추가
        if let parameters = parameters {
            urlComponents?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        
        // Headers 설정
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Body 설정
        if let body = body {
            request.httpBody = body
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return request
    }
}

