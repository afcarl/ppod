#!/usr/bin/env python
# vim:set ft=python ts=4 sw=4 sts=4 autoindent:

'''
Illustration of how Python resolves multiple inheritance.

On the Diamond Problem:

    https://en.wikipedia.org/wiki/Diamond_problem

Great write-up:

    http://rhettinger.wordpress.com/2011/05/26/super-considered-super/

Note: Realising that `super` returns the next class in the Method Resolution
    Order (MRO) rather than than the base class(es) of the current class is
    what made things click for me. This means that `super` in `Left` can
    return either `Tip` or `Right` dependending on the context and thus the
    requirement to use keyword arguments since we can't know which __init__ we
    are about to call.

Note: I am not a fan of having to resort to required keywords, but it seems to
    be the law of the land.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2013-09-15
'''

from __future__ import print_function

# Structure:
#
#    Tip
#    ^ ^
#    | |
# Left Right
#    ^ ^
#    | |
#   Bottom

def _positional_error_str(func_name, num_args, args):
    if num_args == 0:
        num_args_str = 'no'
    else:
        num_args_str = 'exactly {}'.format(num_args)

    return ('{} takes {} positional arguments ({} given)'
        ).format(func_name, num_args_str, len(args))

def _keyword_error_str(func_name, kwarg_name):
    return ("{} requires the keyword argument '{}'".format(func_name,
        kwarg_name))

class Tip(object):
    def __init__(self, *args, **kwargs):
        print('START: Tip')

        if args:
            raise TypeError(_positional_error_str('__init__', 0, args))
        for kwarg in ('a', ):
            try:
                a = kwargs[kwarg]
            except KeyError, e:
                raise TypeError(_keyword_error_str('__init__', e.message))

        self.a = kwargs['a']

        print('END: Tip')

class Left(Tip):
    def __init__(self, *args, **kwargs):
        print('START: Left')

        if args:
            raise TypeError(_positional_error_str('__init__', 0, args))
        for kwarg in ('b', ):
            try:
                a = kwargs[kwarg]
            except KeyError, e:
                raise TypeError(_keyword_error_str('__init__', e.message))
        super(Left, self).__init__(*args, **kwargs)

        self.b = kwargs['b']

        print('END: Left')

class Right(Tip):
    def __init__(self, *args, **kwargs):
        print('START: Right')

        if args:
            raise TypeError(_positional_error_str('__init__', 0, args))
        for kwarg in ('c', 'd', ):
            try:
                a = kwargs[kwarg]
            except KeyError, e:
                raise TypeError(_keyword_error_str('__init__', e.message))
        super(Right, self).__init__(*args, **kwargs)

        self.c = kwargs['c']
        self.d = kwargs['d']

        print('END: Right')

class Bottom(Left, Right):
    def __init__(self, *args, **kwargs):
        print('START: Bottom')

        if args:
            raise TypeError(_positional_error_str('__init__', 0, args))
        for kwarg in ('e', ):
            try:
                a = kwargs[kwarg]
            except KeyError, e:
                raise TypeError(_keyword_error_str('__init__', e.message))
        super(Bottom, self).__init__(*args, **kwargs)

        self.e = kwargs['e']

        print('END: Bottom')

if __name__ == '__main__':
    print('Creating Tip Object:')
    Tip(a=0)
    print()
    print('Creating Left Object:')
    Left(a=0, b=1)
    print()
    print('Creating Right Object:')
    Right(a=0, c=2, d=3)
    print()
    print('Creating Bottom Object:')
    Bottom(a=0, b=1, c=2, d=3, e=4)
