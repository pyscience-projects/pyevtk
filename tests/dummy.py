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
