import SwiftUI

/// 로딩 오버레이 컴포넌트
public struct LoadingOverlay: View {
    public let message: String
    
    public init(message: String = "Loading...") {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .body2()
                .foregroundStyle(Color.gray700)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
}

