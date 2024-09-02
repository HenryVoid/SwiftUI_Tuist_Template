import SwiftUI
import DesignSystem

@main
struct AuthApp: App {
    
    @State var disabled: Bool = false
    @State var isChecked: Bool = false
    
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 20) {
                DefaultRadio(isChecked: isChecked, action: {
                    isChecked.toggle()
                })
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: .infinity)
            .background(.white)
        }
    }
}
