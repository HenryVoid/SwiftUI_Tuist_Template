import Entity
import SwiftUI

extension DefaultTextField {
    struct BottomRow: View {
        var leftBottom: Entity.UI.BottomText?
        var rightBottom: Entity.UI.BottomText?
        
        init(_ leftBottom: Entity.UI.BottomText? = nil, _ rightBottom: Entity.UI.BottomText? = nil) {
            self.leftBottom = leftBottom
            self.rightBottom = rightBottom
        }
        
        var body: some View {
            HStack(spacing: 0) {
                if let leftBottom {
                    Text(leftBottom.text)
                        .foregroundStyle(leftBottom.textColor)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if let rightBottom {
                    Text(rightBottom.text)
                        .foregroundStyle(rightBottom.textColor)
                        .multilineTextAlignment(.trailing)
                }
            }
            .caption1()
            .padding(.horizontal, 12)
        }
    }
}
