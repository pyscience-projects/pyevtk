import pytest
import os
import runpy


def test_imports():
    import pyevtk
    print(pyevtk.evtk)


def test_examples():
    this_dir = os.path.dirname(os.path.abspath(__file__))
    example_dir = os.path.join(this_dir, '..', 'examples')
    for root, _, files in os.walk(example_dir):
        examples = [os.path.join(root, f) for f in files if f.endswith('.py')]
        for ex in examples:
            runpy.run_path(ex)


def test_compat_lib():
    with pytest.warns(DeprecationWarning):
        import evtk
    import pyevtk
    assert pyevtk.evtk is evtk.evtk
    assert pyevtk.hl is evtk.hl
    assert pyevtk.vtk is evtk.vtk
    assert pyevtk.xml is evtk.xml

