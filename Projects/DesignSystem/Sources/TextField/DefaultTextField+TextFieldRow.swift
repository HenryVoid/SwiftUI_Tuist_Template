import SwiftUI
import Entity

extension DefaultTextField {
    struct TextFieldRow: View {
        let isSecure: Bool
        let placeholder: String
        @Binding var text: String
        var bgColor: Color
        var strokeColor: Color
        var rightBtn: Entity.UI.RightButton?
        
        init(_ isSecure: Bool, _ placeholder: String, _ text: Binding<String>, _ bgColor: Color, _ strokeColor: Color, _ rightBtn: Entity.UI.RightButton? = nil) {
            self.isSecure = isSecure
            self.placeholder = placeholder
            self._text = text
            self.bgColor = bgColor
            self.strokeColor = strokeColor
            self.rightBtn = rightBtn
        }
        
        var body: some View {
            HStack(spacing: 8) {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .frame(height: 26)
                        .foregroundStyle(Color.gray900)
                } else {
                    TextField(placeholder, text: $text)
                        .frame(height: 26)
                        .foregroundStyle(Color.gray900)
                }
                    
                if let rightBtn {
                    Button {
                        rightBtn.action()
                    } label: {
                        Text(rightBtn.text)
                            .foregroundStyle(rightBtn.textColor)
                    }
                    .disabled(!rightBtn.isEnabled)
                }
            }
            .body1()
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1.0)
            )
        }
    }
}
