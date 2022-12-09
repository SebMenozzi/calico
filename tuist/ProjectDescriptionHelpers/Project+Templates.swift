import ProjectDescription

public extension Project {

    static func createProject(
        name: String,
        packages: [Package],
        targets: [Target]
    ) -> Self {
        return .init(
            name: name,
            organizationName: "Calico",
            options: defaultOptions(),
            packages: packages,
            settings: .defaultProjectSettings(),
            targets: targets,
            resourceSynthesizers: Self.defaultResourceSynthesizers()
        )
    }

    private static func defaultOptions() -> Project.Options {
        return .options(developmentRegion: "en")
    }

    private static func defaultResourceSynthesizers() -> [ResourceSynthesizer] {
        return [
            .assets(),
            .fonts(),
            .strings(),
            .files(extensions: ["aac", "txt"])
        ]
    }
}
