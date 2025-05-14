import logging
import time
from typing import Any, Dict, List, Tuple, Union

from appium.webdriver.common.appiumby import AppiumBy as By
from appium.webdriver.webdriver import WebDriver
from appium.webdriver.webelement import WebElement
from lib.enums import Direction
from mobile_actions.mobile_actions import MobileActions
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait


class IOSMobileActions(MobileActions):
    def __init__(self, driver: WebDriver, driver_elements: Dict[str, str]):
        super().__init__(driver=driver, driver_elements=driver_elements)
        self.__done_text_button = (By.ACCESSIBILITY_ID, "Done")
        logging.debug(f"driver {self.__class__.__name__} set successfully")

    def send_keys(self, locator: Tuple[str, str], text: str) -> None:
        """Send keys to an element and attempt to click the 'Done' button if present."""
        self.wait_for_element(locator=locator).send_keys(text)
        self._handle_done_button_click()

    def send_keys_to_element(self, element: WebElement, text: str) -> None:
        """Send keys to a given element and attempt to click the 'Done' button."""
        element.send_keys(text)
        self._handle_done_button_click()

    def _handle_done_button_click(self) -> None:
        """Attempt to click the 'Done' button if it appears."""
        try:
            WebDriverWait(driver=self.driver, timeout=1).until(
                ec.presence_of_element_located(self.__done_text_button)
            ).click()
        except:
            pass  # Ignore if the button is not present

    def find_elements_by_class(self, class_name: str) -> List[WebElement]:
        """Find elements by class name, handling StaleElementReferenceException."""
        try:
            elements = self.driver.find_elements(by=By.CLASS_NAME, value=class_name)
            if class_name == "XCUIElementTypeTextView":
                elements += self.driver.find_elements(by=By.CLASS_NAME, value="XCUIElementTypeStaticText")
            return elements
        except StaleElementReferenceException:
            logging.warning("retrying due to stale element issue...")
            return self.find_elements_by_class(class_name=class_name)

    def get_attribute(self, locator: Tuple[str, str], attribute: str) -> str:
        """Get an element's attribute with retry on failure."""
        return self._get_element_attribute(
            lambda: self.wait_for_element(locator=locator), attribute=attribute, debug_info=str(locator)
        )

    def get_attribute_for_element(self, element: WebElement, attribute: str) -> str:
        """Get an element's attribute with retry on failure."""
        return self._get_element_attribute(lambda: element, attribute=attribute, debug_info=str(element))

    def _get_element_attribute(self, element_provider, attribute: str, debug_info: str) -> str:
        """Helper method to get an element attribute with retry."""
        for _ in range(2):  # Retry once if needed
            try:
                element = element_provider()
                return element.get_attribute(attribute=attribute) or element.get_attribute(
                    attribute=self._driver_elements.get("label", "")
                )
            except:
                logging.error(f"error retrieving attribute from {debug_info}. Retrying...")
                time.sleep(1)
        return ""

    def scroll_gesture(self, locator: Tuple[str, str], direction: Direction) -> bool:
        """Perform a scroll gesture on a locator in a given direction."""
        coords = self._get_scroll_coordinates(target=locator, direction=direction)
        if coords:
            self.driver.swipe(*coords, duration=500)
            return True
        return False

    def scroll_gesture_for_element(self, element: WebElement, direction: Direction) -> bool:
        """Perform a scroll gesture on an element in a given direction."""
        logging.debug(f"scrolling element: {element}")
        coords = self._get_scroll_coordinates(target=element, direction=direction, is_element=True)
        if coords:
            self.driver.swipe(*coords, duration=500)
            return True
        return False

    def _get_scroll_coordinates(
        self, target: Union[Tuple[str, str], WebElement], direction: Direction, is_element: bool = False
    ) -> Tuple[Union[float, Any], Union[float, int, Any], Union[float, Any], Union[float, Any]]:
        """Calculate start and end coordinates for a scroll gesture."""
        if is_element:
            get_x = self.get_x_for_element
            get_y = self.get_y_for_element
            get_width = self.get_width_for_element
            get_height = self.get_height_for_element
        else:
            get_x = self.get_x
            get_y = self.get_y
            get_width = self.get_width
            get_height = self.get_height

        x = get_x(target) + get_width(target) / 2
        y = get_y(target) + get_height(target) / 2

        offsets = {
            Direction.DOWN: (x, y + get_height(target) / 2 - 2, x, y - get_height(target) / 2),
            Direction.UP: (x, y - get_height(target) / 2 + 2, x, y + get_height(target) / 2),
            Direction.RIGHT: (x + get_width(target) / 2 - 2, y, x - get_width(target) / 2, y),
            Direction.LEFT: (x - get_width(target) / 2 + 2, y, x + get_width(target) / 2, y),
        }

        return offsets.get(direction)
