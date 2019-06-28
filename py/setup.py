# This file is a part of PRCoords, a public-domain library
from __future__ import with_statement
from setuptools import setup

with open("../README.md", "r") as f:
    long_description = f.read()

setup(
    name="prcoords",
    version="1.0.0",
    author="Mingye Wang",
    author_email="arthur200126@gmail.com",
    description="Public Domain library for rectifying Chinese coordinates (gcj-02/bd-09)",
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