import logging

import pytest
from _pytest.fixtures import SubRequest
from lib.configuration import configuration
from lib.enums import Platform

import lib.constants as constants


@pytest.fixture(scope="session", autouse=True)
def session_setup_teardown(request: SubRequest) -> None:
    """
    Setup and teardown the testing environment.
    On setup: read args and init the test configuration accordingly.
    On teardown: quit the webdriver.
    """
    logging.debug("reading command line args")
    local = request.config.getoption("--local")

    if local == "android":
        tested_platform = Platform.ANDROID
    elif local == "ios":
        tested_platform = Platform.IOS
    else:
        if local is not None:
            raise ValueError(f"The local argument must be in {list(Platform)}; got {local} instead")

        logging.warning(f"'--local' parameter not set, running with default os: {constants.DEFAULT_PLATFORM.value}")
        tested_platform = Platform.ANDROID

    configuration.__init__(platform=tested_platform, rootpath=request.config.rootpath)
    logging.info("test configuration has been created")

    yield

    logging.info("quitting configuration")
    configuration.quit()


@pytest.fixture(scope="function", autouse=True)
def test_setup(request: SubRequest) -> None:
    test_name = request.node.name.replace("test_", "")
    logging.info(f"***** starting test: {test_name} *****")

    configuration.driver.start_recording()

    yield

    # Access the test reports
    setup_report = getattr(request.node, "rep_setup", None)
    call_report = getattr(request.node, "rep_call", None)
    teardown_report = getattr(request.node, "rep_teardown", None)

    # Determine if the test has failed or encountered an error
    if any(report and report.failed for report in [setup_report, call_report, teardown_report]):
        if configuration.driver.is_recording:
            configuration.driver.stop_recording(file_name=test_name)
            pass

        logging.error(f"***** {test_name} failed *****")
    else:
        logging.info(f"***** {test_name} passed *****")
