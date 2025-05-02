from random import randint
from PySide6.QtCore import QObject, Signal

class PaircodeManager(QObject):
    code_changed = Signal()

    def __init__(self):
        super().__init__()
        self._instance = None
        
    def __call__(self, code: int):
        return _Code(code)

    def get(self):
        return self._instance

    def reset(self):
        self._instance = _Code(randint(100000, 999999))
        self.code_changed.emit()
        return self._instance

    def remove(self):
        self._instance = None
        self.code_changed.emit()
        return self._instance

class _Code:
    def __init__(self, code):
        self.code = code

    def __str__(self):
        return str(str(self.code)[:3]).zfill(3) + " " + str(str(self.code)[3:]).zfill(3)

    def __eq__(self, other):
        return self.code == other.code

    def __ne__(self, other):
        return self.code != other.code

Paircode = PaircodeManager()