# Guardicore_connector — macOS Guardicore Operations Toolbox — macOS Unified Remote Computing Toolbox
# ─────────────────────────────────────────────────
# Prerequisites: brew install xcodegen swiftlint

.PHONY: all generate build test lint clean dmg notarize

# ── Config ──────────────────────────────────────────────────────────────────
SCHEME        := Guardicore_connector
CONFIGURATION ?= Debug
DERIVED_DATA  := .build/DerivedData
ARCHIVE_PATH  := .build/Guardicore_connector.xcarchive
EXPORT_PATH   := .build/export
DMG_NAME      := Guardicore_connector.dmg

# ── Primary targets ──────────────────────────────────────────────────────────
all: generate build

generate:
	@echo "▶ Generating Xcode project..."
	xcodegen generate
	@echo "✓ Guardicore_connector.xcodeproj ready"

build: generate
	@echo "▶ Building ($(CONFIGURATION))..."
	xcodebuild build \
	  -scheme $(SCHEME) \
	  -configuration $(CONFIGURATION) \
	  -derivedDataPath $(DERIVED_DATA) \
	  -destination "platform=macOS" \
	  | xcpretty || xcodebuild build \
	    -scheme $(SCHEME) \
	    -configuration $(CONFIGURATION) \
	    -derivedDataPath $(DERIVED_DATA) \
	    -destination "platform=macOS"

test: generate
	@echo "▶ Running tests..."
	xcodebuild test \
	  -scheme $(SCHEME) \
	  -configuration Debug \
	  -derivedDataPath $(DERIVED_DATA) \
	  -destination "platform=macOS,arch=$(shell uname -m)" \
	  | xcpretty -r junit --output .build/test-results.xml || true

lint:
	@echo "▶ Linting..."
	swiftlint lint --config .swiftlint.yml

# ── Distribution ─────────────────────────────────────────────────────────────
archive: generate
	@echo "▶ Archiving (Release)..."
	xcodebuild archive \
	  -scheme $(SCHEME) \
	  -configuration Release \
	  -derivedDataPath $(DERIVED_DATA) \
	  -archivePath $(ARCHIVE_PATH) \
	  -destination "generic/platform=macOS"

dmg: archive
	@echo "▶ Building DMG..."
	bash scripts/build-dmg.sh $(ARCHIVE_PATH) $(EXPORT_PATH) $(DMG_NAME)

notarize: dmg
	@echo "▶ Notarizing..."
	bash scripts/notarize.sh $(EXPORT_PATH)/$(DMG_NAME)

clean:
	@echo "▶ Cleaning..."
	rm -rf $(DERIVED_DATA) $(ARCHIVE_PATH) $(EXPORT_PATH)
	@echo "✓ Clean complete"

# ── Helpers ──────────────────────────────────────────────────────────────────
open: generate
	open Guardicore_connector.xcodeproj

brew-deps:
	brew install xcodegen swiftlint xcpretty || true

version:
	@echo "Xcode: $$(xcodebuild -version | head -1)"
	@echo "Swift: $$(swift --version | head -1)"
	@echo "XcodeGen: $$(xcodegen --version)"
	@echo "SwiftLint: $$(swiftlint --version)"
