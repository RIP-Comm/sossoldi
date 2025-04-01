from utils.driver import Driver
from selenium.webdriver.common.by import By
from utils.utils import Utils


class OnboardingPage:
    def __init__(self):
        self.driver = Driver.driver
        if Driver.os == Utils.ANDROID:
            self.__deny_notification = (By.ID, "com.android.permissioncontroller:id/permission_deny_button")
            self.__start_onboarding = (By.ACCESSIBILITY_ID, "START THE SET UP")
            self.__skip_budget = (By.ACCESSIBILITY_ID, "CONTINUE WITHOUT BUDGET  ")
            self.__skip_account = (By.ACCESSIBILITY_ID, "START FROM 0  ")
        elif Driver.os == Utils.IOS:
            self.__deny_notification = (By.ID, "")
            self.__start_onboarding = (By.ACCESSIBILITY_ID, "")
            self.__skip_budget = (By.ACCESSIBILITY_ID, "")
            self.__skip_account = (By.ACCESSIBILITY_ID, "")

    def skip_onboarding(self):
        self.driver.click(self.__deny_notification)
        self.driver.click(self.__start_onboarding)
        self.driver.click(self.__skip_budget)
        self.driver.click(self.__skip_account)