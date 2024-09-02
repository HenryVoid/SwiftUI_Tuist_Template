import SwiftUI
import Entity

public struct DefaultTextField<value: Hashable>: View {
    let isSecure: Bool
    let placeholder: String
    @Binding var text: String
    var focusedField: (binding: FocusState<value?>.Binding, equals: value?)
    var disabled: Bool
    @Binding var isError: Bool
    
    var leftBottom: Entity.UI.BottomText?
    var rightBottom: Entity.UI.BottomText?
    
    var rightBtn: Entity.UI.RightButton?
    
    var hasBottom: Bool { leftBottom?.text.count ?? 0 > 0 || rightBottom?.text.count ?? 0 > 0 }
    var bgColor: Color { disabled ? .gray75 : .white }
    var strokeColor: Color {
        if focusedField.binding.wrappedValue == focusedField.equals {
            return .gray600
        } else if isError {
            return .rubyRed
        } else {
            return .gray200
        }
    }
    
    public init(
        isSecure: Bool = false,
        placeholder: String,
        text: Binding<String>,
        focusedField: (binding: FocusState<value?>.Binding, equals: value?),
        disabled: Bool = false,
        isError: Binding<Bool> = .constant(false),
        leftBottom: Entity.UI.BottomText? = nil,
        rightBottom: Entity.UI.BottomText? = nil,
        rightBtn: Entity.UI.RightButton? = nil
    ) {
        self.isSecure = isSecure
        self.placeholder = placeholder
        self._text = text
        self.focusedField = focusedField
        self.disabled = disabled
        self._isError = isError
        self.leftBottom = leftBottom
        self.rightBottom = rightBottom
        self.rightBtn = rightBtn
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            TextFieldRow(isSecure, placeholder, $text, bgColor, strokeColor, rightBtn)
                .focused(focusedField.binding, equals: focusedField.equals)
                .disabled(disabled)
                .onChange(of: text) { oldValue, newValue in
                    if isError {
                        isError = oldValue == newValue
                    }
                }
            
            if hasBottom {
                BottomRow(leftBottom, rightBottom)
            }
        }
    }
}
