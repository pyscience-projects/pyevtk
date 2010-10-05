#! /usr/bin/env python

# **************************************************************
# * Example of how to use the low level VtkFile class.         *
# * Author: Paulo A. Herrera                                   *
# **************************************************************

from evtk.vtk import VtkFile, VtkRectilinearGrid
import numpy as np

nx, ny, nz = 6, 6, 2
lx, ly, lz = 1.0, 1.0, 1.0
dx, dy, dz = lx/nx, ly/ny, lz/nz
ncells = nx * ny * nz
npoints = (nx + 1) * (ny + 1) * (nz + 1)
x = np.arange(0, lx + 0.1*dx, dx, dtype='float64')
y = np.arange(0, ly + 0.1*dy, dy, dtype='float64')
z = np.arange(0, lz + 0.1*dz, dz, dtype='float64')
start, end = (0,0,0), (nx, ny, nz)

w = VtkFile("./evtk_test", VtkRectilinearGrid)
w.openGrid(start = start, end = end)
w.openPiece( start = start, end = end)

# Point data
temp = np.random.rand(npoints)
vx = vy = vz = np.zeros([nx + 1, ny + 1, nz + 1], dtype="float64", order = 'F')
w.openData("Point", scalars = "Temperature", vectors = "Velocity")
w.addData("Temperature", temp)
w.addData("Velocity", (vx,vy,vz))
w.closeData("Point")

# Cell data
pressure = np.zeros([nx, ny, nz], dtype="float64", order='F')
w.openData("Cell", scalars = "Pressure")
w.addData("Pressure", pressure)
w.closeData("Cell")

# Coordinates of cell vertices
w.openElement("Coordinates")
w.addData("x_coordinates", x);
w.addData("y_coordinates", y);
w.addData("z_coordinates", z);
w.closeElement("Coordinates");

w.closePiece()
w.closeGrid()

w.appendData(data = temp)
w.appendData(data = (vx,vy,vz))
w.appendData(data = pressure)
w.appendData(x).appendData(y).appendData(z)
w.save()

