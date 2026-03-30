# Photos CLI Tools

## Build & Test

```
make build    # debug build
make release  # optimized build
make test     # build and verify
make clean    # remove build artifacts
```

## Project Layout

- `Sources/PhotosCore/` — shared library (PhotoKit helpers, permissions, date parsing)
- `Sources/ExportPhotos/` — `export-photos` CLI tool

## Conventions

- Swift 6, macOS 13+
- Swift Package Manager for builds
- `swift-argument-parser` for CLI flags
- Info.plist embedded via linker flags (CLI has no app bundle)
