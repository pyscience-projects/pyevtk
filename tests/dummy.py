import pytest
import os
import runpy

import numpy as np


def test_imports():
    import pyevtk

    print(pyevtk.evtk)


def test_examples():
    this_dir = os.path.dirname(os.path.abspath(__file__))
    example_dir = os.path.join(this_dir, "..", "examples")
    for root, _, files in os.walk(example_dir):
        examples = [os.path.join(root, f) for f in files if f.endswith(".py")]
        for ex in examples:
            runpy.run_path(ex)


def test_compat_lib():
    with pytest.warns(DeprecationWarning):
        import evtk
    import pyevtk

    assert pyevtk.evtk is evtk.evtk
    assert pyevtk.hl is evtk.hl
    assert pyevtk.vtk is evtk.vtk
    assert pyevtk.xml is evtk.xml


def test_positional_args_only_image():
    from pyevtk.hl import imageToVTK

    nx, ny, nz = 6, 6, 2
    ncells = nx * ny * nz
    npoints = (nx + 1) * (ny + 1) * (nz + 1)

    # Variables
    pressure = np.random.rand(ncells).reshape((nx, ny, nz), order="C")
    temp = np.random.rand(npoints).reshape((nx + 1, ny + 1, nz + 1))

    imageToVTK(
        "./image",
        (0.0, 0.0, 0.0),
        (1.0, 1.0, 1.0),
        {"pressure": pressure},
        {"temp": temp},
    )


def test_positional_args_only_grid():
    from pyevtk.hl import gridToVTK

    nx, ny, nz = 6, 6, 2

    ncells = nx * ny * nz
    npoints = (nx + 1) * (ny + 1) * (nz + 1)

    x = np.zeros((nx + 1, ny + 1, nz + 1))
    y = np.zeros((nx + 1, ny + 1, nz + 1))
    z = np.zeros((nx + 1, ny + 1, nz + 1))

    # Variables
    pressure = np.random.rand(ncells).reshape((nx, ny, nz))
    temp = np.random.rand(npoints).reshape((nx + 1, ny + 1, nz + 1))

    gridToVTK(
        "./structured",
        x,
        y,
        z,
        {"pressure": pressure},
        {"temp": temp},
    )
