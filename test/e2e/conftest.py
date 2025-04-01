from typing import Any, Optional, Union
import pytest
import os
from appium import webdriver
from mobile_actions.mobile_actions import MobileActions
from utils.utils import Utils
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

@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    # Execute all other hooks to obtain the report object
    outcome = yield
    report = outcome.get_result()

    # Attach the report to the item for later access in fixtures
    setattr(item, f"rep_{report.when}", report)

@pytest.fixture(scope="function")
def test_setup(request):
    test_name = request.node.name.replace("test_", "")
    print()
    print(Fore.YELLOW + f"***** Starting {test_name} *****")
    print(Style.RESET_ALL)

    appium_driver = set_driver()
    MobileActions.driver = appium_driver
    Driver.driver.start_recording()

    yield appium_driver

    # Access the test reports
    setup_report = getattr(request.node, "rep_setup", None)
    call_report = getattr(request.node, "rep_call", None)
    teardown_report = getattr(request.node, "rep_teardown", None)

    # Determine if the test has failed or encountered an error
    if any(report and report.failed for report in [setup_report, call_report, teardown_report]):
        if MobileActions.is_recording:
            Driver.driver.stop_recording(test_name)
        print()
        print(Fore.RED + f"***** {test_name} failed. Video recording saved. *****")
    else:
        print()
        print(Fore.GREEN + f"***** {test_name} passed. *****")
    print(Style.RESET_ALL)

    appium_driver.quit()


@pytest.fixture(scope="session")
def driver_setup(request):
    MobileActions.date_time = Utils.get_date_time()
    set_session_info(request.config.getoption("--local"))