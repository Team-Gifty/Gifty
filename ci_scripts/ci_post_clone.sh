#!/bin/sh

set -e

echo "Starting post-clone script..."

echo "Workspace: $CI_WORKSPACE"

mkdir -p "$CI_WORKSPACE/Gifty_iOS/Config"

# xcconfig 저장소에서 설정 파일 복사
XCCONFIG_REPO="$CI_WORKSPACE/../Gifty_XCConfig"

if [ -d "$XCCONFIG_REPO" ]; then
    if [ -f "$XCCONFIG_REPO/Config.xcconfig" ]; then
        cp "$XCCONFIG_REPO/Config.xcconfig" "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig"
        echo "Config copied from root"
    elif [ -f "$XCCONFIG_REPO/Config/Config.xcconfig" ]; then
        cp "$XCCONFIG_REPO/Config/Config.xcconfig" "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig"
        echo "Config copied from Config dir"
    else
        echo "Error: Config.xcconfig not found"
        ls -la "$XCCONFIG_REPO" || true
        exit 1
    fi
else
    echo "Error: Gifty_XCConfig repo not found"
    echo "Add it as Additional Repository in Xcode Cloud"
    ls -la "$CI_WORKSPACE/.." || true
    exit 1
fi

if [ ! -f "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig" ]; then
    echo "Error: Config setup failed"
    exit 1
fi

echo "Config ready"
echo "Post-clone completed"
