import SwiftUI

public struct DefaultRadio: View {
    
    var isChecked: Bool
    var action: () -> Void
    
    var bgColor: Color { isChecked ? .primary500 : .white }
    var strokeColor: Color { isChecked ? .clear : .gray300 }
    
    public init(isChecked: Bool, action: @escaping () -> Void) {
        self.isChecked = isChecked
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Circle()
                .fill(bgColor)
                .stroke(strokeColor, lineWidth: 1.5)
                .frame(width: 20, height: 20)
                .overlay {
                    Circle()
                        .fill(.white)
                        .frame(width: 8, height: 8)
                }
        }
    }
}
