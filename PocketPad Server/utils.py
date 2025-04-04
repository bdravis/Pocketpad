from random import randint

class Paircode:
    def __init__(self, code):
        self.code = code
        
    def __str__(self):
        return str(str(self.code)[:3]).zfill(3) + " " + str(str(self.code)[3:]).zfill(3)
    
    def __eq__(self, other):
        return self.code == other.code
    
    def __neq__(self, other):
        return self.code != other.code
    
    @classmethod
    def generate(self):
        return Paircode(randint(100000, 999999))