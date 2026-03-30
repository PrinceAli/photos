import ArgumentParser
import Foundation
import PhotosCore

@main
struct ExportPhotos: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "export-photos",
        abstract: "Export photos from the macOS Photos library by date range."
    )

    @Argument(help: "Start date (YYYY-MM-DD).")
    var startDate: String

    @Argument(help: "End date inclusive (YYYY-MM-DD).")
    var endDate: String

    @Argument(help: "Destination folder path.")
    var destination: String

    @Flag(name: .shortAndLong, help: "Print each exported filename.")
    var verbose = false

    @Flag(name: .long, help: "Include video files in the export.")
    var includeVideos = false

    mutating func run() throws {
        let start = try parseDate(startDate)
        let end = endOfDay(try parseDate(endDate))

        guard start <= end else {
            throw ValidationError("Start date must be before or equal to end date.")
        }

        let destURL = URL(fileURLWithPath: destination)
        try FileManager.default.createDirectory(at: destURL, withIntermediateDirectories: true)

        try requestPhotosAccess()

        let assets = fetchAssets(from: start, to: end, includeVideos: includeVideos)
        if assets.isEmpty {
            print("No photos found in the given date range.")
            return
        }

        print("Found \(assets.count) item(s). Exporting to \(destination) ...")

        var existingFilenames = Set<String>()
        var exportedCount = 0
        var errorCount = 0

        for assetInfo in assets {
            do {
                _ = try exportAsset(
                    assetInfo, to: destURL, existingFilenames: &existingFilenames, verbose: verbose)
                exportedCount += 1
            } catch {
                errorCount += 1
                print("  Error: \(error)")
            }
        }

        print("Done. Exported \(exportedCount) file(s).", terminator: "")
        if errorCount > 0 {
            print(" \(errorCount) error(s).", terminator: "")
        }
        print()
    }
}
