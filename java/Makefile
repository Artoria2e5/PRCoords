# Java port plus an optional JNI bridge into ../cpp.
#
# "make" builds the Java classes only and needs nothing but a JDK 9 or newer
# on PATH; the classes themselves target Java 8. "make native" additionally builds the bridge, which needs a C++
# compiler. Without the bridge the classes fall back to the Java code.

JAVAC ?= javac
JAVACFLAGS ?= --release 8 -Xlint:-options
JAVA ?= java
CXX ?= g++
PYTHON ?= python
# Take the headers from whatever javac will run, not from a stale JAVA_HOME.
JAVA_HOME := $(shell dirname "$$(dirname "$$(command -v $(JAVAC))")")

BUILD := build
CLASSES := $(BUILD)/classes
SRC := $(wildcard src/main/java/io/github/artoria2e5/prcoords/*.java)

ifeq ($(OS),Windows_NT)
  LIB := $(BUILD)/prcoords_jni.dll
  JNI_PLATFORM := win32
  JNI_LDFLAGS := -shared -static-libgcc -static-libstdc++
else
  UNAME := $(shell uname -s)
  ifeq ($(UNAME),Darwin)
    LIB := $(BUILD)/libprcoords_jni.dylib
    JNI_PLATFORM := darwin
    JNI_LDFLAGS := -dynamiclib
  else
    LIB := $(BUILD)/libprcoords_jni.so
    JNI_PLATFORM := linux
    JNI_LDFLAGS := -shared -fPIC
  endif
endif

all: classes

classes: $(CLASSES)/.stamp

native: $(LIB)

$(CLASSES)/.stamp: $(SRC)
	mkdir -p $(CLASSES)
	$(JAVAC) $(JAVACFLAGS) -d $(CLASSES) $(SRC)
	touch $@

$(LIB): cpp/prcoords_jni.cc ../cpp/libprcoords.cc ../cpp/prcoords.h
	mkdir -p $(BUILD)
	$(CXX) -O2 $(JNI_LDFLAGS) -I"$(JAVA_HOME)/include" -I"$(JAVA_HOME)/include/$(JNI_PLATFORM)" -I../cpp -o $@ cpp/prcoords_jni.cc

vecs: all
	$(JAVA) -Djava.library.path=$(BUILD) -cp $(CLASSES) io.github.artoria2e5.prcoords.Vecs

check: all native
	$(JAVA) -Djava.library.path=$(BUILD) -cp $(CLASSES) io.github.artoria2e5.prcoords.Vecs ../TestVecs/inputs.tsv > $(BUILD)/java.tsv
	$(JAVA) -Djava.library.path=$(BUILD) -cp $(CLASSES) io.github.artoria2e5.prcoords.Vecs --native ../TestVecs/inputs.tsv > $(BUILD)/native.tsv
	$(PYTHON) ../py/checkvecs.py - --profile exact < $(BUILD)/java.tsv
	$(PYTHON) ../py/checkvecs.py - --profile badmath < $(BUILD)/native.tsv

clean:
	rm -rf $(BUILD)

.PHONY: all classes native vecs check clean
