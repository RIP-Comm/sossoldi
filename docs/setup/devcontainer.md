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
- Community [GitHub Release](https://github.com/devcontainers-extra/features/tree/main/src/gh-release)
  to install the standalone [FVM](https://fvm.app/) binary,
  [Android SDK](https://github.com/CASL0/devcontainer-features/tree/main/src/android-sdk),
  and [apt-packages](https://github.com/rocker-org/devcontainer-features/tree/main/src/apt-packages).

FVM installs the Flutter version specified in `.fvmrc`, the single source of truth
for the project's Flutter version. Use `fvm flutter` and `fvm dart` inside the
container, matching the project's FVM workflow. VS Code uses the project-local
`.fvm/flutter_sdk` symlink rather than a version-specific SDK path.

After updating `.fvmrc` or switching to a branch with a different Flutter version,
run `bash .devcontainer/setup.sh` again. No image rebuild is needed just to change
Flutter versions, although a new Flutter release may require updated Android or
Linux dependencies. The FVM tool version is pinned separately in the Feature
configuration.

Downloaded Flutter SDKs are stored in a Docker volume named
`<repository-folder>-fvm`, mounted at `/home/vscode/fvm`. Recreating the container
reuses this cache. The first setup needs internet access to download Flutter and
project dependencies.

## Open in VS Code

1. Install Docker and the VS Code **Dev Containers** extension.
2. Clone your fork and open the repository folder in VS Code.
3. Run **Dev Containers: Reopen in Container** from the command palette.
4. Wait for setup to download dependencies and generate the ignored `*.g.dart`
   files. The first build downloads several GB of SDKs, including the Android NDK.

The configuration targets an x86-64 Docker host, matching the Android Linux SDK
tools and the selected FVM binary.

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
fvm flutter analyze
fvm flutter test --concurrency=1
fvm flutter build linux --release
fvm flutter build apk --debug --flavor default
```

Run these commands in the container terminal, or prefix them with
`devcontainer exec --workspace-folder .` on your host. After editing annotated
models or providers, regenerate code with:

```sh
fvm dart run build_runner build --delete-conflicting-outputs
```

Artifacts are written to `build/linux/x64/release/bundle/` and
`build/app/outputs/flutter-apk/app-default-debug.apk`.

## Run the app

Inside the container:

```sh
dbus-run-session -- fvm flutter run -d linux
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
fvm flutter devices
fvm flutter run -d DEVICE_ID --flavor default
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
  [its README](../../test/e2e/README.md) for that setup. `fvm flutter test` runs the
  repository's Dart/Flutter tests without a mobile device.
- `fvm flutter doctor -v` can report missing Android Studio or Chrome. Neither is
  required for the Linux/Android CLI workflow above.
