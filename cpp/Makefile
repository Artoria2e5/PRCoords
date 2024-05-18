CXXFLAGS += -O3 -funsafe-math-optimizations -fno-math-errno -std=c++0x -Wall -Wextra -fvisibility=hidden -fvisibility-inlines-hidden -DNDEBUG

# "Cross compile" shite. In other words MinGW.
# TARGET is Triplet PLUS THE HYPHEN!
CC = $(TARGET)gcc
CXX = $(TARGET)g++
AR ?= $(TARGET)ar
DLLTOOL ?= $(TARGET)dlltool

# for clang's llvm bitcode: CCAR=llvm-ar
CCAR ?= gcc-ar

# Override when using CYGWIN: make [target] LIB=cyg SO=dll
# Override when using MinGW: make [target] LIB='' SO=dll TARGET=x86_64-w64-mingw32-
LIB ?= lib
SO ?= so

# Installation
DESTDIR ?= 
PREFIX ?= /usr/local

# Path to the Microsoft Library Manager (LIB.exe)
# Available from https://aka.ms/buildtools
# Tends to be buried deep, e.g. C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.22.27905\bin\Hostx64\x64
# I recommend putting a shell script called lib.exe in /usr/local/bin to call it with "$@"
#
# Mingw-W64 has a genlib.exe for those who dare to try. It generates MSVC-style
# __IMPORT_DESCRIPTOR_%s. Or maybe the ld -Wl,--out-implib will work with MSVC
# too with __imp symbols only, who knows.
#
# Note that this is only meaningful for MinGW output: Cygwin/MSYS builds have
# dependency for cygwin1.dll, which triggers address-clashes with MSVC's libs.
#
# cl /Fe:demo-cl.exe demo.cc prcoords.lib
LIBEXE ?= LIB.exe
# Or /machine:x86.
LIBFLAGS ?= /machine:x64

all: libprcoords.a $(LIB)prcoords.$(SO) demoso
prec_sample: demo demof demold
windows: all $(LIB)prcoords.lib

# We assume that your copy of "ar" supports the "s" option,
# which does some ranlib work itself.
libprcoords.a: libprcoords.o
	$(AR) rcs libprcoords.a libprcoords.o

libprcoords-lto.a: libprcoords-lto.o
	$(CCAR) rcs libprcoords-lto.a libprcoords-lto.o

$(LIB)prcoords.$(SO): libprcoords.o
	$(CC) -shared -o $(LIB)prcoords.$(SO) libprcoords.o

libprcoords.o: libprcoords.cc badmath.hh
	$(CC) $(CXXFLAGS) -fPIC -c -DPRCOORDS_DLL -DPRCOORDS_DLL_EXPORTS libprcoords.cc

libprcoords-lto.o: libprcoords.cc
	$(CC) $(CXXFLAGS) -flto -ffat-lto-objects -c libprcoords.cc -o libprcoords-lto.o

# Import library generation for MSVC users (optional)
$(LIB)prcoords.def: libprcoords.o
	$(DLLTOOL) --dllname $(LIB)prcoords.$(SO) -z $(LIB)prcoords.def --export-all-symbols libprcoords.o

# Also spits out an .exp
$(LIB)prcoords.lib: $(LIB)prcoords.def
	$(LIBEXE) $(LIBFLAGS) /nologo /def:$(LIB)prcoords.def /out:$(LIB)prcoords.lib

demo: demo.cc libprcoords.cc
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -o demo demo.cc

demof: demo.cc libprcoords.cc
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM=float -DPRCOORDS_STON=stof -o demof demo.cc

demold: demo.cc libprcoords.cc
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM='long double' -DPRCOORDS_STON=stold -o demold demo.cc

# Horray! We do not need import libraries.
# FIXME: COMMAND NOT BUILDING ON MY NIXOS
demoso: demo.cc $(LIB)prcoords.$(SO)
	$(CXX) $(CXXFLAGS) -L. -l:$(LIB)prcoords.$(SO) -o demoso -DPRCOORDS_DLL demo.cc

nanobench.h:
	wget -O nanobench.h https://github.com/martinus/nanobench/raw/master/src/include/nanobench.h

bench: libprcoords.o prcoords.h nanobench.h bench.cc
	$(CXX) $(CXXFLAGS) -DPRCOORDS_BENCH $(DEFS) -o bench libprcoords.o bench.cc

.PHONY: clean help install uninstall

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin/prcoords-demo
	install -s demoso -- $(DESTDIR)$(PREFIX)/bin/prcoords-demo
	mkdir -p $(DESTDIR)$(PREFIX)/lib
	install -m 644 -- libprcoords.a $(LIB)prcoords.$(SO) $(DESTDIR)$(PREFIX)/lib

uninstall:
	rm -f -- $(DESTDIR)$(PREFIX)/bin/prcoords-demo $(DESTDIR)$(PREFIX)/lib/libprcoords.a $(DESTDIR)$(PREFIX)/lib/$(LIB)prcoords.$(SO)

clean:
	$(RM) demo demof demold *.exe *.a *.o *.def *.dll *.obj *.lib *.exp *.obj bench
