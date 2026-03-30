.PHONY: build release test clean run

build:
	swift build

release:
	swift build -c release

test:
	swift build
	@echo "Build succeeded."

clean:
	swift package clean

run:
	swift run ExportPhotos $(ARGS)

test-help: build
	.build/debug/ExportPhotos --help

export-yesterday: build
	@mkdir -p ~/tmp/yesterday
	.build/debug/ExportPhotos $$(date -v-1d +%Y-%m-%d) $$(date -v-1d +%Y-%m-%d) ~/tmp/yesterday --verbose

export-last-week: build
	@mkdir -p ~/tmp/last-week
	.build/debug/ExportPhotos $$(date -v-7d +%Y-%m-%d) $$(date -v-1d +%Y-%m-%d) ~/tmp/last-week --verbose

export-last-month: build
	@mkdir -p ~/tmp/last-month
	.build/debug/ExportPhotos $$(date -v-1m +%Y-%m-%d) $$(date -v-1d +%Y-%m-%d) ~/tmp/last-month --verbose
