from cevtk import VtkFile, VtkRectilinearGrid
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

#temp = np.zeros( [nx + 1, ny + 1, nz + 1], dtype="float64", order='F')
temp = np.random.rand(npoints)
vx = vy = vz = np.zeros([nx + 1, ny + 1, nz + 1], dtype="float64", order = 'F')

# Point data
w.openData("Point", scalars = "Temperature", vectors = "Velocity")
w.addData("Temperature", "float64", npoints, 1)
w.addData("Velocity", "float64", npoints, 3)
w.closeData("Point")

# Cell data
pressure = np.zeros([nx, ny, nz], dtype="float64", order='F')
w.openData("Cell", scalars = "Pressure")
w.addData("Pressure", "float64", ncells, 1)
w.closeData("Cell")

# Coordinates of cell vertices
w.openElement("Coordinates")
w.addData("x_coordinates", 'float64', nx + 1, 1);
w.addData("y_coordinates", 'float64', ny + 1, 1);
w.addData("z_coordinates", 'float64', nz + 1, 1);
w.closeElement("Coordinates");

w.closePiece()
w.closeGrid()

w.appendData(data = temp)
w.appendData(data = (vx,vy,vz))
w.appendData(data = pressure)
w.appendData(x).appendData(y).appendData(z)
w.save()

