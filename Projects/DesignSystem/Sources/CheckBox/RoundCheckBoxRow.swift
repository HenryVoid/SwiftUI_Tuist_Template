import SwiftUI
import Entity

public struct RoundCheckBoxRow: View {
    @Binding var state: Entity.UI.CheckBoxState
    var text: String
    var fontWeight: FontWeight
    var disabled: Bool
    var rightBtn: Entity.UI.RightButton?
    var action: (Entity.UI.CheckBoxState) -> Void
    
    public init(state: Binding<Entity.UI.CheckBoxState>, text: String, fontWeight: FontWeight, disabled: Bool = false, rightBtn: Entity.UI.RightButton? = nil, action: @escaping (Entity.UI.CheckBoxState) -> Void) {
        self._state = state
        self.text = text
        self.fontWeight = fontWeight
        self.disabled = disabled
        self.rightBtn = rightBtn
        self.action = action
    }
    
    public var body: some View {
        Button {
            action(state)
        } label: {
            HStack(spacing: 4) {
                RoundCheckBox(state: state, disabled: disabled, action: { _ in })
                
                Text(text)
                    .subtitle5(fontWeight)
                    .foregroundStyle(Color.gray900)
                
                Spacer()
                
                if let rightBtn {
                    Button {
                        rightBtn.action()
                    } label: {
                        Text(rightBtn.text)
                            .subtitle6(.medium)
                            .foregroundStyle(rightBtn.textColor)
                    }
                    .disabled(!rightBtn.isEnabled)
                }
            }
        }
        .disabled(disabled)
    }
}
