#!/bin/sh

set -e

echo "=========================================="
echo "POST-CLONE SCRIPT IS RUNNING!"
echo "=========================================="

# 현재 스크립트 위치 기준으로 경로 설정
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Script dir: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/Config"

# 환경 변수에서 Config.xcconfig 생성
echo "Creating Config.xcconfig from environment variables..."

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_KEY" ] || [ -z "$KAKAO_APP_KEY" ]; then
    echo "Error: Required environment variables not set"
    echo "Please set SUPABASE_URL, SUPABASE_KEY, KAKAO_APP_KEY in Xcode Cloud environment"
    exit 1
fi

cat > "$PROJECT_ROOT/Config/Config.xcconfig" << EOF
SLASH = /
SUPABASE_URL = $SUPABASE_URL
SUPABASE_KEY = $SUPABASE_KEY
KAKAO_APP_KEY = $KAKAO_APP_KEY
EOF

if [ -f "$PROJECT_ROOT/Config/Config.xcconfig" ]; then
    echo "Config.xcconfig created successfully ($(wc -c < "$PROJECT_ROOT/Config/Config.xcconfig") bytes)"
else
    echo "Error: Config setup failed"
    exit 1
fi

echo "Post-clone completed"
