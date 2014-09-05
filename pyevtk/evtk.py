# ***********************************************************************************
# * Copyright 2010 - 2014 Paulo A. Herrera. All rights reserved.                    * 
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

import struct
import numpy as np
import sys

# Map numpy dtype to struct format
np_to_struct = { 'int8'    : 'b',
                 'uint8'   : 'B',
                 'int16'   : 'h',
                 'uint16'  : 'H',
                 'int32'   : 'i',
                 'uint32'  : 'I',
                 'int64'   : 'q',
                 'uint64'  : 'Q',
                 'float32' : 'f',
                 'float64' : 'd' }
              
def _get_byte_order_char():
# Check format in https://docs.python.org/3.5/library/struct.html
    if sys.byteorder == "little":
        return '<'
    else:
        return '>'
        
# ================================
#        Python interface
# ================================  
def writeBlockSize(stream, block_size):
    fmt = _get_byte_order_char() + 'Q' # Write size as unsigned long long == 64 bits unsigned integer
    stream.write(struct.pack(fmt, block_size))

def writeArrayToFile(stream, data):
    #stream.flush() # this should not be necessary          
    assert (data.ndim == 1 or data.ndim == 3)
    fmt = _get_byte_order_char() + str(data.size) + np_to_struct[data.dtype.name]  # > for big endian

    # NOTE: VTK expects data in FORTRAN order
    if data.flags['C_CONTIGUOUS']: #this is only relevant for multidimensional arrays
        dd = np.asfortranarray(data.T).ravel()
    else:
        dd = data.ravel()
    bin = struct.pack(fmt, *dd)
    stream.write(bin)
    
# ==============================================================================
def writeArraysToFile(stream, x, y, z):
    # Check if arrays have same shape and data type
    assert ( x.size == y.size == z.size ), "Different array sizes."
    assert ( x.dtype.itemsize == y.dtype.itemsize == z.dtype.itemsize ), "Different item sizes."
  
    nitems = x.size
    itemsize = x.dtype.itemsize

    fmt = _get_byte_order_char() + str(1) + np_to_struct[x.dtype.name]  # > for big endian
    if (x.flags['C_CONTIGUOUS']):  
        xx = np.asfortranarray(x.T).ravel()
    else:
	xx = x.ravel()

    if (y.flags['C_CONTIGUOUS']):
        yy = np.asfortranarray(y.T).ravel()
    else:
        yy = y.ravel()

    if (z.flags['C_CONTIGUOUS']):
        zz = np.asfortranarray(z.T).ravel()
    else:
        zz = z.ravel()    
        
    # eliminate this loop by creating a composed array.
    for i in range(nitems):
        bx = struct.pack(fmt, xx[i])
        by = struct.pack(fmt, yy[i])
        bz = struct.pack(fmt, zz[i])
        stream.write(bx)
        stream.write(by)
        stream.write(bz)
