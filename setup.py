# *************************************************************************
# * Copyright 2010 Paulo Herrera                                          *
# *                                                                       *
# * This file is part of EVTK.                                            *
# *                                                                       *
# * EVTK is free software: you can redistribute it and/or modify          *
# * it under the terms of the GNU General Public License as published by  *
# * the Free Software Foundation, either version 3 of the License, or     *
# * (at your option) any later version.                                   *
# *                                                                       *
# * EVTK is distributed in the hope that it will be useful,               *
# * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# * GNU General Public License for more details.                          *
# *                                                                       *
# * You should have received a copy of the GNU General Public License     *
# * along with EVTK.  If not, see <http://www.gnu.org/licenses/>.         *
# *************************************************************************

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
    ext_modules = [ext],
    data_files = [ ('', 'LICENSE')]
)

