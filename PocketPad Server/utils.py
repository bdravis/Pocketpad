from random import randint

class Paircode:
    _instance = None
    def __init__(self, code):
        self.code = code
        
    def __str__(self):
        return str(str(self.code)[:3]).zfill(3) + " " + str(str(self.code)[3:]).zfill(3)
    
    def __eq__(self, other):
        return self.code == other.code
    
    def __neq__(self, other):
        return self.code != other.code
    
    @staticmethod
    def get():
        return Paircode._instance
    
    @staticmethod
    def reset():
        Paircode._instance = Paircode(randint(100000, 999999))
        return Paircode._instance
    
    @staticmethod
    def remove():
        Paircode._instance = None
        return Paircode._instance