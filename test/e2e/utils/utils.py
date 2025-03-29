import yaml

class Utils:
    WAIT = 20
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
