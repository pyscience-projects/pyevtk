######################################################################################
# MIT License
#
# Copyright (c) 2010-2021 Paulo A. Herrera
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
######################################################################################
"""Simple class to generate a well-formed XML file."""


class XmlWriter:
    """
    xml writer class.

    Parameters
    ----------
    filepath : str
        Path to the xml file.
    addDeclaration : bool, optional
        Whether to add the declaration.
        The default is True.
    """

    def __init__(self, filepath, addDeclaration=True):
        self.stream = open(filepath, "wb")
        self.openTag = False
        self.current = []
        if addDeclaration:
            self.addDeclaration()

    def close(self):
        """Close the file."""
        assert not self.openTag
        self.stream.close()

    def addDeclaration(self):
        """Add xml declaration."""
        self.stream.write(b'<?xml version="1.0"?>')

    def openElement(self, tag):
        """Open a new xml element."""
        if self.openTag:
            self.stream.write(b">")
        st = "\n<%s" % tag
        self.stream.write(str.encode(st))
        self.openTag = True
        self.current.append(tag)
        return self

    def closeElement(self, tag=None):
        """
        Close the current element.

        Parameters
        ----------
        tag : str, optional
            Tag of the element.
            The default is None.

        Returns
        -------
        XmlWriter
            The XmlWriter itself for chained calles.
        """
        if tag:
            assert self.current.pop() == tag
            if self.openTag:
                self.stream.write(b">")
                self.openTag = False
            st = "\n</%s>" % tag
            self.stream.write(str.encode(st))
        else:
            self.stream.write(b"/>")
            self.openTag = False
            self.current.pop()
        return self

    def addText(self, text):
        """
        Add text.

        Parameters
        ----------
        text : str
            Text to add.

        Returns
        -------
        XmlWriter
            The XmlWriter itself for chained calles.
        """
        if self.openTag:
            self.stream.write(b">\n")
            self.openTag = False
        self.stream.write(str.encode(text))
        return self

    def addAttributes(self, **kwargs):
        """
        Add attributes.

        Parameters
        ----------
        **kwargs
            keys as attribute names.

        Returns
        -------
        XmlWriter
            The XmlWriter itself for chained calles.
        """
        assert self.openTag
        for key in kwargs:
            st = ' %s="%s"' % (key, kwargs[key])
            self.stream.write(str.encode(st))
        return self
