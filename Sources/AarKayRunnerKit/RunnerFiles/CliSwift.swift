import Foundation

/// main.swift file for `AarKayRunner`.
struct CliSwift {
    /// The contents.
    static let contents = """
    import Foundation
    import AarKay

    let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

    let options = AarKayOptions(
        force: CommandLine.arguments.contains("--force"),
        verbose: CommandLine.arguments.contains("--verbose"),
        dryrun: CommandLine.arguments.contains("--dryrun"),
        exitOnError: CommandLine.arguments.contains("--exitOnError")
    )
    AarKay(url: url, options: options).bootstrap()
    """
}
