import ProjectDescription

let workspace = Workspace(
    name: "MyApp",
    projects: [
        "Projects/MyApp",
        "Projects/Core/**",
        "Projects/DesignSystem",
        "Projects/Feature/**"
    ]
)
