#!/bin/sh

set -e

echo "🚀 Starting Xcode Cloud post-clone script..."

# 현재 디렉토리 확인
echo "📂 Current directory: $(pwd)"
echo "📦 Workspace: $CI_WORKSPACE"

# Config 파일이 있는지 확인 (private repo에서 가져온 경우)
if [ -f "$CI_WORKSPACE/Gifty_iOS/Config/Config.xcconfig" ]; then
    echo "✅ Config.xcconfig found"
else
    echo "⚠️ Config.xcconfig not found - make sure it's properly configured"
fi

# SPM 의존성 확인
if [ -d "$CI_WORKSPACE/Gifty_iOS/.build" ]; then
    echo "✅ Using cached SPM dependencies"
else
    echo "📦 SPM dependencies will be resolved during build"
fi

echo "✅ Post-clone script completed successfully"
