from datetime import datetime
import yaml

class Utils:
    WAIT = 10
    ANDROID = "android"
    IOS = "ios"
    CONSTANTS = None

    @staticmethod
    def set_constants(os: str) -> None:
        yaml_file = "config/platform_config.yaml"
        if os == "android":
            with open(yaml_file, "r") as file:
                data = yaml.safe_load(file)
            Utils.CONSTANTS = data["platforms"][0]["constants"]
        elif os == "ios":
            with open(yaml_file, "r") as file:
                data = yaml.safe_load(file)
            Utils.CONSTANTS = data["platforms"][1]["constants"]

    @staticmethod
    def get_date_time():
        date_format = "%Y-%m-%d-%H-%M-%S"
        current_datetime = datetime.now()
        return current_datetime.strftime(date_format)