# ***********************************************************************************
# * Copyright 2010-2017 Paulo A. Herrera. All rights reserved.                           *
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

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup


def readme(fname):
    with open(fname, 'r') as f:
        return f.read()


setup(
    name='pyevtk',
    version='1.1.0',
    description='Export data as binary VTK files',
    long_description=readme('README.md'),
    author='Paulo Herrera',
    author_email='pauloa.herrera@gmail.com',
    maintainer='Adamos Kyriakou',
    maintainer_email='somada141@gmail.com',
    url='https://bitbucket.org/pauloh/pyevtk',
    packages=['pyevtk'],
    package_dir={'pyevtk': 'pyevtk'},
    package_data={'pyevtk': ['LICENSE.txt', 'examples/*.py']},
    install_requires=[
        "numpy >= 1.8.0",
    ],
    # necessary for 'python setup.py test'
    setup_requires=['pytest-runner'],
    tests_require=['pytest>=3.1', 'pytest-cov'],
)
