# This file is a part of PRCoords, a public-domain library
from __future__ import with_statement
from setuptools import setup

description="Public Domain library for rectifying Chinese coordinates (gcj-02/bd-09)"

try:
    with open("../README.md", "r") as f:
        long_description = f.read()
except:
    # Will only happen with non-wheel archives and never on pypi
    long_description = description

setup(
    name="prcoords",
    version="1.0.1",
    author="Mingye Wang",
    author_email="arthur200126@gmail.com",
    description=description,
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/Artoria2e5/PRCoords",
    py_modules=["prcoords"],
    classifiers=[
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 3",
        "Development Status :: 5 - Production/Stable",
        "License :: CC0 1.0 Universal (CC0 1.0) Public Domain Dedication",
        "Operating System :: OS Independent",
        "Topic :: Scientific/Engineering :: GIS",
    ],
)
