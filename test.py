from vtk import VtkFile, VtkRectilinearGrid
from vtk import XmlWriter
import numpy as np

nx = 3
ny = 3
nz = 1
ncells = nx * ny * nz
npoints = (nx + 1) * (ny + 1) * (nz + 1)

temp = np.zeros( [nx + 1, ny + 1, nz + 1], dtype="float64", order='C')

temp[0,0,0] = 0.0
temp[1,0,0] = 1.0
temp[2,0,0] = 2.5
temp[3,0,0] = 12.968
temp[0,1,0] = 3.4
temp[1,1,0] = 4.0
temp[2,1,0] = 5.0

pressure = np.zeros([nx,ny,nz], dtype="float64")
vx = vy = vz = np.zeros([nx+1,ny+1,nz+1], dtype="float64")

w = VtkFile("./data", VtkRectilinearGrid)
w.openGrid(VtkRectilinearGrid, start = (0,0,0), end = (1,1,1))
w.openPiece( start = (0,0,0), end = (1,1,1))

w.openData("Point", scalars = "Temperature", vectors = "Velocity")
w.addData("Temperature", "float64", npoints, 1)
w.addData("Velocity", "float64", npoints, 3)
w.closeData("Point")

w.openData("Cell", scalars = "Pressure")
w.addData("Pressure", "float64", ncells, 1)
w.closeData("Cell")

w.closePiece()
w.closeGrid(VtkRectilinearGrid)

w.appendData(dtype = 'float64', nelem = npoints, ncomp = 1)
w.appendData(data = temp)
w.save()


#xml = XmlWriter("./xml.xml")
#xml.openElement("root")
#xml.openElement("children1")
#xml.closeElement()
#xml.openElement("children2").addAttributes(id = "name", age=34)
#xml.addText("This is text")
#xml.closeElement("children2")
#xml.closeElement("root")
#xml.close()


