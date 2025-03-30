import time
from utils.driver import Driver
from selenium.webdriver.common.by import By
from utils.utils import Utils


class ManageAccountPage:
    def __init__(self):
        self.driver = Driver.driver
        if Driver.os == Utils.ANDROID:
            pass
        elif Driver.os == Utils.IOS:
            self.__account_name = (By.ACCESSIBILITY_ID, "Account name")
            self.__initial_balance = (By.ACCESSIBILITY_ID, "Initial Balance")
        self.__create_account = (By.ACCESSIBILITY_ID, "CREATE ACCOUNT")

    def add_account_info(self, account:str, balance:float):
        if Driver.os == Utils.ANDROID:
            time.sleep(1)
            textfields = self.driver.find_elements_by_class(Utils.CONSTANTS["edit_textfield"])
            account_name = textfields[0]
            initial_balance = textfields[1]
            self.driver.send_keys_to_element(account_name, account)
            self.driver.send_keys_to_element(initial_balance, balance)
        else:
            self.driver.send_keys(self.__account_name, account)
            self.driver.send_keys(self.__initial_balance, balance)
            

    def confirm_creation(self):
        self.driver.click(self.__create_account)