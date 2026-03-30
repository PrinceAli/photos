# Photos CLI Tools

Command-line tools for managing the macOS Photos library.

## Tools

### `export-photos`

Export photos (and optionally videos) from the macOS Photos library by date range.

```
export-photos <start-date> <end-date> <destination> [--verbose] [--include-videos]
```

**Arguments:**
- `start-date` — Start date in `YYYY-MM-DD` format
- `end-date` — End date in `YYYY-MM-DD` format (inclusive)
- `destination` — Folder to export files into (created if needed)

**Flags:**
- `--verbose`, `-v` — Print each exported filename
- `--include-videos` — Include video files in the export

### Examples

Export all photos from 2024:
```
swift run ExportPhotos 2024-01-01 2024-12-31 ~/Desktop/export
```

Export photos and videos from a trip with verbose output:
```
swift run ExportPhotos 2024-06-10 2024-06-20 ~/Desktop/trip --include-videos -v
```

## Build

```
make build     # debug build
make release   # optimized release build
```

## Requirements

- macOS 13+
- Swift 6+
- Photos library access (you'll be prompted on first run)
