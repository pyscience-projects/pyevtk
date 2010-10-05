# **************************************************************
# * Example of how to use the high level imageToVTK function.  *
# * Author: Paulo A. Herrera                                   *
# * Created: Mon 04 Oct 2010 10:22:08 AM CEST                  *
# * Last Modified: Mon 04 Oct 2010 11:16:19 AM CEST            *
# **************************************************************

from vtk import imageToVTK
import numpy as np

# Dimensions
nx, ny, nz = 6, 6, 2
ncells = nx * ny * nz
npoints = (nx + 1) * (ny + 1) * (nz + 1)

# Variables
pressure = np.random.rand(ncells).reshape( (nx, ny, nz), order = 'C')
temp = np.random.rand(npoints).reshape( (nx + 1, ny + 1, nz + 1))

imageToVTK("./image", cellData = {"pressure" : pressure}, pointData = {"temp" : temp} )

