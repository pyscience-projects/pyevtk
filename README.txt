INTRODUCTION:
=============


REQUIREMENTS:
=============
    - Numpy. Tested with Numpy 1.5.0. 
    - Cython. It is only required at compile time.

The package has been tested on:
    - MacOSX 10.6 x64.

DEVELOPER NOTES:
================

While developing, it is useful to build and install the package to a temporary
location without touching the global python site-packages directory. To do that,
while in the root directory, we can type:

    1. python setup.py build --debug install --prefix=./tmp
    2. export PYTHONPATH=./tmp/lib/python2.6/site-packages/:$PYTHONPATH

To test the package we can run some of the examples, e.g.:
    ./tmp/lib/python2.6/site-packages/examples/points.py

That should create a points.vtu file in the current directory.
