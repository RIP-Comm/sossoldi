import base64
import logging
import os
import time
from typing import Dict, List, Tuple, Union

from appium.webdriver.webdriver import WebDriver
from appium.webdriver.webelement import WebElement
from lib.utilities import get_date_time
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

from lib.constants import TIMEOUT


class MobileActions:
    def __init__(self, driver: WebDriver, driver_elements: Dict[str, str]):
        self.driver = driver
        self._driver_elements = driver_elements
        self.is_recording = False

    def relaunch_app(self) -> None:
        """Terminate and relaunch the app."""
        from lib.configuration import configuration

        logging.info("relaunching the app...")
        self.driver.terminate_app(app_id=configuration.app)
        self.driver.activate_app(app_id=configuration.app)
        time.sleep(4)

    def wait_for_element(self, locator: Tuple[str, str], timeout: float = TIMEOUT) -> WebElement:
        """Wait for an element to be present in the DOM."""
        return WebDriverWait(self.driver, timeout=timeout).until(ec.presence_of_element_located(locator))

    def click(self, locator: Tuple[str, str]) -> None:
        """Click an element located by its selector."""
        for _ in range(2):  # Retry once in case of a StaleElementReferenceException
            try:
                self.wait_for_element(locator=locator).click()
                return
            except StaleElementReferenceException:
                time.sleep(0.5)
        logging.error(f"failed to click element: {locator}")

    @staticmethod
    def click_element(element: WebElement) -> None:
        """Click an element directly."""
        element.click()

    def clear_text(self, locator: Tuple[str, str]) -> None:
        """Clear text from an input field."""
        self.wait_for_element(locator=locator).clear()

    def is_visible(self, locator: Tuple[str, str]) -> bool:
        """Check if an element is visible."""
        try:
            self.wait_for_element(locator=locator)
            logging.debug(f"element {locator} is visible")
            return True
        except:
            logging.error(f"element {locator} is NOT visible")
            return False

    def click_element_by_text(self, class_name: str, target_text: str) -> bool:
        """
        Click an element matching the given text or label.
        Returns True if any element matching target_text is found, False otherwise.
        """
        elements = self.find_elements_by_class(class_name=class_name)
        for element in elements:
            if self._matches_target_text(element=element, target_text=target_text):
                element.click()
                return True

        logging.warning(f"no element found with text: {target_text}")
        return False

    def check_element_by_text(self, class_name: str, target_text: str) -> bool:
        """Check if an element with specific text is present, scrolling if needed."""
        elements = self.find_elements_by_class(class_name=class_name)

        for element in elements:
            if self._matches_target_text(element=element, target_text=target_text):
                return True

            # Scroll if needed
            if self._should_scroll(element=element):
                self._scroll(element=element)

        # Try again after potential scrolling
        return any(
            self._matches_target_text(element=e, target_text=target_text)
            for e in self.find_elements_by_class(class_name=class_name)
        )

    def find_element_by_text(self, class_name: str, target_text: str) -> Union[WebElement, None]:
        """Find an element by text or label."""
        elements = self.find_elements_by_class(class_name=class_name)
        for element in elements:
            if self._matches_target_text(element=element, target_text=target_text):
                return element

        logging.warning(f"no element found with text: {target_text}")
        return None

    def _matches_target_text(self, element: WebElement, target_text: str) -> bool:
        """Helper to check if an element's text or label matches the target text."""
        text = element.get_attribute(name=self._driver_elements.get("text"))
        label = element.get_attribute(name=self._driver_elements.get("label", ""))

        if text == target_text or label == target_text:
            return True
        return False

    def _should_scroll(self, element: WebElement) -> bool:
        """Determine if scrolling is necessary based on element position."""
        y = self.get_y_for_element(element) + self.get_height_for_element(element)
        return y > int(self._driver_elements.get("bottom_of_page"))

    def _scroll(self, element: WebElement) -> None:
        """Perform a scroll action to bring an element into view."""
        scroll_distance = (
            self.get_y_for_element(element)
            + self.get_height_for_element(element)
            - int(self._driver_elements.get("bottom_of_page"))
            + 10
        )
        self.driver.swipe(500, 600, 500, 600 - scroll_distance)

    def start_recording(self) -> None:
        """Start recording the screen."""
        self.driver.start_recording_screen(video_quality="low")
        self.is_recording = True
        logging.info("starting screen recording")

    def stop_recording(self, file_name: str) -> None:
        """Stops the video recording and saves the file."""
        from lib.configuration import configuration

        raw_video = self.driver.stop_recording_screen()

        video_dir = os.path.join(
            "videos",
            configuration.platform.value + "_" + configuration.device_udid,
            get_date_time(),
        )
        if not os.path.exists(video_dir):
            os.makedirs(video_dir)
        filepath = os.path.join(video_dir, file_name + ".mp4")
        with open(filepath, "wb+") as vd:
            vd.write(base64.b64decode(raw_video))

        self.is_recording = False
        logging.info(f"screen video recording has been saved at {filepath}")

    def send_keys_to_element(self, element: WebElement, text: str) -> None:
        raise NotImplementedError

    def send_keys(self, locator: Tuple[str, str], txt: str) -> None:
        raise NotImplementedError

    def get_attribute(self, locator: Tuple[str, str], attribute: str) -> str:
        raise NotImplementedError

    def get_attribute_for_element(self, element: WebElement, attribute: str) -> str:
        raise NotImplementedError

    def scroll_gesture(self, locator: Tuple[str, str], direction: str) -> bool:
        raise NotImplementedError

    def scroll_gesture_for_element(self, element: WebElement, direction: str) -> bool:
        raise NotImplementedError

    def find_elements_by_class(self, class_name: str) -> List[WebElement]:
        raise NotImplementedError
