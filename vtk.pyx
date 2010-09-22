cdef extern from "stdio.h":
    ctypedef struct FILE:
        pass

cdef extern from "Python.h":
    #cdef struct _object:
    #    pass
    #ctypedef _object PyObject

    FILE * PyFile_AsFile(object p)
    int fprintf(FILE *stream, char *buf, ...)

#     CONSTANTS
cdef char *VTK_BYTE_ORDER = "LittleEndian"

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
    cdef int size
    cdef char *name

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

cdef void ctest(object p):
    cdef FILE *f = PyFile_AsFile(p)
    fprintf(f, "Hello from C!!!!\n")

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
    
    def test(self):
        ctest(self.stream)



class VtkFile:
    
    def __init__(self, filepath, VtkFileType ftype):
        """
            PARAMETERS:
                filepath: filename without extension.
                ftype: file type, e.g. VtkImageData, etc.
        """

        self.filename = filepath + ftype.ext

    def openElement(self, tag):
        pass 

    def save(self):
        pass
