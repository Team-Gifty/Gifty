#!/bin/sh

set -e

echo "=========================================="
echo "POST-CLONE SCRIPT IS RUNNING!"
echo "=========================================="

# 현재 스크립트 위치 기준으로 경로 설정
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_ROOT="$(cd "$PROJECT_ROOT/.." && pwd)"

echo "Script dir: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"
echo "Workspace root: $WORKSPACE_ROOT"

# 모든 클론된 저장소 확인
echo "=== Available repositories ==="
ls -la "$WORKSPACE_ROOT" || true
echo "=============================="

mkdir -p "$PROJECT_ROOT/Config"

# 가능한 모든 xcconfig 저장소 경로 시도
POSSIBLE_PATHS=(
    "$WORKSPACE_ROOT/Gifty_XCConfig"
    "$WORKSPACE_ROOT/gifty_xcconfig"
    "$WORKSPACE_ROOT/XCConfig"
    "$WORKSPACE_ROOT/xcconfig"
)

FOUND=false

for XCCONFIG_REPO in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$XCCONFIG_REPO" ]; then
        echo "Found repo at: $XCCONFIG_REPO"
        echo "Contents:"
        ls -la "$XCCONFIG_REPO" || true

        if [ -f "$XCCONFIG_REPO/Config.xcconfig" ]; then
            cp "$XCCONFIG_REPO/Config.xcconfig" "$PROJECT_ROOT/Config/Config.xcconfig"
            echo "Config copied from root"
            FOUND=true
            break
        elif [ -f "$XCCONFIG_REPO/Config/Config.xcconfig" ]; then
            cp "$XCCONFIG_REPO/Config/Config.xcconfig" "$PROJECT_ROOT/Config/Config.xcconfig"
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

if [ -f "$PROJECT_ROOT/Config/Config.xcconfig" ]; then
    echo "Config ready ($(wc -c < "$PROJECT_ROOT/Config/Config.xcconfig") bytes)"
else
    echo "Error: Config setup failed"
    exit 1
fi

echo "Post-clone completed"
