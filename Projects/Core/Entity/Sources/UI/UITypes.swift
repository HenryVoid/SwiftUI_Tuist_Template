import SwiftUI

/// UI 관련 타입 정의
public extension Entity {
    enum UI {
        // MARK: - CheckBox Types
        public enum CheckBoxState {
            case checked
            case unchecked
            case partial
            case indeterminate
        }
        
        // MARK: - TextField Types
        public struct BottomText {
            public let text: String
            public let textColor: Color
            
            public init(text: String, textColor: Color = .gray) {
                self.text = text
                self.textColor = textColor
            }
        }
        
        public struct RightButton {
            public let action: () -> Void
            public let text: String
            public let textColor: Color
            public let isEnabled: Bool
            
            public init(
                action: @escaping () -> Void,
                text: String,
                textColor: Color = .blue,
                isEnabled: Bool = true
            ) {
                self.action = action
                self.text = text
                self.textColor = textColor
                self.isEnabled = isEnabled
            }
        }
    }
}

/// Entity 네임스페이스
public enum Entity {}

