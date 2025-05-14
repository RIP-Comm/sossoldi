import logging
import os.path
from pathlib import Path
from typing import Any, Dict

import yaml
from appium import webdriver
from appium.options.common import AppiumOptions
from lib.enums import Platform
from lib.utilities import Singleton
from mobile_actions.android.android_mobile_actions import AndroidMobileActions
from mobile_actions.ios.ios_mobile_actions import IOSMobileActions


class Configuration(metaclass=Singleton):
    """
    Singleton class to define the test configuration used in the testing session.
    """

    def __new__(cls, *args, **kwargs):
        """
        Create a new configuration object and make it unique with Singleton properties.
        """
        return cls._create_unique(super=super(), *args, **kwargs)

    def __init__(self, platform: Platform = None, rootpath: Path = None):
        """
        Initialize configuration with necessary attributes.

        :param platform: mobile platform under test.
        :param rootpath: root path of the pytest project. Used to load config file.
        """
        logging.debug(f"creating {self.__class__.__name__} for platform: {platform}; rootpath: {rootpath}")

        self.__loaded_config = self.__load_platform_config(rootpath=rootpath)

        self.platform = platform
        self.appium_url = self.__loaded_config.get("appiumURL")

        if "platforms" in self.__loaded_config and self.__loaded_config.get("platforms"):
            self.driver_config = self.DriverConfiguration(platform=self.platform, config=self.__loaded_config)
            if self.platform == Platform.ANDROID:
                self.device_udid = self.__loaded_config.get("platforms")[0].get("udid")
                self.app = self.__loaded_config.get("platforms")[0].get("appPackage")
            elif self.platform == Platform.IOS:
                self.device_udid = self.__loaded_config.get("platforms")[1].get("udid")
                self.app = self.__loaded_config.get("platforms")[1].get("bundleID")

        self.__web_driver = webdriver.Remote(
            command_executor=self.appium_url,
            options=AppiumOptions().load_capabilities(caps=self.driver_config.capabilities),
        )

        self.driver = (
            AndroidMobileActions(driver=self.__web_driver, driver_elements=self.driver_config.constants)
            if self.platform == Platform.ANDROID
            else IOSMobileActions(driver=self.__web_driver, driver_elements=self.driver_config.constants)
        )

    def quit(self) -> None:
        """
        Do needed operations during test session teardown and stop web driver.
        Preferred to __del__ since it may cause unwanted behavior.
        """
        logging.debug("quitting configuration webdriver")
        self.__web_driver.quit()

    @staticmethod
    def __load_platform_config(rootpath: Path = None) -> Dict[str, Any]:
        """
        Load platform configuration settings from yaml file.
        """
        with open(os.path.join(rootpath, "config", "platform_config.yaml"), "r") as file:
            return yaml.safe_load(file)

    class DriverConfiguration:
        """
        Class to include configuration settings used in the web driver.
        """

        def __init__(self, platform: Platform, config: Dict[str, Any]):
            if platform == Platform.ANDROID:
                self.capabilities = {
                    "platformName": config.get("platforms")[0].get("platformName"),
                    "automationName": config.get("platforms")[0].get("automationName"),
                    "udid": config.get("platforms")[0].get("udid"),
                    "appPackage": config.get("platforms")[0].get("appPackage"),
                    "appActivity": config.get("platforms")[0].get("appActivity"),
                }
                self.constants = config.get("platforms")[0].get("constants")
            elif platform == Platform.IOS:
                self.capabilities = {
                    "platformName": config.get("platforms")[1].get("platformName"),
                    "appium:udid": config.get("platforms")[1].get("udid"),
                    "appium:automationName": config.get("platforms")[1].get("automationName"),
                    "appium:bundleId": config.get("platforms")[1].get("bundleID"),
                }
                self.constants = config.get("platforms")[1].get("constants")


# create configuration object
configuration = Configuration.__new__(Configuration)
