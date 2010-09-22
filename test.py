from vtk import VtkFile, VtkImageData
from vtk import XmlWriter

#w = VtkFile("./data", VtkImageData)
#w.save()
xml = XmlWriter("./xml.xml")
xml.openElement("root")
xml.openElement("children1")
xml.closeElement()
xml.openElement("children2").addAttributes(id = "name", age=34)
xml.addText("This is text")
xml.closeElement("children2")
xml.closeElement("root")
xml.close()


