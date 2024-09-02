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
        }
        .frame(maxWidth: .infinity)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(disabled)
    }
}
