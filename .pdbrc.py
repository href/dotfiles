from __future__ import print_function
from pprint import pprint as pp

#py flakes
pp


def search_member(object, query):
    results = (m for m in dir(query) if query.lower() in m.lower())
    map(print, results)
