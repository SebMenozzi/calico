import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "Calico",
    projects: [
        "Targets",
        "Modules/**"
    ]
)
