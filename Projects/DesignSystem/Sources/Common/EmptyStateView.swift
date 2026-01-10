import SwiftUI

/// 빈 상태 표시 컴포넌트
public struct EmptyStateView: View {
    public let icon: String
    public let title: String
    public let message: String
    
    public init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Color.gray400)
            
            Text(title)
                .title2(.medium)
                .foregroundStyle(Color.gray700)
            
            Text(message)
                .body2()
                .foregroundStyle(Color.gray500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

