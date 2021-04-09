import sys
import sys
from types import ModuleType, FunctionType
from gc import get_referents

# Custom objects know their class.
# Function objects seem to know way too much, including modules.
# Exclude modules as well.
BLACKLIST = type, ModuleType, FunctionType

def getsize(obj):
    """sum size of object & members."""
    if isinstance(obj, BLACKLIST):
        raise TypeError('getsize() does not take argument of type: '+ str(type(obj)))
    seen_ids = set()
    size = 0
    objects = [obj]
    while objects:
        need_referents = []
        for obj in objects:
            if not isinstance(obj, BLACKLIST) and id(obj) not in seen_ids:
                seen_ids.add(id(obj))
                size += sys.getsizeof(obj)
                need_referents.append(obj)
        objects = get_referents(*need_referents)
    return size

class thing(object):
    def __init__(self):
        self.var = 1
        self.var2 = 10
        self.arr = [1,2,3,4,5,6,7,8,9,10]

obj = thing()
var = 12312412
arr = [1,2,3,4,5,6,7,8,9]
print sys.getsizeof(arr)
print sys.getsizeof(obj)
print getsize(obj)