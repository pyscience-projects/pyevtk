from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy as np

ext = Extension("vtk", ["vtk.pyx"], include_dirs = [np.get_include()])

setup(
    name = 'evtk',
    description = 'Export data as VTK binary files',
    author = 'Paulo Herrera',
    author_email = 'pauloh81@yahoo.ca',
    url = '',
    cmdclass = {'build_ext': build_ext},
    ext_modules = [ext]
)

