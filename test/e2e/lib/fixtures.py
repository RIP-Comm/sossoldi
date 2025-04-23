import pytest
from _pytest.fixtures import SubRequest
from colorama import Fore, Style
from lib.configuration import Configuration
from lib.enums import Os


@pytest.fixture(scope="session", autouse=True)
def session_setup_teardown(request: SubRequest) -> None:
    local = request.config.getoption("--local")

    if local == "android":
        tested_os = Os.ANDROID
    elif local == "ios":
        tested_os = Os.IOS
    else:
        raise ValueError(f"The local argument must be in {list(Os)}; got {local} instead")

    Configuration(os=tested_os, rootpath=request.config.rootpath)
    yield
    Configuration().quit()


@pytest.fixture(scope="function", autouse=True)
def test_setup(request: SubRequest) -> None:
    test_name = request.node.name.replace("test_", "")
    config = Configuration()
    print(Fore.YELLOW + f"***** Starting {test_name} *****")
    print(Style.RESET_ALL)

    config.driver.start_recording()

    yield

    # Access the test reports
    setup_report = getattr(request.node, "rep_setup", None)
    call_report = getattr(request.node, "rep_call", None)
    teardown_report = getattr(request.node, "rep_teardown", None)

    # Determine if the test has failed or encountered an error
    if any(report and report.failed for report in [setup_report, call_report, teardown_report]):
        if config.driver.is_recording:
            # Driver.driver.stop_recording(test_name)
            pass
        print()
        print(Fore.RED + f"***** {test_name} failed. Video recording saved. *****")
    else:
        print()
        print(Fore.GREEN + f"***** {test_name} passed. *****")
    print(Style.RESET_ALL)
