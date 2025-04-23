from datetime import datetime


class Singleton(type):
    """
    Singleton definition to have a single instance of the class expressing singleton as metaclass.
    """

    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


def get_date_time() -> str:
    date_format = "%Y-%m-%d-%H-%M-%S"
    return datetime.now().strftime(date_format)
