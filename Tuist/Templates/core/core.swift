import ProjectDescription
import Foundation
import MyAppPlugIn

private let name = Template.Attribute.required("name")

private var basePath: String { "Projects/Core/\(name)" }

private let template = Template(
    description: "Core Module Template",
    attributes: [name],
    items: [
        ModuleTemplate.core(path: basePath).item,
        ModuleTemplate.default(path: basePath).item
    ].flatMap { $0 }
)

