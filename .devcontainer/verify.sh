#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

bash .devcontainer/setup.sh
fvm dart format --set-exit-if-changed --output=none .
fvm flutter analyze
fvm flutter test --concurrency=1
fvm flutter build linux --release
fvm flutter build apk --debug --flavor default
