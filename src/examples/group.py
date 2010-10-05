from evtk.vtk import VtkGroup

g = VtkGroup("./group")
g.addFile("sim0000.vtu", 0.0)
g.addFile("sim0001.vtu", 1.0)
g.addFile("sim0002.vtu", 2.0)
g.addFile("sim0003.vtu", 3.0)
g.save()
