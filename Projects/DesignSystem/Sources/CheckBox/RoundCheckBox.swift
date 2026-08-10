import SwiftUI
import Entity

public struct RoundCheckBox: View {
    
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
        case .indeterminate:
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
            icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(state == .unchecked ? .clear : .white)
                .frame(width: DSIconSize.sm, height: DSIconSize.sm)
                .padding(2)
                .background {
                    Circle().fill(bgColor)
                }
                .overlay(
                    Circle().stroke(strokeColor, lineWidth: DSBorderWidth.thin)
                )
        }
        .disabled(disabled)
    }
}
