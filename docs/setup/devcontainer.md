---
title: Dev Container Setup
layout: default
nav_order: 6
parent: Setup Guide
---

# Dev Container Setup

The repository includes a Linux development container for Flutter development,
code generation, unit/widget tests, Linux desktop builds, and Android debug APKs.
It uses the official Ubuntu Dev Containers base image and published Features:

- Official [Java](https://github.com/devcontainers/features/tree/main/src/java)
  (Temurin 17) and
  [desktop-lite](https://github.com/devcontainers/features/tree/main/src/desktop-lite)
  (a browser-accessible Linux desktop).
- Community [asdf-package](https://github.com/devcontainers-extra/features/tree/main/src/asdf-package)
  with the [Flutter plugin](https://github.com/asdf-community/asdf-flutter),
  [Android SDK](https://github.com/CASL0/devcontainer-features/tree/main/src/android-sdk),
  and [apt-packages](https://github.com/rocker-org/devcontainer-features/tree/main/src/apt-packages).

Flutter is pinned to the version in `.fvmrc`. The container provides `flutter` and
`dart` directly on `PATH`; you do not need to install FVM inside it. When updating
`.fvmrc`, update the Flutter Feature version and the VS Code SDK path in
`.devcontainer/devcontainer.json`, then rebuild the container. Setup checks that
the installed Flutter version matches `.fvmrc`.

## Open in VS Code

1. Install Docker and the VS Code **Dev Containers** extension.
2. Clone your fork and open the repository folder in VS Code.
3. Run **Dev Containers: Reopen in Container** from the command palette.
4. Wait for setup to download dependencies and generate the ignored `*.g.dart`
   files. The first build downloads several GB of SDKs, including the Android NDK.

The configuration targets an x86-64 Docker host, matching the Android Linux SDK
tools and Flutter plugin downloads.

## Build and test with the CLI

Install the [Dev Container CLI](https://github.com/devcontainers/cli):

```sh
npm install -g @devcontainers/cli
```

From the repository root on your host:

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash .devcontainer/verify.sh
```

The verification script runs setup/code generation, the CI formatting check,
static analysis, the complete Flutter test suite with CI's single-worker setting,
a Linux release build, and an Android debug build with the `default` flavor.
It stops at the first failing check. To run checks independently:

```sh
flutter analyze
flutter test --concurrency=1
flutter build linux --release
flutter build apk --debug --flavor default
```

Run these commands in the container terminal, or prefix them with
`devcontainer exec --workspace-folder .` on your host. After editing annotated
models or providers, regenerate code with:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Artifacts are written to `build/linux/x64/release/bundle/` and
`build/app/outputs/flutter-apk/app-default-debug.apk`.

## Run the app

Inside the container:

```sh
dbus-run-session -- flutter run -d linux
```

Open **http://localhost:6080/vnc.html** on the Docker host and select **Connect**
to see the app. Port 6080 is published to the host's loopback interface, so the
address stays the same when the container is recreated. VS Code can also forward
port 6080 when connecting to a remote Docker host. This works without forwarding your host's
X11 socket. The official desktop Feature sets up the display; `dbus-run-session`
provides the session bus needed by the Linux notification plugin when launching
from a VS Code or CLI terminal.

For Android, use a reachable external device/emulator with wireless ADB:

```sh
adb pair DEVICE_IP:PAIRING_PORT
adb connect DEVICE_IP:DEBUG_PORT
flutter devices
flutter run -d DEVICE_ID --flavor default
```

The device and container must be able to reach each other over the network.
An Android emulator and USB passthrough are not configured by default.

## Platform-specific checks

- Android **release** APKs/app bundles use the existing signing configuration and
  require your own `android/key.properties` and keystore, as in CI. Debug builds
  use the generated debug keystore and do not require release secrets.
- iOS and macOS builds require macOS/Xcode; Windows builds require Windows.
- The separate Python/Appium mobile end-to-end suite requires a running Appium
  server, a configured device, and an installed app. Follow
  [its README](../../test/e2e/README.md) for that setup. `flutter test` runs the
  repository's Dart/Flutter tests without a mobile device.
- `flutter doctor -v` can report missing Android Studio or Chrome. Neither is
  required for the Linux/Android CLI workflow above.
