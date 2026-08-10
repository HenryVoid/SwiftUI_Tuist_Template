import SwiftUI

struct DSButtonContent: View {
    let text: String
    let leftIcon: Image?
    let rightIcon: Image?
    let textColor: Color

    var body: some View {
        HStack(alignment: .center, spacing: DSSpacing.xxs) {
            icon(leftIcon)

            Text(text)
                .subtitle3(.medium)
                .foregroundStyle(textColor)

            icon(rightIcon)
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.vertical, DSSpacing.md)
    }

    @ViewBuilder
    private func icon(_ image: Image?) -> some View {
        if let image {
            image
                .resizable()
                .renderingMode(.template)
                .frame(width: DSIconSize.md, height: DSIconSize.md)
                .foregroundStyle(textColor)
        }
    }
}
