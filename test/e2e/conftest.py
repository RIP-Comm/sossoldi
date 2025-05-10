import pytest
from _pytest.config.argparsing import Parser
from _pytest.python import Function
from lib.fixtures import session_setup_teardown, test_setup  # noqa F401


def pytest_addoption(parser: Parser) -> None:
    parser.addoption("--local", action="store", help="Custom flag for local testing")


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item: Function) -> None:
    # Execute all other hooks to obtain the report object
    outcome = yield
    report = outcome.get_result()

    # Attach the report to the item for later access in fixtures
    setattr(item, f"rep_{report.when}", report)
