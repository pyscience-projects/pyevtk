#! /usr/bin/env python

# **************************************************************
# * Example of how to use the high level pointsToVTK function. *
# * Author: Paulo A. Herrera                                   *
# **************************************************************

from evtk.hl import pointsToVTK
import numpy as np

npoints = 100
x = np.random.rand(npoints)
y = np.random.rand(npoints)
z = np.random.rand(npoints)
pressure = np.random.rand(npoints)
temp = np.random.rand(npoints)

pointsToVTK("./points", x, y, z, data = {"temp" : temp, "pressure" : pressure}) 

