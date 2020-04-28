import pytest
import os
import runpy

THIS_DIR = os.path.dirname(os.path.abspath(__file__))


def test_imports():
    import pyevtk
    print(pyevtk.evtk)


def test_examples():
    example_dir = os.path.join(THIS_DIR, '..', 'examples')
    for root, _, files in os.walk(example_dir):
        examples = [os.path.join(root, f) for f in files if f.endswith('.py')]
        for ex in examples:
            runpy.run_path(ex)


def _try_xml(fn):
    import xml.etree.ElementTree as ET
    try:
        ET.parse(fn)
        return True, None
    except Exception as e:
        return False, 'try_xml failed on {} with msg:\n{}'.format(fn, str(e))


def _try_meshio(fn):
    try:
        import meshio
    except ImportError:
        return True, None
    try:
        meshio.read(fn)
        return True, None
    except Exception as e:
        return False, 'try_meshio failed on {} with msg:\n{}'.format(fn, str(e))


# This would ideally get a parameterized fixture
def test_xml_compat():
    # to produce vtu files
    test_examples()
    for root, _, files in os.walk(os.path.join(THIS_DIR, '..')):
        for fn in (os.path.join(root, f) for f in files if f.endswith('.vtu')):
            for chk in ['xml', 'meshio']:
                check, msg = globals()['_try_{}'.format(chk)](fn)
            assert check, msg


def test_compat_lib():
    with pytest.warns(DeprecationWarning):
        import evtk
    import pyevtk
    assert pyevtk.evtk is evtk.evtk
    assert pyevtk.hl is evtk.hl
    assert pyevtk.vtk is evtk.vtk
    assert pyevtk.xml is evtk.xml

