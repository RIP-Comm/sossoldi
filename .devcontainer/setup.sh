#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Docker creates a new cache volume as root. Keep it writable across rebuilds.
if [[ ! -w "$FVM_CACHE_PATH" ]]; then
  sudo chown -R "$(id -u):$(id -g)" "$FVM_CACHE_PATH"
fi

# The Android Feature installs as root. Gradle needs to install additional SDK
# components as the development user, and Flutter checks all SDK licenses.
if [[ ! -w "$ANDROID_HOME" ]]; then
  sudo chown -R "$(id -u):$(id -g)" "$ANDROID_HOME"
fi
# yes exits with SIGPIPE once sdkmanager finishes; check sdkmanager's status.
set +o pipefail
yes | sdkmanager --licenses >/dev/null
sdkmanager_status=${PIPESTATUS[1]}
set -o pipefail
if [[ "$sdkmanager_status" != 0 ]]; then
  exit "$sdkmanager_status"
fi

# CI mode avoids interactive prompts. Resolve Flutter only from .fvmrc.
CI=true fvm install --skip-pub-get
fvm flutter config --no-analytics --enable-linux-desktop --android-sdk "$ANDROID_HOME"
fvm dart --disable-analytics
fvm flutter precache --linux --android
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
