from appium.webdriver.common.appiumby import AppiumBy as By
from lib.configuration import Configuration


class DashboardPage:
    def __init__(self):
        self.driver = Configuration().driver
        self.__empty_graph = (
            By.ACCESSIBILITY_ID,
            "MONTHLY BALANCE\n0.00€\nINCOME\n0.00€\nEXPENSES\n0.00€\nWe are sorry but there are not\nenough data to make the graph...\nCurrent month\nLast month",
        )
        self.__empty_accounts_budgets = (
            By.ACCESSIBILITY_ID,
            "Your accounts\nLast transactions\nNo transactions available\nYour budgets\nNo budget set\nCreate a budget to track your spending",
        )
        self.__new_account = (By.ACCESSIBILITY_ID, "New Account")

    def check_empty_dashboard(self) -> bool:
        return self.driver.is_visible(self.__empty_graph) and self.driver.is_visible(self.__empty_accounts_budgets)

    def create_account(self) -> None:
        self.driver.click(self.__new_account)

    def check_account(self, name: str, balance: float) -> bool:
        formatted_balance = f"{balance:.2f}"  # Ensures two decimal places
        account = (By.ACCESSIBILITY_ID, f"{name}\n{formatted_balance}€")
        return self.driver.is_visible(account)
