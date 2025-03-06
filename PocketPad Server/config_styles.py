# This file contains classes and enums that correspond to style structs in Swift
# RegularButtonShape, RegularButtonIconType, RegularButtonStyle
# 
# Created by Jack on 3/6/25

from enum import Enum

class RegularButtonShape(Enum):
    CIRCLE = 0
    PILL = 1

class RegularButtonIconType(Enum):
    TEXT = 0
    SFSYMBOL = 1

class RegularButtonStyle:
    def __init__(
        self,
        shape: RegularButtonShape,
        iconType: RegularButtonIconType,
        icon: str
    ):
        self.shape = shape
        self.iconType = iconType
        self.icon = icon

