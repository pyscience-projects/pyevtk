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
    #cdef struct _object:
    #    pass
    #ctypedef _object PyObject

    FILE * PyFile_AsFile(object p)
    void PyFile_IncUseCount(object p)
    void PyFile_DecUseCount(object p)

cdef extern from "numpy/arrayobject.h":
    void *PyArray_DATA(object obj)
    int PyArray_ISCARRAY(object obj)
    int PyArray_ISFARRAY(object obj)

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
    

# Helper function
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

class VtkFile:
    
    def __init__(self, filepath, VtkFileType ftype):
        """
            PARAMETERS:
                filepath: filename without extension.
                ftype: file type, e.g. VtkImageData, etc.
        """

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
            self.xml.addAttributes(npoints = npoints, ncells = ncells)

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


    def openGrid(self, gridType, start = None, end = None, origin = None, spacing = None):
        """ Open grid section.

            PARAMETERS:
                gridType: one of the VtkFileType, e.g. VtkStructuredGrid.
                start: array or list of start indexes. Required for Structured, Rectilinear and ImageData grids.
                end: array or list of end indexes. Required for Structured, Rectilinear and ImageData grids.
                origin: 3D array or list with grid origin. Only required for ImageData grids.
                spacing: 3D array or list with grid spacing. Only required for ImageData grids.

            RETURNS:
                this VtkFile to allow chained calls.
        """
        gType = gridType.name
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

    def closeGrid(self, gridType):
        """ Open grid section.

            PARAMETERS:
                gridType: one of the VtkFileType, e.g. VtkStructuredGrid.

            RETURNS:
                this VtkFile to allow chained calls.
        """
        self.xml.closeElement(gridType.name)

    
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

    def appendData(self, data = None, dtype = None, nelem = None, ncomp = None):
        cdef int block_size, dsize
        cdef void *p
        cdef FILE *f

        self.openAppendedData()

        if data is not None:
            dsize = data.dtype.itemsize
            nelem = data.size
            ncomp = 1             # change this for 3 components

        elif dtype and nelem and ncomp:
            dsize = np_to_vtk[dtype].size

        else:
            assert(False)
        
        # Write data block size
        block_size = dsize * ncomp * nelem
        self.xml.stream.flush()                 # flush the stream buffer
        f = PyFile_AsFile(self.xml.stream)
        PyFile_IncUseCount(self.xml.stream)
        fwrite(&block_size, sizeof(int), 1, f)

        # Write data array if present
        if data is not None:
            # Check if array is contiguous and it has Fortran order
            # TODO: Make sure we release the lock for the file
            if not PyArray_ISFARRAY(data): assert(False)

            p = PyArray_DATA(data)
            fwrite(p, data.dtype.itemsize, data.size, f)
        
        # Release file
        PyFile_DecUseCount(self.xml.stream)

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

    def save(self):
        if self.appendedDataIsOpen:
            self.xml.closeElement("AppendedData")
        self.xml.closeElement("VTKFile")
        self.xml.close()
    
