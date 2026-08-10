import SwiftUI

public struct SolidButton: View {
    var text: String
    var leftIcon: Image?
    var rightIcon: Image?
    var disabled: Bool
    var action: () -> Void
    
    var textColor: Color { disabled ? .gray400 : .white }
    var bgColor: Color { disabled ? .gray75 : .primary500 }
    
    public init(text: String, leftIcon: Image? = nil, rightIcon: Image? = nil, disabled: Bool = false, action: @escaping () -> Void) {
        self.text = text
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.disabled = disabled
        self.action = action
    }
    
    public var body: some View {
        Button {
            self.action()
        } label: {
            DSButtonContent(text: text, leftIcon: leftIcon, rightIcon: rightIcon, textColor: textColor)
        }
        .frame(maxWidth: .infinity)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .disabled(disabled)
    }
}
