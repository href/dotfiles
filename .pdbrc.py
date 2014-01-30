from __future__ import print_function
from pprint import pprint


def search_member(object, query):
    results = (m for m in dir(query) if query.lower() in m.lower())
    map(print, results)


sm = search_member
pp = pprint
