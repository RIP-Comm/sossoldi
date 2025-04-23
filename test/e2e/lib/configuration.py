import os.path
from pathlib import Path
from typing import Any, Dict

import yaml
from appium import webdriver
from appium.options.common import AppiumOptions
from lib.enums import Os
from lib.utilities import Singleton
from mobile_actions.android.android_mobile_actions import AndroidMobileActions
from mobile_actions.ios.ios_mobile_actions import IOSMobileActions


class Configuration(metaclass=Singleton):
    """
    Singleton class to define the test configuration used in the testing session.
    """

    def __init__(self, os: Os = None, rootpath: Path = None):
        self.__loaded_config = self.__load_platform_config(rootpath=rootpath)

        self.os = os
        self.appium_url = self.__loaded_config.get("appiumURL")

        if "platforms" in self.__loaded_config and self.__loaded_config.get("platforms"):
            self.driver_config = self.DriverConfiguration(os=self.os, config=self.__loaded_config)
            if self.os == Os.ANDROID:
                self.device_udid = self.__loaded_config.get("platforms")[0].get("udid")
                self.app = self.__loaded_config.get("platforms")[0].get("appPackage")
            elif self.os == Os.IOS:
                self.device_udid = self.__loaded_config.get("platforms")[1].get("udid")
                self.app = self.__loaded_config.get("platforms")[1].get("bundleID")

        self.__web_driver = webdriver.Remote(
            command_executor=self.appium_url,
            options=AppiumOptions().load_capabilities(caps=self.driver_config.capabilities),
        )

        self.driver = (
            AndroidMobileActions(driver=self.__web_driver, driver_elements=self.driver_config.constants)
            if self.os == Os.ANDROID
            else IOSMobileActions(driver=self.__web_driver, driver_elements=self.driver_config.constants)
        )

    def quit(self) -> None:
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

        def __init__(self, os: Os, config: Dict[str, Any]):

            if os == Os.ANDROID:
                self.capabilities = {
                    "platformName": config.get("platforms")[0].get("platformName"),
                    "automationName": config.get("platforms")[0].get("automationName"),
                    "udid": config.get("platforms")[0].get("udid"),
                    "appPackage": config.get("platforms")[0].get("appPackage"),
                    "appActivity": config.get("platforms")[0].get("appActivity"),
                }
                self.constants = config.get("platforms")[0].get("constants")
            elif os == Os.IOS:
                self.capabilities = {
                    "platformName": config.get("platforms")[1].get("platformName"),
                    "appium:udid": config.get("platforms")[1].get("udid"),
                    "appium:automationName": config.get("platforms")[1].get("automationName"),
                    "appium:bundleId": config.get("platforms")[1].get("bundleID"),
                }
                self.constants = config.get("platforms")[1].get("constants")
