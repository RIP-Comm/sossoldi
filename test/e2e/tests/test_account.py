from lib.configuration import Configuration
from lib.enums import Os
from pages.dashboard_page import DashboardPage
from pages.manage_account_page import ManageAccountPage
from pages.onboarding_page import OnboardingPage


class TestAccount:
    def test_create_account(self):
        onboarding = OnboardingPage()
        if Configuration().os == Os.ANDROID:
            onboarding.skip_onboarding()
        dashboard = DashboardPage()
        dashboard.create_account()
        manage_account = ManageAccountPage()
        manage_account.add_account_info("account name", 1000)
        manage_account.confirm_creation()
        assert dashboard.check_account("account name", 1000)
