import ProjectDescription

public extension TargetDependency {
    enum SPM {}
}

public extension TargetDependency.SPM {
    static let Alamofire = TargetDependency.external(name: "Alamofire")
    static let NukeUI = TargetDependency.external(name: "NukeUI")
}
