#!/bin/zsh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$PROJECT_ROOT/Untitled Project.xcodeproj"
SCHEME_NAME="MyApp"
APP_NAME="SystemPulse"
RELEASE_DIRECTORY="$PROJECT_ROOT/build/release"
ARCHIVE_PATH="$RELEASE_DIRECTORY/$APP_NAME.xcarchive"
STAGING_DIRECTORY="$RELEASE_DIRECTORY/dmg-staging"
DMG_PATH="$RELEASE_DIRECTORY/$APP_NAME.dmg"

rm -rf "$RELEASE_DIRECTORY"
mkdir -p "$STAGING_DIRECTORY"

xcodebuild archive \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH"

ditto "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$STAGING_DIRECTORY/$APP_NAME.app"
ln -s /Applications "$STAGING_DIRECTORY/Applications"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIRECTORY" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

echo "Created $DMG_PATH"
