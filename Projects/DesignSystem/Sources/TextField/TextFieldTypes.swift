import SwiftUI

// MARK: - TextField Supporting Types
// These types replace Entity.UI references

public extension DefaultTextField {
    struct BottomText {
        public let text: String
        public let textColor: Color
        
        public init(text: String, textColor: Color = .gray600) {
            self.text = text
            self.textColor = textColor
        }
    }
    
    struct RightButton {
        public let action: () -> Void
        public let text: String
        public let textColor: Color
        public let isEnabled: Bool
        
        public init(action: @escaping () -> Void, text: String, textColor: Color = .blue, isEnabled: Bool = true) {
            self.action = action
            self.text = text
            self.textColor = textColor
            self.isEnabled = isEnabled
        }
    }
}

