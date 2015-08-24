from __future__ import print_function
from pprint import pprint

# pdb++ support
try:
    from pdb import DefaultConfig

    class Config(DefaultConfig):
        pass
except ImportError:
    pass


def search_member(obj, query):
    results = (m for m in dir(obj) if query.lower() in m.lower())
    map(print, results)


sm = search_member
pp = pprint
