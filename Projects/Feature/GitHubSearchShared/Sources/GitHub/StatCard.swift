import SwiftUI
import DesignSystem

/// Repository 통계 카드 컴포넌트
public struct StatCard: View {
    public let title: String
    public let value: String
    public let icon: String
    public let color: Color
    
    public init(title: String, value: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .title3(.bold)
                .foregroundStyle(Color.gray900)
            
            Text(title)
                .body3()
                .foregroundStyle(Color.gray600)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray50)
        .cornerRadius(12)
    }
}
