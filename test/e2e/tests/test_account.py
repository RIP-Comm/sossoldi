from lib.configuration import configuration
from lib.enums import Platform
from pages.dashboard_page import DashboardPage
from pages.manage_account_page import ManageAccountPage
from pages.onboarding_page import OnboardingPage


class TestAccount:
    def test_create_account(self):
        """
        Verify the account creation and subsequent display in the dashboard.
        """
        onboarding = OnboardingPage()
        if configuration.platform == Platform.ANDROID:
            onboarding.skip_onboarding()
        dashboard = DashboardPage()
        dashboard.create_account()
        manage_account = ManageAccountPage()
        manage_account.add_account_info("account name", 1000)
        manage_account.confirm_creation()
        assert dashboard.check_account("account name", 1000)
