# *************************************************************************
# * Copyright 2010 - 2016 Paulo Herrera                                   *
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

from . import evtk
from . import hl
from . import vtk
from . import xml

from ._version import get_versions
__version__ = get_versions()['version']
del get_versions
