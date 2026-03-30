import Photos

public enum PermissionError: Error, CustomStringConvertible {
    case denied
    case restricted
    case unknown

    public var description: String {
        switch self {
        case .denied:
            return "Photos access denied. Open System Settings > Privacy & Security > Photos and grant access."
        case .restricted:
            return "Photos access is restricted by a device policy."
        case .unknown:
            return "Photos access returned an unknown status."
        }
    }
}

public func requestPhotosAccess() throws {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    switch status {
    case .authorized, .limited:
        return
    case .notDetermined:
        let semaphore = DispatchSemaphore(value: 0)
        var granted = false
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
            granted = newStatus == .authorized || newStatus == .limited
            semaphore.signal()
        }
        semaphore.wait()
        if !granted {
            throw PermissionError.denied
        }
    case .denied:
        throw PermissionError.denied
    case .restricted:
        throw PermissionError.restricted
    @unknown default:
        throw PermissionError.unknown
    }
}
