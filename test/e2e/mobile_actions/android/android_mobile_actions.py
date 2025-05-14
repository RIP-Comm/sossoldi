import logging
import time
from typing import Dict, List, Tuple

from appium.webdriver.common.appiumby import AppiumBy as By
from appium.webdriver.webdriver import WebDriver
from appium.webdriver.webelement import WebElement
from lib.enums import Direction
from mobile_actions.mobile_actions import MobileActions
from selenium.common.exceptions import StaleElementReferenceException


class AndroidMobileActions(MobileActions):
    def __init__(self, driver: WebDriver, driver_elements: Dict[str, str]):
        super().__init__(driver=driver, driver_elements=driver_elements)
        logging.debug(f"driver {self.__class__.__name__} set successfully")

    def send_keys(self, locator: Tuple[str, str], text: str) -> None:
        """Send text input to an element."""
        self.click(locator=locator)
        self._send_keys(element=self.wait_for_element(locator=locator), text=text)

    def send_keys_to_element(self, element: WebElement, text: str) -> None:
        """Send text input to a given element."""
        self.click_element(element=element)
        self._send_keys(element=element, text=text)

    @staticmethod
    def _send_keys(element: WebElement, text: str) -> None:
        """Helper method to send keys to an element."""
        if element:
            element.send_keys(text)

    def get_attribute(self, locator: Tuple[str, str], attribute: str) -> str:
        """Retrieve an element's attribute with retry mechanism."""
        return self._get_element_attribute(
            lambda: self.wait_for_element(locator=locator), attribute=attribute, debug_info=str(locator)
        )

    def get_attribute_for_element(self, element: WebElement, attribute: str) -> str:
        """Retrieve an attribute from a given element with retry mechanism."""
        return self._get_element_attribute(lambda: element, attribute=attribute, debug_info=str(element))

    @staticmethod
    def _get_element_attribute(element_provider, attribute: str, debug_info: str) -> str:
        """Helper method to get an element attribute with retry."""
        for _ in range(2):  # Retry once if needed
            try:
                element = element_provider()
                return element.get_attribute(attribute=attribute)
            except:
                logging.error(f"error retrieving attribute from {debug_info}. Retrying...")
                time.sleep(1)
        return ""

    def find_elements_by_class(self, class_name: str) -> List[WebElement]:
        """Find elements by class name, handling StaleElementReferenceException."""
        try:
            logging.debug(f"looking for element with class name: {class_name}")
            return self.driver.find_elements(by=By.CLASS_NAME, value=class_name)
        except StaleElementReferenceException:
            logging.warning("retrying due to stale element issue...")
            return self.find_elements_by_class(class_name=class_name)

    def scroll_gesture(self, locator: Tuple[str, str], direction: Direction) -> bool:
        """Perform a scroll gesture on an element located by the given locator and returns whether it can be furtherly scrolled."""
        return self.scroll_gesture_for_element(element=self.wait_for_element(locator=locator), direction=direction)

    def scroll_gesture_for_element(self, element: WebElement, direction: Direction) -> bool:
        """Perform a scroll gesture on a specific element and returns whether it can be furtherly scrolled."""
        if not element:
            return False

        logging.debug(f"scrolling element: {element}")
        can_scroll_more = self.driver.execute_script(
            "mobile: scrollGesture",
            {
                "elementId": element.id,
                "direction": direction.value,
                "percent": 0.8,
                "speed": 2000,
            },
        )
        return bool(can_scroll_more)
