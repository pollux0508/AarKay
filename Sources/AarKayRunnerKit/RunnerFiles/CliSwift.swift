import Foundation

/// main.swift file for `AarKayRunner`.
struct CliSwift {
    /// The contents.
    static let contents = """
    import AarKay
    import Foundation

    let url = URL(fileURLWithPath: CommandLine.arguments[2])

    let options = AarKayOptions(
        force: CommandLine.arguments.contains("--force"),
        verbose: CommandLine.arguments.contains("--verbose"),
        dryrun: CommandLine.arguments.contains("--dryrun"),
        exitOnError: CommandLine.arguments.contains("--exitOnError")
    )
    AarKay(url: url, options: options).bootstrap()

    """
}
