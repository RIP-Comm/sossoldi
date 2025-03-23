import time
from appium.webdriver.webdriver import WebDriver
from appium.webdriver.webelement import WebElement
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.common.by import By

from mobile_actions.mobile_actions import MobileActions


class AndroidMobileActions(MobileActions):
    def __init__(self, driver: WebDriver):
        super().__init__(driver)

    def relaunch_app(self):
        """Terminate and relaunch the app."""
        from utils.driver import Driver

        app_package = Driver.app
        print("Relaunching the app...")
        time.sleep(1)
        self.driver.terminate_app(app_package)
        time.sleep(1)
        self.driver.activate_app(app_package)

    def send_keys(self, locator: tuple[str, str], txt: str) -> None:
        """Send text input to an element."""
        self.click(locator)
        self._send_keys(self.wait_for_element(locator), txt)

    def send_keys_to_element(self, element: WebElement, text: str) -> None:
        """Send text input to a given element."""
        self._send_keys(element, text)

    def _send_keys(self, element: WebElement, text: str) -> None:
        """Helper method to send keys to an element."""
        if element:
            element.send_keys(text)

    def get_attribute(self, locator: tuple[str, str], attribute: str) -> str:
        """Retrieve an element's attribute with retry mechanism."""
        return self._get_element_attribute(lambda: self.wait_for_visibility(locator), attribute, str(locator))

    def get_attribute_for_element(self, element: WebElement, attribute: str) -> str:
        """Retrieve an attribute from a given element with retry mechanism."""
        return self._get_element_attribute(lambda: element, attribute, str(element))

    def _get_element_attribute(self, element_provider, attribute: str, debug_info: str) -> str:
        """Helper method to get an element attribute with retry."""
        for _ in range(2):  # Retry once if needed
            try:
                element = element_provider()
                return element.get_attribute(attribute)
            except:
                print(f"Error retrieving attribute from {debug_info}. Retrying...")
                time.sleep(1)
        return ""

    def find_elements_by_class(self, class_name: str):
        """Find elements by class name, handling StaleElementReferenceException."""
        try:
            return self.driver.find_elements(AppiumBy.CLASS_NAME, class_name)
        except StaleElementReferenceException:
            print("Retrying due to stale element issue...")
            return self.find_elements_by_class(class_name)

    def scroll_gesture(self, locator: tuple[str, str], direction: str) -> bool:
        """Perform a scroll gesture on an element located by the given locator."""
        return self.scroll_gesture_for_element(self.wait_for_visibility(locator), direction)

    def scroll_gesture_for_element(self, element: WebElement, direction: str) -> bool:
        """Perform a scroll gesture on a specific element."""
        if not element:
            return False

        print(f"Scrolling element: {element}")
        can_scroll_more = self.driver.execute_script(
            "mobile: scrollGesture",
            {
                "elementId": element.id,
                "direction": direction,
                "percent": 0.8,
                "speed": 2000,
            },
        )
        return bool(can_scroll_more)