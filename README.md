[![Coverage Status](https://codecov.io/gh/pyscience-projects/pyevtk/branch/master/graph/badge.svg)](https://codecov.io/gh/pyscience-projects/pyevtk)
[![Build Status](https://github.com/pyscience-projects/pyevtk/workflows/Test%20Python/badge.svg)](https://github.com/pyscience-projects/pyevtk/actions?query=workflow%3A%22Test+Python%22)

PREAMBLE:
=========

This package in its entirety belongs to Paulo Herrera and its currently hosted under:

https://github.com/paulo-herrera/PyEVTK

I've misappropriated, well forked and repackaged really, this package in order to host it on PyPI and allow for its easy distribution and installation as I use it a lot. I take no credit whatsoever for it.

My fork is hosted under:

https://github.com/pyscience-projects/pyevtk

This package is nowadays primarily maintained by [René Fritze](https://github.com/renefritze) and [Xylar Asay-Davis](https://github.com/xylar).

INTRODUCTION:
=============

EVTK (Export VTK) package allows exporting data to binary VTK files for
visualization and data analysis with any of the visualization packages that
support VTK files, e.g.  Paraview, VisIt and Mayavi. EVTK does not depend on any
external library (e.g. VTK), so it is easy to install in different systems.

Since version 0.9 the package is composed only of a set of pure Python files, hence
it is straightforwrd to install and run in any system where Python is installed.
EVTK provides low and high level interfaces.  While the low level interface
can be used to export data that is stored in any type of container, the high
level functions make easy to export data stored in Numpy arrays.

INSTALLATION:
=============

This package is being hosted on PyPI under:

https://pypi.python.org/pypi/PyEVTK

and can be installed with pip using `pip install pyevtk`

DOCUMENTATION:
==============

This file together with the included examples in the examples directory in the
source tree provide enough information to start using the package.

DESIGN GUIDELINES:
==================

The design of the package considered the following objectives:

1. Self-contained. The package does not require any external library with
the exception of Numpy, which is becoming a standard package in many Python
installations.

2. Flexibility. It is possible to use EVTK to export data stored in any
container and in any of the grid formats supported by VTK by using the low level
interface.

3. Easy of use. The high level interface makes very easy to export data stored
in Numpy arrays. The high level interface provides functions to export most of
the grids supported by VTK: image data, rectilinear and structured grids. It
also includes a function to export point sets and associated data that can be
used to export results from particle and meshless numerical simulations.

4. Performance. The aim of the package is to be used as a part of
post-processing tools. Thus, good performance is important to handle the results
of large simulations.  However, latest versions give priority to ease of installation
and use over performance.

REQUIREMENTS:
=============

    - Numpy. Tested with Numpy 1.11.3.

The package has been tested on:
    - MacOSX 10.6 x86-64.
    - Ubuntu 10.04 x86-64 guest running on VMWare Fusion.
    - Ubuntu 12.04 x86-64 running Python Anaconda (3.4.3)
    - Windows 7 x86-64 running Python Anaconda (3.4.3)

It is compatible with both Python 2.7 and Python 3.3. Since version 0.9 it is only compatible
with VTK 6.0 and newer versions.

DEVELOPER NOTES:
================

It is useful to build and install the package to a temporary location without
touching the global python site-packages directory while developing. To do
this, while in the root directory, one can type:

    1. python setup.py build --debug install --prefix=./tmp
    2. export PYTHONPATH=./tmp/lib/python2.6/site-packages/:$PYTHONPATH

NOTE: you may have to change the Python version depending of the installed
version on your system.

To test the package one can run some of the examples, e.g.:
./tmp/lib/python2.6/site-packages/examples/points.py

That should create a points.vtu file in the current directory.

SUPPORT:
=======

I will continue releasing this package as open source, so it is free to be used in any kind of project.
I will also continue providing support for simple questions and making incremental improvements as time
allows. However, I also  provide contract based support for commercial or research projects interested
in this package or in topics related to data analysis and scientific programming with Python, Java, MATLAB/Octave, C/C++ or Fortran.
For further details, please contact me to: paulo.herrera.eirl@gmail.com.

**NOTE: PyEVTK moved to GitHub. The new official page is this one (https://github.com/paulo-herrera/PyEVTK)**
