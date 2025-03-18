from utils.driver import Driver
from selenium.webdriver.common.by import By
from utils.utils import Utils


class DashboardPage:
    def __init__(self):
        self.driver = Driver.driver
        if Driver.os == Utils.ANDROID:
            self.__empty_graph = (By.ACCESSIBILITY_ID, "MONTHLY BALANCE\n0.00€\nINCOME\n0.00€\nEXPENSES\n0.00€\nWe are sorry but there are not\nenough data to make the graph...\nCurrent month\nLast month")
            self.__empty_accounts_budgets = (By.ACCESSIBILITY_ID, "Your accounts\nLast transactions\nNo transactions available\nYour budgets\nNo budget set\nCreate a budget to track your spending")
        elif Driver.os == Utils.IOS:
            self.__empty_graph = (By.ACCESSIBILITY_ID, "")
            self.__empty_accounts_budgets = (By.ACCESSIBILITY_ID, "")

    def check_empty_dashboard(self) -> bool:
        return self.driver.is_visible(self.__empty_graph) and self.driver.is_visible(self.__empty_accounts_budgets)


