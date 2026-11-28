# This file is a part of PRCoords, a public-domain library
from __future__ import with_statement
import io
import os
import shutil
from setuptools import setup
from setuptools.command.build_py import build_py as _build_py
from setuptools.command.sdist import sdist as _sdist

description = "Public Domain library for rectifying Chinese coordinates (gcj-02/bd-09)"

class build_py(_build_py):
    def run(self):
        super().run()
        for name in ("prcoords.pyi", "py.typed"):
            self.copy_file(name, os.path.join(self.build_lib, name))

class sdist(_sdist):
    def run(self):
        here = os.path.abspath(os.path.dirname(__file__))
        source = os.path.join(here, "..", "README.md")
        target = os.path.join(here, "README.md")
        copied = False
        if not os.path.exists(target) and os.path.exists(source):
            shutil.copyfile(source, target)
            copied = True
        try:
            super().run()
        finally:
            if copied:
                os.remove(target)

try:
    with io.open("README.md", "r", encoding="utf-8") as f:
        long_description = f.read()
except:
    # Building from the repository root before README.md is copied here.
    with io.open("../README.md", "r", encoding="utf-8") as f:
        long_description = f.read()

setup(
    name="prcoords",
    version="1.2.1",
    author="Mingye Wang",
    author_email="arthur200126@gmail.com",
    description=description,
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Artoria2e5/PRCoords",
    py_modules=["prcoords"],
    cmdclass={"build_py": build_py, "sdist": sdist},
    classifiers=[
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 3",
        "Typing :: Typed",
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering :: GIS",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
)
