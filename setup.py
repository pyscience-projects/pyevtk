######################################################################################
# MIT License
#
# Copyright (c) 2010-2024 Paulo A. Herrera
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

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

import versioneer


def readme(fname):
    """Open the readme file."""
    with open(fname, "r") as f:
        return f.read()


setup(
    name="pyevtk",
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    description="Export data as binary VTK files",
    long_description=readme("README.md"),
    long_description_content_type="text/markdown",
    author="Paulo Herrera",
    author_email="pauloa.herrera@gmail.com",
    maintainer="Adamos Kyriakou",
    maintainer_email="somada141@gmail.com",
    license="MIT",
    url="https://github.com/pyscience-projects/pyevtk",
    packages=["pyevtk", "evtk"],
    package_dir={"pyevtk": "pyevtk"},
    package_data={"pyevtk": ["LICENSE.txt", "examples/*.py"]},
    install_requires=["numpy >= 1.8.0"],
    classifiers=[
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: 3.13",
        "Programming Language :: Python :: 3.14",
    ],
)
