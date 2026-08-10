import SwiftUI

public struct AssistiveButton: View {
    var text: String
    var leftIcon: Image?
    var rightIcon: Image?
    var disabled: Bool
    var action: () -> Void
    
    var textColor: Color { disabled ? .gray300 : .gray900 }
    
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
            .background {
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(.white)
            }
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(Color.gray200, lineWidth: DSBorderWidth.thin)
            )
        }
        .disabled(disabled)
    }
}
