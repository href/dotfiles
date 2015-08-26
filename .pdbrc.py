from __future__ import print_function

import types

from pprint import pprint


def search_member(obj, query=None):
    if query:
        results = (m for m in dir(obj) if query.lower() in m.lower())
    else:
        results = dir(obj)

    for result in results:
        print(result)


# pdb++ support
try:
    from pdb import DefaultConfig

    class Config(DefaultConfig):

        current_line_color = 40  # black

        def setup(self, pdb):

            def do_pp(self, arg):
                return pprint(self._getval(arg))

            def do_pd(self, arg):
                return pprint(self._getval(arg).__dict__)

            def do_sm(self, arg):
                if ':' not in arg:
                    arg, query = arg, None
                else:
                    arg, query = arg.split(':')

                return search_member(self._getval(arg), query)

            pdb.do_pp = types.MethodType(do_pp, pdb)
            pdb.do_sm = types.MethodType(do_sm, pdb)
            pdb.do_pd = types.MethodType(do_pd, pdb)

            pdb.do_l = pdb.do_longlist
            pdb.do_st = pdb.do_sticky


except ImportError:
    pass

sm = search_member
pp = pprint
