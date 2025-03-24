import time
from appium.webdriver.webdriver import WebDriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException
from appium.webdriver.webelement import WebElement
from typing import List

from utils.utils import Utils


class MobileActions:
    driver = None

    def __init__(self, driver: WebDriver):
        MobileActions.driver = driver
        print("Driver set successfully")

    def wait_for_element(self, locator: tuple[str, str]) -> WebElement:
        """Wait for an element to be present in the DOM."""
        return WebDriverWait(self.driver, Utils.WAIT).until(EC.presence_of_element_located(locator))

    def click(self, locator: tuple[str, str]) -> None:
        """Click an element located by its selector."""
        for _ in range(2):  # Retry once in case of a StaleElementReferenceException
            try:
                self.wait_for_element(locator).click()
                return
            except StaleElementReferenceException:
                time.sleep(0.5)
        print(f"Failed to click element: {locator}")

    def click_element(self, element: WebElement) -> None:
        """Click an element directly."""
        element.click()

    def clear_text(self, locator: tuple[str, str]) -> None:
        """Clear text from an input field."""
        self.wait_for_element(locator).clear()

    def is_visible(self, locator: tuple[str, str]) -> bool:
        """Check if an element is visible."""
        try:
            self.wait_for_element(locator)
            print(f"Element {locator} is visible")
            return True
        except:
            print(f"Element {locator} is NOT visible")
            return False

    def click_element_by_text(self, class_name: str, target_text: str) -> bool:
        """Click an element matching the given text or label."""
        elements = self.find_elements_by_class(class_name)
        for element in elements:
            if self._matches_target_text(element, target_text):
                element.click()
                return
                
        print(f"No element found with text: {target_text}")

    def check_element_by_text(self, class_name: str, target_text: str) -> bool:
        """Check if an element with specific text is present, scrolling if needed."""
        elements = self.find_elements_by_class(class_name)
        
        for element in elements:
            if self._matches_target_text(element, target_text):
                return True

            # Scroll if needed
            if self._should_scroll(element):
                self._scroll(element)

        # Try again after potential scrolling
        return any(self._matches_target_text(e, target_text) for e in self.find_elements_by_class(class_name))

    def find_element_by_text(self, class_name: str, target_text: str) -> WebElement:
        """Find an element by text or label."""
        elements = self.find_elements_by_class(class_name)
        for element in elements:
            if self._matches_target_text(element, target_text):
                return element

        print(f"No element found with text: {target_text}")
        return None

    def _matches_target_text(self, element: WebElement, target_text: str) -> bool:
        """Helper to check if an element's text or label matches the target text."""
        text = element.get_attribute(Utils.CONSTANTS["text"])
        label = element.get_attribute(Utils.CONSTANTS.get("label", ""))
        
        if text == target_text or label == target_text:
            return True
        return False

    def _should_scroll(self, element: WebElement) -> bool:
        """Determine if scrolling is necessary based on element position."""
        y = self.get_y_for_element(element) + self.get_height_for_element(element)
        return y > int(Utils.CONSTANTS["bottom_of_page"])

    def _scroll(self, element: WebElement) -> None:
        """Perform a scroll action to bring an element into view."""
        scroll_distance = self.get_y_for_element(element) + self.get_height_for_element(element) - int(Utils.CONSTANTS["bottom_of_page"]) + 10
        self.driver.swipe(500, 600, 500, 600 - scroll_distance)

    def send_keys_to_element(self, element: WebElement, text: str) -> None:
        raise NotImplementedError

    def send_keys(self, locator: tuple[str, str], txt: str) -> None:
        raise NotImplementedError

    def get_attribute(self, locator: tuple[str, str], attribute: str) -> str:
        raise NotImplementedError

    def get_attribute_for_element(self, element: WebElement, attribute: str) -> str:
        raise NotImplementedError

    def scroll_gesture(self, locator: tuple[str, str], direction: str) -> bool:
        raise NotImplementedError

    def scroll_gesture_for_element(self, element: WebElement, direction: str) -> bool:
        raise NotImplementedError

    def find_elements_by_class(self, class_name: str) -> List[WebElement]:
        raise NotImplementedError

    def relaunch_app(self):
        raise NotImplementedError
