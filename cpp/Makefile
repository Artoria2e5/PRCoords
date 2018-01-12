CXXFLAGS += -O3 -fassociative-math

all: libprcoords.a libprcoords.so demo

libprcoords.a: libprcoords.o
	ar rc libprcoords.a libprcoords.o
	ranlib libprcoords.a

libprcoords.so: libprcoords.o
	$(CXX) -shared -o libprcoords.so libprcoords.o

libprcoords.o: libprcoords.cc
	$(CXX) $(CXXFLAGS) -fPIC -c libprcoords.cc

demo: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -o demo demo.cpp
