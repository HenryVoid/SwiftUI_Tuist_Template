import SwiftUI
import Entity

public struct DefaultCheckBox: View {
    
    var state: Entity.UI.CheckBoxState = .unchecked
    var disabled: Bool
    var action: (Entity.UI.CheckBoxState) -> Void
    
    var bgColor: Color { state == .unchecked ? .white : .primary500 }
    var strokeColor: Color { state == .unchecked ? .gray300 : .clear }
    var icon: Image {
        switch state {
        case .unchecked:
            Image.icCheckThickness20
        case .checked:
            Image.icCheckThickness20
        case .partial:
            Image.icMinusThickness20
        }
    }
    
    public init(state: Entity.UI.CheckBoxState = .unchecked, disabled: Bool = false, action: @escaping (Entity.UI.CheckBoxState) -> Void) {
        self.state = state
        self.disabled = disabled
        self.action = action
    }
    
    public var body: some View {
        Button {
            action(state)
        } label: {
            Image.icCheckThickness20
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(state == .unchecked ? .clear : .white)
                .frame(width: 16, height: 16)
                .padding(1)
                .background {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(bgColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(strokeColor, lineWidth: 1.0)
                )
        }
        .disabled(disabled)
    }
}
