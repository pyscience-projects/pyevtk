INTRODUCTION:
=============

EVTK (Export VTK) package allows exporting data to binary VTK files for visualization
and data analysis with any of the visualization packages that support VTK files, e.g.
Paraview, VisIt and Mayavi. EVTK does not depend on any external library (e.g. VTK),
so it is easy to install in different systems.

The package is composed of a set of Python files and a small C/Cython library that 
provides performance critical routines. EVTK provides low and high level interfaces.
The low level interface can be used to export data that is stored in any data structure,
while the high level functions make easy to export data stored in Numpy arrays.

INSTALLATION:
=============

In the source directory type:
python setup.py install

DOCUMENTATION:
==============

This file together with the examples in the examples directory in the source tree
should provide enough information to use the package.

DESIGN GUIDELINES:
==================

The design of the package considered the following objectives:

1. Self-contained. The package does not require any external library with
the exception of Numpy, which is becoming a standard package in many Python
installations.

2. Flexibility. It is possible to use EVTK to export data stored in any data
structure by using the low level interface.

3. Easy of use. The high level interface makes very easy to export data stored
in Numpy arrays. The high level interface provides functions to export most of 
the grids supported by VTK: image data, rectilinear and structured grids. It also
includes a function to export point sets and associated data that can be used 
to export results from particle and meshless numerical simulations.

4. Performance. The aim of the package is to be used as a part of post-processing
tools. Thus, good performance is important to handle the results of large simulations.
To achieve this goal, performance critical routines are implemented as part of a small
C extension.

REQUIREMENTS:
=============
    - Numpy. Tested with Numpy 1.5.0. 
    - Cython. It is only required to re-generate the C file.

The package has been tested on:
    - MacOSX 10.6 x64.

DEVELOPER NOTES:
================

While developing, it is useful to build and install the package to a temporary
location without touching the global python site-packages directory. To do that,
while in the root directory, one can type:

    1. python setup.py build --debug install --prefix=./tmp
    2. export PYTHONPATH=./tmp/lib/python2.6/site-packages/:$PYTHONPATH

NOTE: you may have to change the Python version depending of the installed version
on your system.

To test the package one can run some of the examples, e.g.:
    ./tmp/lib/python2.6/site-packages/examples/points.py

That should create a points.vtu file in the current directory.
