from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy as np

ext = Extension('evtk.cevtk', ['src/cevtk.pyx'], include_dirs = [np.get_include()])

setup(
    name = 'evtk',
    version = '0.1.0',
    description = 'Export data as VTK binary files',
    author = 'Paulo Herrera',
    author_email = 'pauloh81@yahoo.ca',
    url = '',
    cmdclass = {'build_ext': build_ext},
    packages = ['evtk', 'evtk.examples'],
    package_dir = {'evtk' : 'src'},
    #py_modules = ['hlevtk'],
    ext_modules = [ext]
)

