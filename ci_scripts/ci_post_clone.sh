#!/bin/sh

set -e

echo "Starting post-clone script..."
echo "Workspace: $CI_WORKSPACE"

# 모든 클론된 저장소 확인
echo "=== Available repositories ==="
ls -la "$CI_WORKSPACE/.." || true
echo "=============================="

mkdir -p "$CI_WORKSPACE/Gifty_iOS/Config"

# 가능한 모든 xcconfig 저장소 경로 시도
POSSIBLE_PATHS=(
    "$CI_WORKSPACE/../Gifty_XCConfig"
    "$CI_WORKSPACE/../gifty_xcconfig"
    "$CI_WORKSPACE/../XCConfig"
    "$CI_WORKSPACE/../xcconfig"
)

FOUND=false

for XCCONFIG_REPO in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$XCCONFIG_REPO" ]; then
        echo "Found repo at: $XCCONFIG_REPO"
        echo "Contents:"
        ls -la "$XCCONFIG_REPO" || true

        if [ -f "$XCCONFIG_REPO/Config.xcconfig" ]; then
            cp "$XCCONFIG_REPO/Config.xcconfig" "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig"
            echo "Config copied from root"
            FOUND=true
            break
        elif [ -f "$XCCONFIG_REPO/Config/Config.xcconfig" ]; then
            cp "$XCCONFIG_REPO/Config/Config.xcconfig" "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig"
            echo "Config copied from Config dir"
            FOUND=true
            break
        fi
    fi
done

if [ "$FOUND" = false ]; then
    echo "Error: Config.xcconfig not found in any repository"
    echo "Make sure Gifty_XCConfig is added as Additional Repository"
    exit 1
fi

if [ -f "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig" ]; then
    echo "Config ready ($(wc -c < "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig") bytes)"
else
    echo "Error: Config setup failed"
    exit 1
fi

echo "Post-clone completed"
