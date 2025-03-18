from typing import Any, Optional, Union
import pytest
import os
from appium import webdriver
from mobile_actions.mobile_actions import MobileActions
from utils.driver import Driver
from colorama import Fore, Style
from appium.options.common import AppiumOptions


PATH = lambda p: os.path.abspath(os.path.join(os.path.dirname(__file__), p))

def pytest_addoption(parser):
    parser.addoption("--local", action="store", help="Custom flag for local testing")

def set_session_info(local: Optional[str]):
    capabilities = Driver.get_capabilities(local)
    Driver.set_info(local, capabilities)


def set_driver() -> webdriver:
    appium_driver = webdriver.Remote(
        Driver.appium_url,
        options=AppiumOptions().load_capabilities(Driver.capabilities),
    )
    Driver.set_driver(appium_driver)
    return appium_driver


@pytest.fixture(scope="function")
def test_setup(request):
    test_name = request.node.name
    test_name = test_name.replace("test_", "")
    print()
    print(Fore.YELLOW + "***** Starting " + test_name + " *****")
    print(Style.RESET_ALL)

    appium_driver = set_driver()

    MobileActions.driver = appium_driver

    def teardown():
        print()
        print(Fore.YELLOW + "***** " + test_name + " completed *****")
        print(Style.RESET_ALL)
        appium_driver.quit()

    request.addfinalizer(teardown)
    request.cls.driver = appium_driver


@pytest.fixture(scope="session")
def driver_setup(request):
    set_session_info(request.config.getoption("--local"))