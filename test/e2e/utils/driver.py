from typing import Any, Optional, Union

import yaml
from appium import webdriver

from mobile_actions.android.android_mobile_actions import AndroidMobileActions
from mobile_actions.mobile_actions import MobileActions
from mobile_actions.ios.ios_mobile_actions import IOSMobileActions
from utils.utils import Utils


class Driver:
    driver: Optional[MobileActions] = None
    os: Optional[str] = None
    capabilities: Union[dict[Any, Any], Any] = None
    device_udid: Optional[str]
    app: Optional[str]

    def __init__(self, base_test: Union[AndroidMobileActions, IOSMobileActions]) -> None:
        self.driver = base_test

    def set_driver(appium_driver: webdriver) -> None:
        if Driver.os == "android":
            Driver.driver = AndroidMobileActions(appium_driver)
        elif Driver.os == "ios":
            Driver.driver = IOSMobileActions(appium_driver)
        else:
            raise ValueError(
                'Invalid value for platformName inside the browserstack.yml file. Expected "android" or "ios".'
            )

    def set_info(
        os: str, session_capabilities: Union[dict[Any, Any], Any],
    ):
        yaml_file = "config/platform_config.yaml"
        with open(yaml_file, "r") as file:
            data = yaml.safe_load(file)
        Driver.appium_url = data["appiumURL"]
        Driver.os = os
        Utils.set_constants(Driver.os)
        Driver.os = os
        Driver.capabilities = session_capabilities

    def get_capabilities(os: str) -> dict[str, Any]:
        yaml_file = "config/platform_config.yaml"
        with open(yaml_file, "r") as file:
            data = yaml.safe_load(file)
        if "platforms" in data and data["platforms"]:
            if os == "android":
                capabilities = {
                    "platformName": data["platforms"][0]["platformName"],
                    "automationName": data["platforms"][0]["automationName"],
                    "udid": data["platforms"][0]["udid"],
                    "appPackage": data["platforms"][0]["appPackage"],
                    "appActivity": data["platforms"][0]["appActivity"],
                }
                Driver.device_udid = data["platforms"][0]["udid"]
                Driver.app = data["platforms"][0]["appPackage"]
            elif os == "ios":
                capabilities = {
                    "platformName": data["platforms"][1]["platformName"],
                    "appium:udid": data["platforms"][1]["udid"],
                    "appium:automationName": data["platforms"][1]["automationName"],
                    "appium:bundleId": data["platforms"][1]["bundleID"],
                }
                Driver.device_udid = data["platforms"][1]["udid"]
                Driver.app = data["platforms"][1]["bundleID"]
            else:
                raise ValueError(f"The local argument must be either android or ios got {os}")
        return capabilities
