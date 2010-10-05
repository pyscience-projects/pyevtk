# **************************************
# *  Simple class to generate a        *
# *  well-formed XML file.             *
# *  Author: Paulo A. Herrera          *
# **************************************

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
        assert (self.openTag)
        for key in kwargs:
            self.stream.write(' %s="%s"'%(key, kwargs[key]))
        return self

