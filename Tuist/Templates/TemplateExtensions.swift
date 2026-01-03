import ProjectDescription

/// Tuist Template을 이용한 모듈 생성 가이드
/// 
/// Feature 모듈 생성:
/// ```
/// tuist scaffold feature --name MyFeature
/// ```
/// 
/// Core 모듈 생성:
/// ```
/// tuist scaffold core --name MyCore
/// ```
/// 
/// 생성 후 Module.swift에 모듈 추가 필요

/// Feature 모듈 템플릿 (MVVM + Clean Architecture)
extension Template {
    static func mvvmCleanFeature(name: String) -> Template {
        Template(
            description: "MVVM + Clean Architecture Feature Template",
            attributes: [
                .required("name")
            ],
            items: [
                // ViewModel
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)ViewModel.swift",
                    templatePath: "Stencil/mvvm_viewmodel.stencil"
                ),
                // View
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)View.swift",
                    templatePath: "Stencil/mvvm_view.stencil"
                ),
                // UseCase
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)UseCase.swift",
                    templatePath: "Stencil/mvvm_usecase.stencil"
                ),
                // Repository
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)Repository.swift",
                    templatePath: "Stencil/mvvm_repository.stencil"
                ),
                // Project.swift
                .file(
                    path: "Projects/Feature/\(name)/Project.swift",
                    templatePath: "Stencil/feature.stencil"
                ),
                // Tests
                .file(
                    path: "Projects/Feature/\(name)/Tests/\(name)Tests.swift",
                    templatePath: "Stencil/test.stencil"
                ),
                // DemoApp
                .file(
                    path: "Projects/Feature/\(name)/DemoApp/Sources/DemoApp.swift",
                    templatePath: "Stencil/demo.stencil"
                )
            ]
        )
    }
}

/// Coordinator Pattern을 사용하는 Feature 템플릿
extension Template {
    static func coordinatorFeature(name: String) -> Template {
        Template(
            description: "Coordinator Pattern Feature Template",
            attributes: [
                .required("name")
            ],
            items: [
                // Coordinator
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)Coordinator.swift",
                    templatePath: "Stencil/coordinator.stencil"
                ),
                // ViewController
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)ViewController.swift",
                    templatePath: "Stencil/viewcontroller.stencil"
                ),
                // Project.swift
                .file(
                    path: "Projects/Feature/\(name)/Project.swift",
                    templatePath: "Stencil/feature.stencil"
                )
            ]
        )
    }
}

/// Router Pattern을 사용하는 Feature 템플릿
extension Template {
    static func routerFeature(name: String) -> Template {
        Template(
            description: "Router Pattern Feature Template",
            attributes: [
                .required("name")
            ],
            items: [
                // Router
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)Router.swift",
                    templatePath: "Stencil/router.stencil"
                ),
                // View
                .file(
                    path: "Projects/Feature/\(name)/Sources/\(name)View.swift",
                    templatePath: "Stencil/mvvm_view.stencil"
                ),
                // Project.swift
                .file(
                    path: "Projects/Feature/\(name)/Project.swift",
                    templatePath: "Stencil/feature.stencil"
                )
            ]
        )
    }
}

/// 사용 예시:
/// 
/// 1. MVVM + Clean Architecture Feature 생성:
///    `tuist scaffold mvvm-clean --name Shopping`
/// 
/// 2. Coordinator Pattern Feature 생성:
///    `tuist scaffold coordinator --name Profile`
/// 
/// 3. Router Pattern Feature 생성:
///    `tuist scaffold router --name Settings`

