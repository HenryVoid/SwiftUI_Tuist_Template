import Foundation
import SwiftUI

public struct DatePickerRow: View {
    @Binding var date: Date?
    let placeholder: String
    var format: String
    var disabled: Bool
    
    private var strokeColor: Color = .gray200
    private var bgColor: Color { disabled ? .gray75 : .white }
    @State private var selectDate: Date = Date.now
    
    public init(date: Binding<Date?>, placeholder: String, format: String, disabled: Bool = false) {
        self._date = date
        self.placeholder = placeholder
        self.format = format
        self.disabled = disabled
    }
    
    
    public var body: some View {
        HStack(spacing: 8) {
            if let date {
                Text(dateFormat(date))
                    .foregroundStyle(Color.gray900)
            } else {
                Text(placeholder)
                    .foregroundStyle(Color.gray400)
            }
            
            Spacer()
            
            Image.icBracketDownThickness15
                .frame(width: 20, height: 20)
            
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
        .allowsHitTesting(false)
        .overlay {
            if !disabled {
                DatePicker(selection: $selectDate, displayedComponents: .date) {}
                    .labelsHidden()
                    .contentShape(Rectangle())
                    .opacity(0.011)
                    .compositingGroup()
                    .scaleEffect(x: 10, y: 1.5)
                    .clipped()
                    .onChange(of: selectDate) { _, newValue in
                        date = newValue
                    }
            }
        }
    }
    
    private func dateFormat(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = self.format
        fmt.locale = Locale(identifier: "ko_KR")
        return fmt.string(from: date)
    }
}
