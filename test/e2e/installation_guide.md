# Comprehensive Installation Guide

This guide provides step-by-step instructions for setting up a development environment on Mac and Windows platforms.

# Mac Installation Guide

## Java Installation
1. **Check Current Java Version:**
   - Open Terminal and run: `javac --version`
   - If you already have Java 11+ installed, you can skip to the next section

2. **Install Java:**
   - Download the latest LTS version from [Oracle's website](https://www.oracle.com/java/technologies/downloads/)
   - Run the installer and follow the on-screen instructions

3. **Set JAVA_HOME Environment Variable:**
   - Navigate to your home directory: `cd ~/`
   - Open the `.zshrc` file: `nano ~/.zshrc`
   - Add the following lines at the top:
     ```
     export JAVA_HOME=$(/usr/libexec/java_home)
     export PATH="${JAVA_HOME}/bin:$PATH"
     ```
   - Save and exit (press `Control + X`, then `Y`, then `Enter`)
   - Apply the changes: `source ~/.zshrc`
   - Verify by running: `echo $JAVA_HOME`

## Node.js Installation
1. Open Terminal and run: `brew install node`
2. Verify installation by running: `node --version`

## Appium Installation
1. Open Terminal and run: `npm install -g appium`
2. Install the Android driver: `appium driver install uiautomator2`
3. For iOS testing, install the XCUITest driver: `appium driver install xcuitest`

## Android Studio Installation
1. Download Android Studio from [Android's website](https://developer.android.com/studio)
2. Run the installer and follow the on-screen instructions
3. After installation, open Android Studio and follow the steps to install the Android SDK and Platform
4. From the starting screen, go to **More Tools > SDK Manager > SDK Tools**
5. Ensure the following tools are selected and up-to-date:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
6. Click **Apply** to install any unselected tools

## Android Environment Variables
1. Navigate to your home directory: `cd ~/`
2. Open the `.zshrc` file: `nano ~/.zshrc`
3. Add the following lines:
   ```
   export ANDROID_HOME=${HOME}/Library/Android/sdk
   export PATH="${ANDROID_HOME}/platforms-tools:${ANDROID_HOME}/cmdline-tools:$PATH"
   ```
4. Save and exit (press `Control + X`, then `Y`, then `Enter`)
5. Apply the changes: `source ~/.zshrc`
6. Verify by running: `echo $ANDROID_HOME`

## Android Device Setup
1. **Enable USB Debugging on your device:**
   - Find the Build Number option (usually under Settings > About phone)
   - Tap the Build Number seven times until you see "You are now a developer!"
   - Go back to Settings and open Developer Options
   - Enable USB Debugging
   - Connect your device to your computer
   - Accept the USB debugging prompt on your device
   - Verify connection by running: `adb devices`

## iOS Setup
1. **Install Xcode:**
   - Install Xcode from the Mac App Store
   - Open Terminal and run: `xcode-select --install`

2. **Install Additional Dependencies:**
   - (Optional) Install xcpretty: `gem install xcpretty`
   - Install Carthage: `brew install Carthage`

3. **Real Device Setup:**
   - For paid Apple Developer accounts:
     - [Basic Automatic Configuration](https://appium.github.io/appium-xcuitest-driver/latest/preparation/prov-profile-basic-auto/)
     - [Basic Manual Configuration](https://appium.github.io/appium-xcuitest-driver/latest/preparation/prov-profile-basic-manual/)
   - For free Apple Developer accounts:
     - [Full Manual Configuration](https://appium.github.io/appium-xcuitest-driver/latest/preparation/prov-profile-full-manual/)

## Python Setup
1. **Check Current Python Version:**
   - Open Terminal and run: `python --version`
   - If you already have Python 3.10 or greater, you can skip this section

2. **Install Homebrew:**
   - Run: `brew update`
   - If Homebrew is not installed, run:
     ```
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     ```
   - Follow the terminal instructions to add Homebrew to your PATH

3. **Install pyenv and Dependencies:**
   - Run: `brew install pyenv`
   - Run: `brew install pyenv-virtualenv`
   - Install dependencies: `brew install openssl readline sqlite3 xz zlib tcl-tk libffi`
   - Open `.zshrc`: `nano ~/.zshrc`
   - Add the following lines:
     ```
     export PYENV_ROOT="$HOME/.pyenv"
     command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
     eval "$(pyenv init -)"
     eval "$(pyenv virtualenv-init -)"
     export CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl)"
     export PATH="$PYENV_ROOT/shims:$PATH"
     export PATH="$PYENV_ROOT/bin:$PATH"
     ```
   - Save and exit
   - Apply changes: `source ~/.zshrc`

4. **Install Python 3.10:**
   - Run: `pyenv install 3.10`
   - Set as global: `pyenv global 3.10`
   - Verify: `python --version`

## Appium Inspector Installation
- Download the latest Mac version from [GitHub releases](https://github.com/appium/appium-inspector/releases)
- Install and run the application

# Windows Installation Guide

## Java Installation
1. **Download Java:**
   - Get the installation package from [Oracle's website](https://www.oracle.com/java/technologies/javase-downloads.html)
   - Run the installer and follow the on-screen instructions

2. **Set JAVA_HOME Environment Variable:**
   - Press **`Win + R`**, type `sysdm.cpl`, and hit **Enter**
   - Go to the **Advanced** tab and click **Environment Variables**
   - Under **System Variables**, click **New**
   - **Variable name:** `JAVA_HOME`
   - **Variable value:** Set it to your JDK installation path, for example:
     ```
     C:\Program Files\Java\jdk-XX.X.X
     ```
     _(Replace `jdk-XX.X.X` with your actual JDK version)_
   - Click **OK** to save

3. **Add Java to the System PATH:**
   - In the **Environment Variables** window, find **Path** under **System Variables**
   - Click **Edit**, then **New**, and add: `%JAVA_HOME%\bin`
   - Click **OK** to save

4. **Verify Installation:**
   - Close all Command Prompt windows
   - Restart your computer (or log out and log back in)
   - Open Command Prompt and run: `java -version`
   - The command should display the installed version

## Node.js Installation
1. Download the installer from [Node.js website](https://nodejs.org/en/download/)
2. Run the installer and follow the on-screen instructions
3. Verify installation by opening Command Prompt and running: `node --version`

## Appium Installation
1. Open Command Prompt and run: `npm install -g appium`
2. Verify installation by running: `appium`
3. Install the Android driver: `appium driver install uiautomator2`

## Android Studio Installation
1. Download Android Studio from [Android's website](https://developer.android.com/studio/)
2. Run the installer and follow the on-screen instructions
3. During installation, ensure you select the Android Virtual Device component
4. After installation, launch Android Studio
5. In the Welcome dialog, select **Configure > SDK Manager**
6. On the SDK Platforms tab, select at least one SDK
7. Switch to the SDK Tools tab and ensure the following are selected:
   - Android SDK Build-tools
   - Android SDK Platform-Tools
   - Intel x86 Emulator Accelerator (HAXM installer)
8. Copy the Android SDK Location value (you'll need it later)
9. Close the SDK Manager

## Android Virtual Device Setup
1. In the Android Studio Welcome dialog, select **Configure > AVD Manager**
2. If the dialog doesn't list the device you need, click **Create Virtual Device**
3. Create the needed device emulator following the wizard

## Android Environment Variables
1. Open Control Panel and search for "environment variables"
2. Click **Environment Variables**
3. Under **System Variables**, click **New**
4. **Variable name:** `ANDROID_HOME`
5. **Variable value:** Set it to your Android SDK location (copied earlier)
6. Click **OK** to save
7. Restart your computer to apply changes

## Android Device Setup
1. **Enable USB Debugging on your device:**
   - Find the Build Number option (usually under Settings > About phone)
   - Tap the Build Number seven times until you see "You are now a developer!"
   - Go back to Settings and open Developer Options
   - Enable USB Debugging
   - Connect your device to your computer
   - Accept the USB debugging prompt on your device
   - Verify connection by opening Command Prompt and running: `adb devices`

## Appium Inspector Installation
1. Check the latest release and download the Windows version from [GitHub releases](https://github.com/appium/appium-inspector/releases)
2. Run the installer and follow the on-screen instructions
3. Complete the installation and start one of your Android Emulators to test