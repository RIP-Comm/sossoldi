---
title: Setup Guide
layout: default
nav_order: 4
has_children: true
---
# Setup Guide

## Step 1: Install Git

Download and install Git from [https://git-scm.com/](https://git-scm.com/).

## Step 2: Install Docker

For linux system follow [this](https://docs.docker.com/engine/install/ubuntu/)

## Step 3: Set Up an IDE

Choose one of the following:

### Using Visual Studio Code:

1. Download and install Visual Studio Code from [https://code.visualstudio.com/](https://code.visualstudio.com/).
2. Install the Flutter and Dart extensions.

#### Coding inside Docker Container

##### Android

To help contributors working with the same dependencies and SDKs, in .devcontainer folder there a Dockerfile with all the necessary for coding.

1. On VSCode install [Dev Container exentension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers). This extension allows you to coding inside a Docker container directly in VSCode.

2. Open ```.devcontainer/devcontainer.json``` and modify the *args* section, if needed. For example you may want use a different *ANDROID_NDK_VERSION* version (in that case you must update *ANDROID_NDK_SHA256* also)

3. Once the extension in installed at the bottom left corner of VSCode window click on "Open a Remote Window" then click on "Reopen in Container". This will create a Docker container inside which you'll have all the necessary dependencies for coding.

### Using IntelliJ IDEA or Android Studio:

1. Download and install IntelliJ IDEA or Android Studio.
2. Install the Flutter and Dart plugins.

## Step 4: Fork the repository

This is very simple, just go to the Sossoldi repository on GitHub and click on the “Fork” on the top right corner. By doing this you will create a copy of the repository on your account and it will allow you to make changes without affecting the main repository.

## (Optional) Download GitHub Desktop

If you are unfamiliar with Git you might want to use GitHub Desktop.

1. Go to this link and download GitHub Desktop. With this it will be easier to manage and submit the changes that you will do. After the download, set up your account.
2. Now comeback to your repository on GitHub and click on Code -> Open with GitHub Desktop
3. This will open GitHub Desktop and it should ask you to add the path in which you want to save the folder with the project. Then click on clone.