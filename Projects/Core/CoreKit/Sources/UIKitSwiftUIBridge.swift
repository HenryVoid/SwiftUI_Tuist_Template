#if canImport(UIKit)
import UIKit
import SwiftUI

// MARK: - UIKit + SwiftUI Hybrid

/// UIViewController를 SwiftUI로 감싸는 래퍼
public struct UIViewControllerWrapper<ViewController: UIViewController>: UIViewControllerRepresentable {
    private let makeViewController: () -> ViewController
    private let update: ((ViewController) -> Void)?
    
    public init(
        makeViewController: @escaping () -> ViewController,
        update: ((ViewController) -> Void)? = nil
    ) {
        self.makeViewController = makeViewController
        self.update = update
    }
    
    public func makeUIViewController(context: Context) -> ViewController {
        makeViewController()
    }
    
    public func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        update?(uiViewController)
    }
}

/// SwiftUI View를 UIViewController로 감싸는 헬퍼
public final class SwiftUIHostingController<Content: View>: UIHostingController<Content> {
    public init(rootView: Content, ignoresSafeArea: Bool = false) {
        super.init(rootView: rootView)
        
        if ignoresSafeArea {
            view.insetsLayoutMarginsFromSafeArea = false
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// UIViewController Preview 헬퍼
#if DEBUG
public struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    private let viewController: ViewController
    
    public init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    public func makeUIViewController(context: Context) -> ViewController {
        viewController
    }
    
    public func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif

#endif

