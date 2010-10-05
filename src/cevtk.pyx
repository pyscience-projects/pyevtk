import sys
import numpy as np

# ================================
#      External C definitions
# ================================
cdef extern from "stdio.h":
    ctypedef struct FILE:
        pass
    int fprintf(FILE *stream, char *buf, ...)
    int printf(char *buf, ...)
    size_t fwrite (void *array, size_t size, size_t count, FILE *stream)

cdef extern from "Python.h":
    ctypedef struct PyFileObject:
        pass
    FILE * PyFile_AsFile(object p)
    void PyFile_IncUseCount(object p) # The argument should have type PyFileObject *, but it does not work
    void PyFile_DecUseCount(object p)

cdef extern from "numpy/arrayobject.h":
    void import_array()
    void *PyArray_DATA(object obj)
    void* PyArray_GETPTR3(object obj, Py_ssize_t i, Py_ssize_t j, Py_ssize_t k)
    int PyArray_ISCARRAY(object obj)
    int PyArray_ISFARRAY(object obj)

# Initialize Numpy module
import_array()

# ================================
#            VTK Types
# ================================

#     FILE TYPES
cdef class VtkFileType:
    cdef readonly char *name, *ext

    def __init__(self, name, ext):
        self.name = name
        self.ext  = ext

    def __str__(self):
        return "Name: %s  Ext: %s \n" % (self.name, self.ext)

VtkImageData        = VtkFileType("ImageData", ".vti")
VtkPolyData         = VtkFileType("PolyData", ".vtp")
VtkRectilinearGrid  = VtkFileType("RectilinearGrid", ".vtr")
VtkStructuredGrid   = VtkFileType("StructuredGrid", ".vts")
VtkUnstructuredGrid = VtkFileType("UnstructuredGrid", ".vtu")

cdef class VtkDataType:
    cdef readonly int size
    cdef readonly char *name

    def __init__(self, size, name):
        self.size = size
        self.name = name

    def __str__(self):
        return "Type: %s  Size: %d \n" % (self.name, self.size)

#    DATA TYPES
VtkInt8    = VtkDataType(1, "Int8")
VtkUInt8   = VtkDataType(1, "UInt8")
VtkInt16   = VtkDataType(2, "Int16")
VtkUInt16  = VtkDataType(2, "UInt16")
VtkInt32   = VtkDataType(4, "Int32")
VtkUInt32  = VtkDataType(4, "UInt32")
VtkInt64   = VtkDataType(8, "Int64")
VtkUInt64  = VtkDataType(8, "UInt64")
VtkFloat32 = VtkDataType(4, "Float32")
VtkFloat64 = VtkDataType(8, "Float64")

cdef class VtkCellType:
    cdef readonly unsigned char tid
    cdef readonly char *name

    def __init__(self, int tid, char *name):
        self.tid = tid
        self.name = name

    def __str__(self):
        return "VtkCellType( %s ) \n" % ( self.name )

#    CELL TYPES
VtkVertex = VtkCellType(1, "Vertex")
VtkPolyVertex = VtkCellType(2, "PolyVertex")
VtkLine = VtkCellType(3, "Line")
VtkPolyLine = VtkCellType(4, "PolyLine")
VtkTriangle = VtkCellType(5, "Triangle")
VtkTriangleStrip = VtkCellType(6, "TriangleStrip")
VtkPolygon = VtkCellType(7, "Polygon")
VtkPixel = VtkCellType(8, "Pixel")
VtkQuad = VtkCellType(9, "Quad")
VtkTetra = VtkCellType(10, "Tetra")
VtkVoxel = VtkCellType(11, "Voxel")
VtkHexahedron = VtkCellType(12, "Hexahedron")
VtkWedge = VtkCellType(13, "Wedge")
VtkPyramid = VtkCellType(14, "Pyramid")
VtkQuadraticEdge = VtkCellType(21, "Quadratic_Edge")
VtkQuadraticTriangle = VtkCellType(22, "Quadratic_Triangle")
VtkQuadraticQuad = VtkCellType(23, "Quadratic_Quad")
VtkQuadraticTetra = VtkCellType(24, "Quadratic_Tetra")
VtkQuadraticHexahedron = VtkCellType(25, "Quadratic_Hexahedron")

# Map numpy to VTK data types
np_to_vtk = { 'int8'    : VtkInt8,
              'uint8'   : VtkUInt8,
              'int16'   : VtkInt16,
              'uint16'  : VtkUInt16,
              'int32'   : VtkInt32,
              'uint32'  : VtkUInt32,
              'int64'   : VtkInt64,
              'uint64'  : VtkUInt64,
              'float32' : VtkFloat32,
              'float64' : VtkFloat64 }

#cdef void ctest(object p):
#    cdef FILE *f = PyFile_AsFile(p)
#    fprintf(f, "Hello from C!!!!\n")

class XmlWriter:
    def __init__(self, filepath, addDeclaration = True):
        self.stream = open(filepath, "w")
        self.openTag = False
        self.current = []
        if (addDeclaration): self.addDeclaration()

    def close(self):
        assert(not self.openTag)
        self.stream.close()

    def addDeclaration(self):
        self.stream.write('<?xml version="1.0"?>')
    
    def openElement(self, tag):
        if self.openTag: self.stream.write(">")
        self.stream.write("\n<%s" % tag)
        self.openTag = True
        self.current.append(tag)
        return self

    def closeElement(self, tag = None):
        if tag:
            assert(self.current.pop() == tag)
            if (self.openTag):
                self.stream.write(">")
                self.openTag = False
            self.stream.write("\n</%s>" % tag)
        else:
            self.stream.write("/>")
            self.openTag = False
            self.current.pop()
        return self

    def addText(self, text):
        if (self.openTag):
            self.stream.write(">\n")
            self.openTag = False
        self.stream.write(text)
        return self

    def addAttributes(self, **kwargs):
        for key in kwargs:
            self.stream.write(' %s="%s"'%(key, kwargs[key]))
        return self
    

# Helper functions
def _mix_extents(start, end):
    assert (len(start) == len(end) == 3)
    string = "%d %d %d %d %d %d" % (start[0], end[0], start[1], end[1], start[2], end[2])
    return string

def _array_to_string(a):
    s = "".join([`num` + " " for num in a])
    return s

def _get_byte_order():
    if sys.byteorder == "little":
        return "LittleEndian"
    else:
        return "BigEndian"

cdef void _writeBlockSize(object stream, int block_size):
    cdef FILE *f
    stream.flush()          
    f = PyFile_AsFile(stream)
    PyFile_IncUseCount(stream)
    fwrite(&block_size, sizeof(int), 1, f)   # This code is not portable. We should use sizeof(int32_t) instead.
    PyFile_DecUseCount(stream)

cdef void _writeArrayToFile(object stream, object data):
    cdef FILE *f
    cdef void *p
    cdef Py_ssize_t nx, ny, nz
    cdef Py_ssize_t i, j, k

    stream.flush()          
    f = PyFile_AsFile(stream)
    PyFile_IncUseCount(stream)

    # NOTE: If array is 1D, it must have FORTRAN order
    if data.ndim == 1 or PyArray_ISFARRAY(data):
        p = PyArray_DATA(data)
        fwrite(p, data.dtype.itemsize, data.size, f)
    elif data.ndim == 3 and PyArray_ISCARRAY(data):
        shape = data.shape
        nx, ny, nz = shape[0], shape[1], shape[2]
        for k in range(nz):
            for j in range(ny):
                for i in range(nx):
                    p = PyArray_GETPTR3(data, i, j, k)
                    fwrite(p, data.dtype.itemsize, 1, f)
    else:
        assert False
        
    # Release file
    PyFile_DecUseCount(stream)

cdef void _writeArraysToFile(object stream, object x, object y, object z):
    cdef FILE *f
    cdef char *px, *py, *pz    # Hack to avoid checking for correct type cast
    cdef Py_ssize_t nitems, i, j, k, nx, ny, nz
    cdef int itemsize

    # Check if arrays have same shape and data type
    assert ( x.size == y.size == z.size )
    assert ( x.dtype.itemsize == y.dtype.itemsize == z.dtype.itemsize )
  
    nitems = x.size
    itemsize = x.dtype.itemsize

    stream.flush()
    f = PyFile_AsFile(stream)
    PyFile_IncUseCount(stream)
  
    if ( (x.ndim == 1 and y.ndim == 1 and z.ndim == 1) or 
         (PyArray_ISFARRAY(x) and PyArray_ISFARRAY(y) and PyArray_ISFARRAY(z)) ):
        px = <char *>PyArray_DATA(x)
        py = <char *>PyArray_DATA(y)
        pz = <char *>PyArray_DATA(z)
        for i in range(nitems):
            fwrite( &px[i * itemsize], itemsize, 1, f )
            fwrite( &py[i * itemsize], itemsize, 1, f )
            fwrite( &pz[i * itemsize], itemsize, 1, f )

    elif ( (x.ndim == 3 and y.ndim == 3 and z.ndim == 3) and
           (PyArray_ISCARRAY(x) and PyArray_ISCARRAY(y) and PyArray_ISCARRAY(z)) ):
        shape = x.shape
        nx, ny, nz = shape[0], shape[1], shape[2] 
        for k in range(nz):
            for j in range(ny):
                for i in range(nx):
                    px = <char *>PyArray_GETPTR3(x, i, j, k)
                    py = <char *>PyArray_GETPTR3(y, i, j, k)
                    pz = <char *>PyArray_GETPTR3(z, i, j, k)
                    fwrite(px, itemsize, 1, f)
                    fwrite(py, itemsize, 1, f)
                    fwrite(pz, itemsize, 1, f)
    else:
        assert (False)


    # Release file
    PyFile_DecUseCount(stream)

# *********************************
# *     High level functions      *
# *********************************

def _addDataArrayToFile(vtkFile, name, data):
    if type(data).__name__ == "tuple": # vector data
        assert (len(data) == 3)
        x = data[0]
        vtkFile.addData(name, x.dtype.name, x.size, 3)
    else:
        vtkFile.addData(name, data.dtype.name, data.size, 1)

def _addDataToFile(vtkFile, cellData, pointData):
    # Point data
    if pointData <> None:
        keys = pointData.keys()
        vtkFile.openData("Point", scalars = keys[0])
        for key in keys:
            data = pointData[key]
            _addDataArrayToFile(vtkFile, key, data)
        vtkFile.closeData("Point")

    # Cell data
    if cellData <> None:
        keys = cellData.keys()
        vtkFile.openData("Cell", scalars = keys[0])
        for key in keys:
            data = cellData[key]
            _addDataArrayToFile(vtkFile, key, data)
        vtkFile.closeData("Cell")

def _appendDataToFile(vtkFile, cellData, pointData):
    # Append data to binary section
    if pointData <> None:
        keys = pointData.keys()
        for key in keys:
            data = pointData[key]
            vtkFile.appendData(data)

    if cellData <> None:
        keys = cellData.keys()
        for key in keys:
            data = cellData[key]
            vtkFile.appendData(data)

def imageToVTK(path, origin = (0.0,0.0,0.0), spacing = (1.0,1.0,1.0), cellData = None, pointData = None ):
    """ Exports data values as a rectangular image.
        
        PARAMETERS:
            path: name of the file without extension where data should be saved.
            origin: grid origin (default = (0,0,0))
            spacing: grid spacing (default = (1,1,1))
            cellData: dictionary containing arrays with cell centered data.
                      Keys should be the names of the data arrays.
                      Arrays must have the same dimensions in all directions and must contain 
                      only scalar data.
            nodeData: dictionary containing arrays with node centered data.
                      Keys should be the names of the data arrays.
                      Arrays must have same dimension in each direction and 
                      they should be equal to the dimensions of the cell data plus one and
                      must contain only scalar data.

        NOTE: At least, cellData or pointData must be present to infer the dimensions of the image.
    """
    assert (cellData <> None or pointData <> None)
    
    # Extract dimensions
    start = (0,0,0)
    end = None
    if cellData <> None:
        keys = cellData.keys()
        data = cellData[keys[0]]
        end = data.shape
    elif pointData <> None:
        keys = pointData.keys()
        data = pointData[keys[0]]
        end = data.shape
        end = (end[0] - 1, end[1] - 1, end[1] - 1)

    # Write data to file
    w = VtkFile(path, VtkImageData)
    w.openGrid(start = start, end = end, origin = origin, spacing = spacing)
    w.openPiece(start = start, end = end)
    _addDataToFile(w, cellData, pointData)
    w.closePiece()
    w.closeGrid()
    _appendDataToFile(w, cellData, pointData)
    w.save()


def gridToVTK(path, x, y, z, cellData = None, pointData = None):
    """
        Writes data values as a rectilinear or rectangular grid.

        PARAMETERS:
            path: name of the file without extension where data should be saved.
            x, y, z: coordinates of the nodes of the grid. They can be 1D or 3D depending if
                     the grid should be saved as a rectilinear or logically structured grid, respectively.
                     Arrays should contain coordinates of the nodes of the grid.
                     If arrays are 1D, then the grid should be Cartesian, i.e. faces in all cells are orthogonal.
                     If arrays are 3D, then the grid should be logically structured with hexahedral cells.
                     In both cases the arrays dimenions should be equal to the number of nodes of the grid.
            cellData: dictionary containing arrays with cell centered data.
                      Keys should be the names of the data arrays.
                      Arrays must have the same dimensions in all directions and must contain 
                      only scalar data.
            nodeData: dictionary containing arrays with node centered data.
                      Keys should be the names of the data arrays.
                      Arrays must have same dimension in each direction and 
                      they should be equal to the dimensions of the cell data plus one and
                      must contain only scalar data.
    """

    # Extract dimensions
    start = (0,0,0)
    isRect = False
    nx = ny = nz = 0
    ftype = VtkStructuredGrid

    if (x.ndim == 1 and y.ndim == 1 and z.ndim == 1):
        nx, ny, nz = x.size - 1, y.size - 1, z.size - 1
        isRect = True
        ftype = VtkRectilinearGrid
    elif (x.ndim == 3 and y.ndim == 3 and z.ndim == 3):
        s = x.shape
        nx, ny, nz = s[0] - 1, s[1] - 1, s[2] - 1
    else:
        assert(False)
    end = (nx, ny, nz)

    w =  VtkFile(path, ftype)
    w.openGrid(start = start, end = end)
    w.openPiece(start = start, end = end)

    if isRect:
        w.openElement("Coordinates")
        _addDataArrayToFile(w, "x_coordinates", x)
        _addDataArrayToFile(w, "y_coordinates", y)
        _addDataArrayToFile(w, "z_coordinates", z)
        w.closeElement("Coordinates")
    else:
        w.openElement("Points")
        _addDataArrayToFile(w, "points", (x,y,z))
        w.closeElement("Points")

    _addDataToFile(w, cellData, pointData)
    w.closePiece()
    w.closeGrid()
    # Write coordinates
    if isRect:
        w.appendData(x).appendData(y).appendData(z)
    else:
        w.appendData( (x,y,z) )
    # Write data
    _appendDataToFile(w, cellData, pointData)
    w.save()

def pointsToVTK(path, x, y, z, data):
    """
        Export points and associated data as an unstructured grid.

        PARAMETERS:
            path: name of the file without extension where data should be saved.
            x, y, z: 1D arrays with coordinates of the points.
            data: dictionary with variables associated to each point.
                  Keys should be the names of the variable stored in each array.
                  All arrays must have the same number of elements.
    """
    assert (x.size == y.size == z.size)
    npoints = x.size
    
    # create some temporary arrays to write grid topology
    offsets = np.arange(start = 1, stop = npoints + 1, dtype = 'int32')   # index of last node in each cell
    connectivity = np.arange(npoints, dtype = 'int32')                   # each point is only connected to itself
    cell_types = np.empty(npoints, dtype = 'uint8') 
   
    cell_types[:] = VtkVertex.tid

    w = VtkFile(path, VtkUnstructuredGrid)
    w.openGrid()
    w.openPiece(ncells = npoints, npoints = npoints)
    
    w.openElement("Points")
    _addDataArrayToFile(w, "points", (x,y,z))
    w.closeElement("Points")
    w.openElement("Cells")
    _addDataArrayToFile(w, "connectivity", connectivity)
    _addDataArrayToFile(w, "offsets", offsets)
    _addDataArrayToFile(w, "types", cell_types)
    w.closeElement("Cells")
    
    _addDataToFile(w, cellData = None, pointData = data)

    w.closePiece()
    w.closeGrid()
    w.appendData( (x,y,z) )
    w.appendData(connectivity).appendData(offsets).appendData(cell_types)

    _appendDataToFile(w, cellData = None, pointData = data)

    w.save()


# *********************************
# *       Low level class         *
# *********************************

class VtkFile:
    
    def __init__(self, filepath, VtkFileType ftype):
        """
            PARAMETERS:
                filepath: filename without extension.
                ftype: file type, e.g. VtkImageData, etc.
        """
        self.ftype = ftype
        filename = filepath + ftype.ext
        self.xml = XmlWriter(filename)
        self.offset = 0  # offset in bytes after beginning of binary section
        self.appendedDataIsOpen = False

        self.xml.openElement("VTKFile").addAttributes(type = ftype.name,
                                                      version = "0.1",
                                                      byte_order = _get_byte_order())

    def openPiece(self, start = None, end = None,
                        npoints = None, ncells = None,
                        nverts = None, nlines = None, nstrips = None, npolys = None): 
        """ Open piece section.
            
            PARAMETERS:
                Next two parameters must be given together.
                start: array or list with start indexes in each direction.
                end:   array or list with end indexes in each direction.

                npoints: number of points in piece (int).
                ncells: number of cells in piece (int). If present,
                        npoints must also be given.

                All the following parameters must be given together with npoints.
                They shoudl all be integer values.
                nverts:
                nlines:
                nstrips:
                npolys:

            RETURNS:
                this VtkFile to allow chained calls.
        """
        # TODO: Check what are the requirements for each type of grid.

        self.xml.openElement("Piece")
        if (start and end):
            ext = _mix_extents(start, end)
            self.xml.addAttributes( Extent = ext)
        
        elif (ncells and npoints):
            self.xml.addAttributes(NumberOfPoints = npoints, NumberOfCells = ncells)

        elif (npoints and nverts and nlines and nstrips and npolys):
            self.xml.addAttributes(npoints = npoints, nverts = nverts,
                    nlines = nlines, nstrips = nstrips, npolys = npolys)
        else:
            assert(False)

        return self

    def closePiece(self):
        self.xml.closeElement("Piece")

    def openData(self, nodeType, scalars=None, vectors=None, normals=None, tensors=None, tcoords=None):
        """ Open data section.

            PARAMETERS:
                nodeType: Point or Cell.
                scalars: default data array name for scalar data.
                vectors: default data array name for vector data.
                normals: default data array name for normals data.
                tensors: default data array name for tensors data.
                tcoords: dafault data array name for tcoords data.

            RETURNS:
                this VtkFile to allow chained calls.
        """
        self.xml.openElement(nodeType + "Data")
        if scalars:
            self.xml.addAttributes(scalars = scalars)
        if vectors:
            self.xml.addAttributes(vectors = vectors)
        if normals:
            self.xml.addAttributes(normals = normals)
        if tensors:
            self.xml.addAttributes(tensors = tensors)
        if tcoords:
            self.xml.addAttributes(tcoords = tcoords)

        return self

    def closeData(self, nodeType):
        """ Close data section.

            PARAMETERS:
                nodeType: Point or Cell.
 
            RETURNS:
                this VtkFile to allow chained calls.
        """
        self.xml.closeElement(nodeType + "Data")


    def openGrid(self, start = None, end = None, origin = None, spacing = None):
        """ Open grid section.

            PARAMETERS:
                start: array or list of start indexes. Required for Structured, Rectilinear and ImageData grids.
                end: array or list of end indexes. Required for Structured, Rectilinear and ImageData grids.
                origin: 3D array or list with grid origin. Only required for ImageData grids.
                spacing: 3D array or list with grid spacing. Only required for ImageData grids.

            RETURNS:
                this VtkFile to allow chained calls.
        """
        gType = self.ftype.name
        self.xml.openElement(gType)
        if (gType == VtkImageData.name):
            if (not start or not end or not origin or not spacing): assert(False)
            ext = _mix_extents(start, end)
            self.xml.addAttributes(WholeExtent = ext,
                                   Origin = _array_to_string(origin),
                                   Spacing = _array_to_string(spacing))
        
        elif (gType == VtkStructuredGrid.name or gType == VtkRectilinearGrid.name):
            if (not start or not end): assert (False)
            ext = _mix_extents(start, end)
            self.xml.addAttributes(WholeExtent = ext) 
                
        return self

    def closeGrid(self):
        """ Close grid element.

            RETURNS:
                this VtkFile to allow chained calls.
        """
        self.xml.closeElement(self.ftype.name)

    
    def addData(self, name, dtype, nelem, ncomp):
        dtype = np_to_vtk[dtype]

        self.xml.openElement( "DataArray")
        self.xml.addAttributes( Name = name,
                                NumberOfComponents = ncomp,
                                type = dtype.name,
                                format = "appended",
                                offset = self.offset)
        self.xml.closeElement()

        #TODO: Check if 4 is platform independent
        self.offset += nelem * ncomp * dtype.size + 4 # add 4 to indicate array size
        return self

    def appendHeader(self, dtype, nelem, ncomp):
        """ This function only writes the size of the data block that will be appended.
            The data itself must be written immediately after calling this function.
            
            PARAMETERS:
                dtype: string with data type representation (same as numpy). For example, 'float64'
                nelem: number of elements.
                ncomp: number of components, 1 (scalar) or 3 (vector).
        """
        cdef int block_size, dsize

        self.openAppendedData()
        dsize = np_to_vtk[dtype].size
        block_size = dsize * ncomp * nelem
        _writeBlockSize(self.xml.stream, block_size)

            
    def appendData(self, data):
        """ Append data to binary section.
            This function writes the header section and the data to the binary file.

            PARAMETERS:
                data: one numpy array or a tuple with 3 numpy arrays. If a tuple, the individual
                      arrays must represent the components of a vector field.
                      All arrays must be one dimensional or 3D with Fortran order.
                      The order of the arrays must coincide with the numbering scheme of the grid.
            
            RETURNS:
                this VtkFile to allow chained calls

            TODO: Extend this function to accept contiguous C order arrays.
        """

        cdef int block_size, nelem   # VTK expect and int32 for this number 
        self.openAppendedData()

        if type(data).__name__ == 'tuple': # 3 numpy arrays
            ncomp = len(data)
            assert (ncomp == 3)
            dsize = data[0].dtype.itemsize
            nelem = data[0].size
            block_size = ncomp * nelem * dsize
            _writeBlockSize(self.xml.stream, block_size)
            x, y, z = data[0], data[1], data[2]
            _writeArraysToFile(self.xml.stream, x, y, z)

        else: # single numpy array
            ncomp = 1       
            dsize = data.dtype.itemsize
            nelem = data.size
            block_size = ncomp * nelem * dsize
            _writeBlockSize(self.xml.stream, block_size)
            _writeArrayToFile(self.xml.stream, data)

        return self

    def openAppendedData(self):
        """ 
            Open binary section.
            It is not necessary to explicitly call this function.
        """
        if not self.appendedDataIsOpen:
            self.xml.openElement("AppendedData").addAttributes(encoding = "raw").addText("_")
            self.appendedDataIsOpen = True

    def closeAppendedData(self):
        """ 
            Close binary section.
            It is not necessary to explicitly call this function.
        """
        self.xml.closeElement("AppendedData")

    def openElement(self, tagName):
        """ Useful to add elements such as: Coordinates, Points, Verts, etc. """
        self.xml.openElement(tagName)

    def closeElement(self, tagName):
        self.xml.closeElement(tagName)

    def save(self):
        if self.appendedDataIsOpen:
            self.xml.closeElement("AppendedData")
        self.xml.closeElement("VTKFile")
        self.xml.close()
    
