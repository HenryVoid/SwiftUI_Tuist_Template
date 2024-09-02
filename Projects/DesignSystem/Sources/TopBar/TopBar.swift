import SwiftUI

struct TopBarModifier<Left, Right>: ViewModifier where Left: View, Right: View {
    var title: String
    var padding: (Edge.Set, CGFloat?)
    var leftItem: (() -> Left)?
    var rightItem: (() -> Right)?
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            TopBar(
                title: self.title,
                padding: self.padding,
                leftItem: self.leftItem,
                rightItem: self.rightItem
            )
            .zIndex(999)
            content
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationBarHidden(true)
    }
}

struct TopBar<Left, Right>: View where Left: View, Right: View {
    var title: String
    var padding: (Edge.Set, CGFloat?)
    var leftItem: (() -> Left)?
    var rightItem: (() -> Right)?
    
    var body: some View {
        HStack {
            self.leftItem?()
            Spacer()
            self.rightItem?()
        }
        .overlay(
            Text(self.title)
                .subtitle3(.bold)
                .frame(minWidth: 140, minHeight: 44)
        )
        .padding(padding.0, padding.1)
        .frame(height: 44)
        .background(Color.clear.ignoresSafeArea())
    }
}

extension View {
    public func topBar<Left: View, Right: View>(
        title: String,
        padding: (Edge.Set, CGFloat?) = (.horizontal, 16),
        @ViewBuilder leftItem: @escaping () -> Left,
        @ViewBuilder rightItem: @escaping () -> Right
    ) -> some View {
        modifier(
            TopBarModifier(
                title: title,
                padding: padding,
                leftItem: leftItem,
                rightItem: rightItem
            )
        )
    }
    
    public func backTopBar(
        title: String,
        padding: (Edge.Set, CGFloat?) = (.horizontal, 16),
        backAction: @escaping () -> Void
    ) -> some View {
        modifier(
            TopBarModifier(
                title: title,
                padding: padding,
                leftItem: {
                    Button {
                        backAction()
                    } label: {
                        Image.icBracketLeftThickness15
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                },
                rightItem: { EmptyView() }
            )
        )
    }
}
