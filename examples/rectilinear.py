#! /usr/bin/env python

# ***********************************************************************************
# * Copyright 2010 - 2016 Paulo A. Herrera. All rights reserved.                    *
# *                                                                                 *
# * Redistribution and use in source and binary forms, with or without              *
# * modification, are permitted provided that the following conditions are met:     *
# *                                                                                 *
# *  1. Redistributions of source code must retain the above copyright notice,      *
# *  this list of conditions and the following disclaimer.                          *
# *                                                                                 *
# *  2. Redistributions in binary form must reproduce the above copyright notice,   *
# *  this list of conditions and the following disclaimer in the documentation      *
# *  and/or other materials provided with the distribution.                         *
# *                                                                                 *
# * THIS SOFTWARE IS PROVIDED BY PAULO A. HERRERA ``AS IS'' AND ANY EXPRESS OR      *
# * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF    *
# * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO      *
# * EVENT SHALL <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,        *
# * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,  *
# * BUT NOT LIMITED TO, PROCUREMEN OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    *
# * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY           *
# * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING  *
# * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS              *
# * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                    *
# ***********************************************************************************

# **************************************************************
# * Example of how to use the high level gridToVTK function.   *
# * This example shows how to export a rectilinear grid.       *
# **************************************************************

from pyevtk.hl import gridToVTK, writeParallelVTKGrid
import numpy as np

# ==================
# Serial example
# ==================

# Dimensions
nx, ny, nz = 6, 6, 2
lx, ly, lz = 1.0, 1.0, 1.0
dx, dy, dz = lx / nx, ly / ny, lz / nz

ncells = nx * ny * nz
npoints = (nx + 1) * (ny + 1) * (nz + 1)

# Coordinates
x = np.arange(0, lx + 0.1 * dx, dx, dtype="float64")
y = np.arange(0, ly + 0.1 * dy, dy, dtype="float64")
z = np.arange(0, lz + 0.1 * dz, dz, dtype="float64")

# Variables
pressure = np.random.rand(ncells).reshape((nx, ny, nz))
temp = np.random.rand(npoints).reshape((nx + 1, ny + 1, nz + 1))

gridToVTK(
    "./rectilinear",
    x,
    y,
    z,
    cellData={"pressure": pressure},
    pointData={"temp": temp},
)


# ==================
# Parallel example
# ==================

# Dimensions
x1 = np.linspace(0, 1, 10)
x2 = np.linspace(1, 2, 20)

y = np.linspace(0, 1, 10)
z = np.linspace(0, 1, 10)

gridToVTK("test.0", x1, y, z, start=(0, 0, 0))
gridToVTK("test.1", x2, y, z, start=(9, 0, 0))

writeParallelVTKGrid(
    "test_full",
    coordsData=((29, 10, 10), x.dtype),
    starts=[(0, 0, 0), (9, 0, 0)],
    ends=[(9, 9, 9), (28, 9, 9)],
    sources=["test.0.vtr", "test.1.vtr"],
)
