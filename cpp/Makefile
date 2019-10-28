CXXFLAGS += -O3 -funsafe-math-optimizations -std=c++0x -Wall -Wextra -fvisibility=hidden -fvisibility-inlines-hidden

# for clang's llvm bitcode: llvm-ar/llvm-ranlib
CCAR ?= gcc-ar
# CCRANLIB ?= gcc-ranlib

# Override when using CYGWIN: make [target] LIB=cyg SO=dll
LIB ?= lib
SO ?= so

all: libprcoords.a $(LIB)prcoords.$(SO) demo
prec_sample: demo demof demold

# We assume that your copy of "ar" supports the "s" option,
# which does some ranlib work itself.
libprcoords.a: libprcoords.o
	ar rcs libprcoords.a libprcoords.o

libprcoords-lto.a: libprcoords-lto.o
	$(CCAR) rcs libprcoords-lto.a libprcoords-lto.o

$(LIB)prcoords.$(SO): libprcoords.o
	$(CC) -shared -o $(LIB)prcoords.$(SO) libprcoords.o

libprcoords.o: libprcoords.cc
	$(CC) $(CXXFLAGS) -fPIC -c libprcoords.cc

libprcoords-lto.o: libprcoords.cc
	$(CC) $(CXXFLAGS) -flto -ffat-lto-objects -c libprcoords.cc -o libprcoords-lto.o

demo: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -o demo demo.cpp

demof: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM=float -DPRCOORDS_STON=stof -o demof demo.cpp

demold: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM='long double' -DPRCOORDS_STON=stold -o demold demo.cpp

# Let's not talk about the slow awful MSVC import-library BS.
demoso: demo.cpp $(LIB)prcoords.$(SO)
	$(CXX) $(CXXFLAGS) -L. -l:$(LIB)prcoords.$(SO) -o demoso demo.cpp

.PHONY: clean help

clean:
	rm -f demo demof demold demo.exe demof.exe demold.exe libprcoords.o libprcoords.a $(LIB)prcoords.$(SO) libprcoords-lto.o libprcoords-lto.a
