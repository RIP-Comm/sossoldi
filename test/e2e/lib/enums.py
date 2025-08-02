from enum import Enum


class Platform(Enum):
    ANDROID = "android"
    IOS = "ios"


class Direction(Enum):
    UP = "up"
    DOWN = "down"
    RIGHT = "right"
    LEFT = "left"
