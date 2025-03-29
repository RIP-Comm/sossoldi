import pytest

from pages.dashboard_page import DashboardPage
from pages.onboarding_page import OnboardingPage
from pages.manage_account_page import ManageAccountPage
from utils.utils import Utils
from utils.driver import Driver

@pytest.mark.usefixtures("driver_setup", "test_setup")
class TestAccount():
    def test_create_account(self):
        onboarding = OnboardingPage()
        if Driver.os == Utils.ANDROID:
            onboarding.skip_onboarding()
        dashboard = DashboardPage()
        dashboard.create_account()
        manage_account = ManageAccountPage()
        manage_account.add_account_info("account name", 1000)
        manage_account.confirm_creation()
        assert dashboard.check_account("account name", 1000)
