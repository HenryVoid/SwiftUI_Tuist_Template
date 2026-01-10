import XCTest
@testable import NetworkKit

/// Mock URLProtocol for testing
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

/// Mock Request for testing
struct MockRequest: NetworkRequest {
    typealias Response = MockResponse
    
    let baseURL: String
    let path: String
    let method: HTTPMethod
    
    init(baseURL: String = "https://api.example.com", path: String = "/test", method: HTTPMethod = .get) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
    }
}

/// Mock Response for testing
struct MockResponse: Decodable, Sendable {
    let message: String
}

/// NetworkKit Tests
final class NetworkKitTests: XCTestCase {
    var networkService: NetworkService!
    var configuration: URLSessionConfiguration!
    
    override func setUp() async throws {
        // URLSession 설정
        configuration = .ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        networkService = NetworkService(session: session)
    }
    
    override func tearDown() async throws {
        networkService = nil
        MockURLProtocol.requestHandler = nil
    }
    
    // MARK: - Success Tests
    
    func testSuccessfulRequest() async throws {
        // Given
        let expectedMessage = "Success"
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let data = """
            {"message": "\(expectedMessage)"}
            """.data(using: .utf8)
            
            return (response, data)
        }
        
        // When
        let request = MockRequest()
        let response = try await networkService.request(request)
        
        // Then
        XCTAssertEqual(response.message, expectedMessage)
    }
    
    // MARK: - Error Tests
    
    func testStatusCodeError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, nil)
        }
        
        // When/Then
        let request = MockRequest()
        do {
            _ = try await networkService.request(request)
            XCTFail("Should throw error")
        } catch let error as NetworkError {
            if case .statusCode(let code) = error {
                XCTAssertEqual(code, 404)
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testDecodingError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let data = """
            {"invalid": "data"}
            """.data(using: .utf8)
            
            return (response, data)
        }
        
        // When/Then
        let request = MockRequest()
        do {
            _ = try await networkService.request(request)
            XCTFail("Should throw error")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // Success
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    // MARK: - Retry Tests
    
    func testRetryLogic() async throws {
        // Given
        var attemptCount = 0
        let maxRetries = 3
        
        MockURLProtocol.requestHandler = { request in
            attemptCount += 1
            
            if attemptCount <= maxRetries {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!
                
                return (response, nil)
            } else {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                
                let data = """
                {"message": "Success after retry"}
                """.data(using: .utf8)
                
                return (response, data)
            }
        }
        
        let interceptor = DefaultRequestInterceptor(maxRetryCount: maxRetries)
        let session = URLSession(configuration: configuration)
        let serviceWithRetry = NetworkService(session: session, interceptor: interceptor)
        
        // When
        let request = MockRequest()
        let response = try await serviceWithRetry.request(request)
        
        // Then
        XCTAssertEqual(response.message, "Success after retry")
        XCTAssertEqual(attemptCount, maxRetries + 1)
    }
}

