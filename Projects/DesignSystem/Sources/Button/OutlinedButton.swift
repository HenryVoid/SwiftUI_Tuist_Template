import SwiftUI

public struct OutlinedButton: View {
    var text: String
    var leftIcon: Image?
    var rightIcon: Image?
    var disabled: Bool
    var action: () -> Void
    
    
    var textColor: Color { disabled ? .gray300 : .primary500 }
    var strokeColor: Color { disabled ? .gray200 : .primary500 }
    
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
            HStack(alignment: .center, spacing: 4) {
                if let leftIcon {
                    leftIcon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(textColor)
                        
                }
                
                Text(text)
                    .subtitle3(.medium)
                    .foregroundStyle(textColor)
                
                if let rightIcon {
                    rightIcon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(textColor)
                        
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1.0)
            )
        }
        .disabled(disabled)
    }
}
