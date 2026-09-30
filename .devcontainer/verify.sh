#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

bash .devcontainer/setup.sh
dart format --set-exit-if-changed --output=none .
flutter analyze
flutter test --concurrency=1
flutter build linux --release
flutter build apk --debug --flavor default
