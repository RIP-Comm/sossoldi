from utils.driver import Driver
from selenium.webdriver.common.by import By
from utils.utils import Utils


class ManageAccountPage:
    def __init__(self):
        self.driver = Driver.driver
        if Driver.os == Utils.ANDROID:
            self.__account_name = (By.XPATH, '//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.View/android.view.View/android.view.View/android.view.View/android.view.View[2]/android.widget.EditText[1]')
            self.__initial_balance = (By.XPATH, '//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.View/android.view.View/android.view.View/android.view.View/android.view.View[2]/android.widget.EditText[2]')
        elif Driver.os == Utils.IOS:
            self.__account_name = (By.ACCESSIBILITY_ID, "Account name")
            self.__initial_balance = (By.ACCESSIBILITY_ID, "Initial Balance")
        self.__create_account = (By.ACCESSIBILITY_ID, "CREATE ACCOUNT")

    def add_account_info(self, account:str, balance:float):
        self.driver.send_keys(self.__account_name, account)
        self.driver.send_keys(self.__initial_balance, balance)

    def confirm_creation(self):
        self.driver.click(self.__create_account)