# **************************************
# *  C library for exporting data      *
# *  to binary VTK file.               *
# *  Author: Paulo A. Herrera          *
# **************************************

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
#        Python interface
# ================================  
def writeBlockSize(stream, block_size):
    _writeBlockSize(stream, block_size)

def writeArrayToFile(stream, data):
    _writeArrayToFile(stream, data)

def writeArraysToFile(stream, x, y, z):
    _writeArraysToFile(stream, x, y, z)

# ================================
#        C functions
# ================================ 
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



