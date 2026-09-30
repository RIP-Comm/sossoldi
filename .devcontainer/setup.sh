#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

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

flutter config --no-analytics --enable-linux-desktop --android-sdk "$ANDROID_HOME"
dart --disable-analytics

expected_version=$(jq -r .flutter .fvmrc)
installed_version=$(flutter --version --machine | jq -r .frameworkVersion)
if [[ "$installed_version" != "$expected_version" ]]; then
  printf 'Flutter %s is required by .fvmrc; found %s. Update devcontainer.json and rebuild.\n' \
    "$expected_version" "$installed_version" >&2
  exit 1
fi

flutter precache --linux --android
flutter pub get
dart run build_runner build --delete-conflicting-outputs
