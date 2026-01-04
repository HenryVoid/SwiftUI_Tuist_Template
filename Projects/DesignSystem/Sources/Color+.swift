import SwiftUI

// Note: DesignSystemAsset 대신 시스템 컬러 사용

extension Color {
    // Primary Colors
    public static let primary25 = Color.blue.opacity(0.05)
    public static let primary100 = Color.blue.opacity(0.1)
    public static let primary200 = Color.blue.opacity(0.2)
    public static let primary300 = Color.blue.opacity(0.3)
    public static let primary400 = Color.blue.opacity(0.4)
    public static let primary500 = Color.blue
    public static let primary600 = Color.blue.opacity(0.85)
    public static let primary700 = Color.blue.opacity(0.75)
    public static let primary800 = Color.blue.opacity(0.65)
    public static let primary900 = Color.blue.opacity(0.55)
    
    // Gray Scale
    public static let gray50 = Color(white: 0.98)
    public static let gray75 = Color(white: 0.96)
    public static let gray100 = Color(white: 0.94)
    public static let gray200 = Color(white: 0.88)
    public static let gray300 = Color(white: 0.78)
    public static let gray400 = Color(white: 0.68)
    public static let gray500 = Color(white: 0.58)
    public static let gray600 = Color(white: 0.48)
    public static let gray700 = Color(white: 0.38)
    public static let gray800 = Color(white: 0.28)
    public static let gray850 = Color(white: 0.23)
    public static let gray900 = Color(white: 0.18)
    public static let gray950 = Color(white: 0.08)
    public static let white = Color.white
    
    // Accent Colors
    public static let rubyRed = Color.red
    public static let apricotOrange = Color.orange
    public static let lemonYellow = Color.yellow
    public static let spearMint = Color.green
    public static let skyBlue = Color.blue
    public static let azureBlue = Color.blue.opacity(0.8)
    public static let cornflowerBlue = Color.blue.opacity(0.6)
}
