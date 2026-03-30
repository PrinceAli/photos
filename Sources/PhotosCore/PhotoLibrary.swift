import Foundation
import Photos

public struct AssetInfo: Sendable {
    public let asset: PHAsset
    public let originalFilename: String
}

public enum ExportError: Error, CustomStringConvertible {
    case fetchFailed(String)
    case writeFailed(String)

    public var description: String {
        switch self {
        case .fetchFailed(let detail):
            return "Failed to fetch asset: \(detail)"
        case .writeFailed(let detail):
            return "Failed to write file: \(detail)"
        }
    }
}

public func fetchAssets(from startDate: Date, to endDate: Date, includeVideos: Bool) -> [AssetInfo] {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(
        format: "creationDate >= %@ AND creationDate <= %@",
        startDate as NSDate,
        endDate as NSDate
    )
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

    var mediaTypes: [Int] = [PHAssetMediaType.image.rawValue]
    if includeVideos {
        mediaTypes.append(PHAssetMediaType.video.rawValue)
    }
    fetchOptions.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
        fetchOptions.predicate!,
        NSPredicate(format: "mediaType IN %@", mediaTypes),
    ])

    let result = PHAsset.fetchAssets(with: fetchOptions)

    var assets: [AssetInfo] = []
    result.enumerateObjects { asset, _, _ in
        let resources = PHAssetResource.assetResources(for: asset)
        let primaryResource = resources.first { $0.type == .photo || $0.type == .video }
            ?? resources.first
        let filename = primaryResource?.originalFilename ?? "unknown"
        assets.append(AssetInfo(asset: asset, originalFilename: filename))
    }
    return assets
}

public func exportAsset(
    _ assetInfo: AssetInfo, to destinationDir: URL, existingFilenames: inout Set<String>,
    verbose: Bool
) throws -> String {
    let resources = PHAssetResource.assetResources(for: assetInfo.asset)

    guard
        let resource = resources.first(where: { $0.type == .photo || $0.type == .video })
            ?? resources.first
    else {
        throw ExportError.fetchFailed("No resource found for asset \(assetInfo.asset.localIdentifier)")
    }

    let filename = uniqueFilename(assetInfo.originalFilename, existing: &existingFilenames)
    let fileURL = destinationDir.appendingPathComponent(filename)

    let options = PHAssetResourceRequestOptions()
    options.isNetworkAccessAllowed = true

    let semaphore = DispatchSemaphore(value: 0)
    var writeError: Error?

    PHAssetResourceManager.default().writeData(for: resource, toFile: fileURL, options: options) {
        error in
        writeError = error
        semaphore.signal()
    }
    semaphore.wait()

    if let error = writeError {
        throw ExportError.writeFailed("\(filename): \(error.localizedDescription)")
    }

    if verbose {
        print("  Exported: \(filename)")
    }

    return filename
}

public func uniqueFilename(_ name: String, existing: inout Set<String>) -> String {
    if !existing.contains(name) {
        existing.insert(name)
        return name
    }

    let url = URL(fileURLWithPath: name)
    let stem = url.deletingPathExtension().lastPathComponent
    let ext = url.pathExtension

    var counter = 2
    while true {
        let candidate = ext.isEmpty ? "\(stem) (\(counter))" : "\(stem) (\(counter)).\(ext)"
        if !existing.contains(candidate) {
            existing.insert(candidate)
            return candidate
        }
        counter += 1
    }
}
