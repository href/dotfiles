from __future__ import print_function
from pprint import pprint


def search_member(obj, query):
    results = (m for m in dir(obj) if query.lower() in m.lower())
    map(print, results)


sm = search_member
pp = pprint
