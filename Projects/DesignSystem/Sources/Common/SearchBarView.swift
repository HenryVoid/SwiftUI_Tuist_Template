import SwiftUI

/// 공통 Search Bar 컴포넌트
public struct SearchBarView: View {
    @Binding public var text: String
    public let placeholder: String
    public let onSubmit: () -> Void
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        onSubmit: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .onSubmit(onSubmit)
            
            Button("Search") {
                onSubmit()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

