import pytest

from pages.dashboard_page import DashboardPage
from pages.onboarding_page import OnboardingPage

@pytest.mark.usefixtures("driver_setup", "test_setup")
class TestOnboarding():
    def test_skip_onboarding(self):
        onboarding = OnboardingPage()
        onboarding.skip_onboarding()
        dashboard = DashboardPage()
        assert dashboard.check_empty_dashboard()
