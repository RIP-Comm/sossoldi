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

- `mobile_actions.py`: Contains basic actions that can be performed across all platforms. If a new action needs to be added, start here and then extend to platform-specific classes only if necessary.
- `android/android_mobile_actions.py`: Contains specific implementation of some actions for Android platform.
- `ios/ios_mobile_actions.py`: Contains specific implementation of some actions for iOS platform.

### pages
In the pages folder, you'll find actions that are specific to each page of the application. Each page should have its own file with locators defined inside the __init__ method.

### platform_config.yam
This file contains the configuration necessary for running the tests.

### tests
All the actual tests reside in this folder. Here are some guidelines for writing tests:

- Use [page objects](https://medium.com/@aifakhri/page-object-models-implementation-with-pytest-b9673744b8c0) for each test.
- Only perform actions using the page object without directly using gestures from mobile_actions.
- Use enums wherever it's needed, avoid hard-coded strings and data

### lib
The lib folder holds different files used to support the test script development:
- `configuration.py`: defines the test configuration object. It is initialized when the test session starts and inherits singleton properties
- `constants.py`: global constants to support the scripts should be put here
- `enums.py`: enumerators to support the scripts should be put here
- `fixtures.py`: [pytest fixtures](https://docs.pytest.org/en/stable/explanation/fixtures.html) are collected here
- `utilities.py`: the file holds miscellaneous functions that are needed but don't fit into any specific category.

### conftest.py
`conftest.py` is where you'll find all the hooks to extend the standard pytest behavior.