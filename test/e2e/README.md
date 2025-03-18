# Appium cross-platoform testing project

## Introduction
Welcome to our mobile testing project! This README file will guide you through the project structure, organization, and best practices for contributing to the project.

## Requirements

* Python 3.12.x installed
* Appium 2.x installed

If you are missing one or both you can check our [guide](installation_guide.md)

## Installation

1. Create a virtual environment
    ```sh
    python3 -m venv pyenv
    ```
2. Activate it
    ```sh
    source pyenv/bin/activate
    ```
3. Install dependencies
    ```sh
    pip install -r requirements.txt
    ```

## How to run the tests

1. Make sure that the device information inside `platform_config.yaml` are correct (you can see an example in `platform_config_example.yaml`)
2. Open your terminal and start the Appium server by typing:
    ```sh
    appium
    ```
3. Make sure that the app under test is installed in the device and is specified inside `local.yml`
4. Comeback to your IDE and activate the virual environment: 
   (if you already see (pyenv) before your username in the terminal you can skip this step)
    ```sh
    source pyenv/bin/activate
    ```
5. Run the following command to run the entire test suite on Android
    ```sh
    pytest -s tests --driver Remote --local android
    ```
    Run the following command to run the entire test suite on iOS
    ```sh
    pytest -s tests --driver Remote --local ios
    ```
**NOTE:** if you want to run a single file run:
    ```sh
    pytest -s tests/test_file.py --driver Remote --local android
    ```

## Project Structure

### Mobile actions
The *mobile_actions* folder houses essential classes for testing across different platforms. Here's what you'll find inside:

- mobile_actions: Contains basic actions that can be performed across all platforms. If a new action needs to be added, start here and then extend to platform-specific classes only if necessary.
- android_mobile_actions: Contains specific implementation of some actions for Android platform.
- ios_mobile_actions: Contains specific implementation of some actions for iOS platform.

### pages
In the pages folder, you'll find actions that are specific to each page of the application. Each page should have its own file with locators defined inside the __init__ method. 
The driver setup is standard, always set as self.driver = Driver.driver. After this you will be able to use all the actions that are inside the BaseTest class (Ex. *self.driver.click(self.button)*)

### platform_config.yam
This file contains the configuration necessary for running the tests.

### tests
All the actual tests reside in this folder. Here are some guidelines for writing tests:

- Use page objects for each test.
- Only perform actions using the page object without directly using gestures from mobile_actions.

### utils
The utils folder holds miscellaneous functions that are needed but don't fit into any specific category.

### conftest.py
conftest.py is where you'll find all the setup and teardown procedures that need to be executed before and after each test session and test.