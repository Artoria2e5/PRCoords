CXXFLAGS += -O3 -funsafe-math-optimizations -std=c++0x -Wall -Wextra -fvisibility=hidden -fvisibility-inlines-hidden

AR ?= ar
DLLTOOL ?= dlltool

# for clang's llvm bitcode: CCAR=llvm-ar
CCAR ?= gcc-ar

# Override when using CYGWIN: make [target] LIB=cyg SO=dll
LIB ?= lib
SO ?= so

# Path to the Microsoft Library Manager (LIB.exe)
# Available from https://aka.ms/buildtools
# Tends to be buried deep, e.g. C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.22.27905\bin\Hostx64\x64
# I recommend putting a shell script called lib.exe in /usr/local/bin to call it with "$@"
#
# Mingw-W64 has a genlib.exe for those who dare to try. It generates MSVC-style
# __IMPORT_DESCRIPTOR_%s. Or maybe the ld -Wl,--out-implib will work with MSVC
# too with __imp symbols only, who knows.
LIBEXE ?= LIB.exe
# Or /machine:x86.
LIBFLAGS ?= /machine:x64

all: libprcoords.a $(LIB)prcoords.$(SO) demo
prec_sample: demo demof demold

# We assume that your copy of "ar" supports the "s" option,
# which does some ranlib work itself.
libprcoords.a: libprcoords.o
	$(AR) rcs libprcoords.a libprcoords.o

libprcoords-lto.a: libprcoords-lto.o
	$(CCAR) rcs libprcoords-lto.a libprcoords-lto.o

$(LIB)prcoords.$(SO): libprcoords.o
	$(CC) -shared -o $(LIB)prcoords.$(SO) libprcoords.o

libprcoords.o: libprcoords.cc
	$(CC) $(CXXFLAGS) -fPIC -c libprcoords.cc

libprcoords-lto.o: libprcoords.cc
	$(CC) $(CXXFLAGS) -flto -ffat-lto-objects -c libprcoords.cc -o libprcoords-lto.o

# Import library generation for MSVC users (optional)
$(LIB)prcoords.def: libprcoords.o
	$(DLLTOOL) --dllname $(LIB)prcoords.$(SO) -z $(LIB)prcoords.def --export-all-symbols libprcoords.o

# Also spits out an .exp
$(LIB)prcoords.lib: $(LIB)prcoords.def
	$(LIBEXE) $(LIBFLAGS) /nologo /def:$(LIB)prcoords.def /out:$(LIB)prcoords.lib

demo: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -o demo demo.cpp

demof: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM=float -DPRCOORDS_STON=stof -o demof demo.cpp

demold: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM='long double' -DPRCOORDS_STON=stold -o demold demo.cpp

# Horray! We do not need import libraries.
demoso: demo.cpp $(LIB)prcoords.$(SO)
	$(CXX) $(CXXFLAGS) -L. -l:$(LIB)prcoords.$(SO) -o demoso demo.cpp

.PHONY: clean help

clean:
	rm -f demo demof demold demo.exe demof.exe demold.exe libprcoords.o libprcoords.a $(LIB)prcoords.$(SO) libprcoords-lto.o libprcoords-lto.a
