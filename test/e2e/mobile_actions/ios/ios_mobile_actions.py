import time
from appium.webdriver.webdriver import WebDriver
from appium.webdriver.webelement import WebElement
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import StaleElementReferenceException

from mobile_actions.mobile_actions import MobileActions
from utils.utils import Utils


class IOSMobileActions(MobileActions):
    def __init__(self, driver: WebDriver):
        super().__init__(driver)
        self.__done_text_button = (By.ACCESSIBILITY_ID, "Done")

    def send_keys(self, locator: tuple[str, str], txt: str) -> None:
        """Send keys to an element and attempt to click the 'Done' button if present."""
        self.wait_for_element(locator).send_keys(txt)
        self._handle_done_button_click()

    def send_keys_to_element(self, element: WebElement, text: str) -> None:
        """Send keys to a given element and attempt to click the 'Done' button."""
        element.send_keys(text)
        self._handle_done_button_click()

    def _handle_done_button_click(self) -> None:
        """Attempt to click the 'Done' button if it appears."""
        try:
            WebDriverWait(self.driver, 1).until(EC.presence_of_element_located(self.__done_text_button)).click()
        except:
            pass  # Ignore if the button is not present

    def find_elements_by_class(self, class_name: str):
        """Find elements by class name, handling StaleElementReferenceException."""
        try:
            elements = self.driver.find_elements(AppiumBy.CLASS_NAME, class_name)
            if class_name == "XCUIElementTypeTextView":
                elements += self.driver.find_elements(AppiumBy.CLASS_NAME, "XCUIElementTypeStaticText")
            return elements
        except StaleElementReferenceException:
            print("Retrying due to stale element issue...")
            return self.find_elements_by_class(class_name)

    def relaunch_app(self):
        """Terminate and relaunch the app."""
        from utils.driver import Driver

        print("Restarting app...")
        self.driver.terminate_app(Driver.app)
        self.driver.activate_app(Driver.app)
        time.sleep(4)

    def get_attribute(self, locator: tuple[str, str], attribute: str) -> str:
        """Get an element's attribute with retry on failure."""
        return self._get_element_attribute(lambda: self.wait_for_element(locator), attribute, str(locator))

    def get_attribute_for_element(self, element: WebElement, attribute: str) -> str:
        """Get an element's attribute with retry on failure."""
        return self._get_element_attribute(lambda: element, attribute, str(element))

    def _get_element_attribute(self, element_provider, attribute: str, debug_info: str) -> str:
        """Helper method to get an element attribute with retry."""
        for _ in range(2):  # Retry once if needed
            try:
                element = element_provider()
                return element.get_attribute(attribute) or element.get_attribute(Utils.CONSTANTS.get("label", ""))
            except:
                print(f"Error retrieving attribute from {debug_info}. Retrying...")
                time.sleep(1)
        return ""

    def scroll_gesture(self, locator: tuple[str, str], direction: str) -> bool:
        """Perform a scroll gesture on a locator in a given direction."""
        coords = self._get_scroll_coordinates(locator, direction)
        if coords:
            self.driver.swipe(*coords, duration=500)
            return True
        return False

    def scroll_gesture_for_element(self, element: WebElement, direction: str) -> bool:
        """Perform a scroll gesture on an element in a given direction."""
        print(f"Scrolling element: {element}")
        coords = self._get_scroll_coordinates(element, direction, is_element=True)
        if coords:
            self.driver.swipe(*coords, duration=500)
            return True
        return False

    def _get_scroll_coordinates(self, target, direction: str, is_element: bool = False):
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
            "down": (x, y + get_height(target) / 2 - 2, x, y - get_height(target) / 2),
            "up": (x, y - get_height(target) / 2 + 2, x, y + get_height(target) / 2),
            "right": (x + get_width(target) / 2 - 2, y, x - get_width(target) / 2, y),
            "left": (x - get_width(target) / 2 + 2, y, x + get_width(target) / 2, y),
        }

        return offsets.get(direction)
    
    def start_recording(self) -> None:
        """Start recording the screen."""
        ex = self.driver.start_recording_screen(video_quality="low")
        MobileActions.is_recording = True
        print("Started recording...")