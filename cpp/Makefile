CXXFLAGS += -O3 -funsafe-math-optimizations -std=c++0x

all: libprcoords.a libprcoords.so demo
prec_sample: demo demof demold

libprcoords.a: libprcoords.o
	ar rc libprcoords.a libprcoords.o
	ranlib libprcoords.a

libprcoords.so: libprcoords.o
	$(CC) -shared -o libprcoords.so libprcoords.o

libprcoords.o: libprcoords.cc
	$(CC) $(CXXFLAGS) -fPIC -c libprcoords.cc

demo: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -o demo demo.cpp

demof: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM=float -DPRCOORDS_STON=stof -o demof demo.cpp

demold: demo.cpp
	$(CXX) $(CXXFLAGS) -DPRCOORDS_DEMO_FORCE_STANDALONE=1 -DPRCOORDS_NUM='long double' -DPRCOORDS_STON=stold -o demold demo.cpp

clean:
	rm -f demo demof demold demo.exe demof.exe demold.exe libprcoords.o libprcoords.a libprcoords.so
