import SwiftUI
import UIKit


public enum FontWeight: String {
    case bold = "Bold"
    case medium = "Medium"
    case regular = "Regular"
}

extension UIFont {
    public class func pretendard(weight: FontWeight, size: CGFloat) -> UIFont {
        return .init(name: "Pretendard-\(weight.rawValue)", size: size)!
    }
    
}

struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}

extension View {
    public func headline1(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 56), lineHeight: 72)
            .kerning(-1.78)
    }
    
    public func headline2(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 44), lineHeight: 57)
            .kerning(-1.32)
    }
    
    public func headline3(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 40), lineHeight: 52)
            .kerning(-1.12)
    }
    
    public func headline4(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 36), lineHeight: 48)
            .kerning(-0.97)
    }
    
    public func headline6(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 28), lineHeight: 38)
            .kerning(-0.66)
    }
    
    public func headline7(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 24), lineHeight: 32)
            .kerning(-0.55)
    }
    
    public func headline8(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 20), lineHeight: 28)
            .kerning(-0.24)
    }
    
    public func subtitle1(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 18), lineHeight: 26)
            .kerning(-0.36)
    }
    
    public func subtitle2(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 17), lineHeight: 24)
            .kerning(0)
    }
    
    public func subtitle3(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 16), lineHeight: 24)
            .kerning(0)
    }
    
    public func subtitle4(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 15), lineHeight: 24)
            .kerning(0)
    }
    
    public func subtitle5(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 14), lineHeight: 22)
            .kerning(0.19)
    }
    
    public func subtitle6(_ weight: FontWeight) -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: weight, size: 13), lineHeight: 18)
            .kerning(0.25)
    }
    
    public func body1() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 16), lineHeight: 26)
            .kerning(0.1)
    }
    
    public func body2() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 15), lineHeight: 24)
            .kerning(0.15)
    }
    
    public func body3() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 14), lineHeight: 24)
            .kerning(0.19)
    }
    
    public func caption1() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 13), lineHeight: 18)
            .kerning(0.25)
    }
    
    public func caption2() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 12), lineHeight: 16)
            .kerning(0.3)
    }
    
    public func caption3() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 11), lineHeight: 14)
            .kerning(0.34)
    }
    
    public func caption4() -> some View {
        return self
            .fontWithLineHeight(font: .pretendard(weight: .regular, size: 11), lineHeight: 12)
            .kerning(0.34)
    }
    
    private func fontWithLineHeight(font: UIFont, lineHeight: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontWithLineHeight(font: font, lineHeight: lineHeight))
    }
}
