APPNAME=bm3d
OBJS=bm3d.o denoise.o
LIBS=X11 png z cufft cudart GL
ifdef USE_JPEG
LIBS += jpeg
endif
ifdef USE_GLUT
LIBS += glut
endif
LDLIBS=$(addprefix -l,$(LIBS))
CXX=g++ -w -m64 -std=c++11
CXXFLAGS = -O3 -Wall -Wno-unknown-pragmas
CVFLAGS := $(shell pkg-config --cflags --libs opencv 2>/dev/null || \
                     pkg-config --cflags --libs opencv4)

CUDA_HOME ?= /usr/local/cuda
ARCH ?= compute_80
LDFLAGS = -L$(CUDA_HOME)/lib64 -lcudart
INCLUDE = $(CUDA_HOME)/include
NVCCFLAGS = -O3 -m64 --gpu-architecture $(ARCH)
NVCC=nvcc

default: $(APPNAME)

psnr: cal_psnr.cpp
	$(CXX) $(CXXFLAGS) $(LDLIBS) -I /opt/X11/include -L /opt/X11/lib cal_psnr.cpp -o $@
demo: bm3d.o demo.o
	$(NVCC) $(NVCCFLAGS) $(LDFLAGS) $(LDLIBS) $(CVFLAGS) bm3d.o demo.o -o $@

$(APPNAME): $(OBJS)
	$(NVCC) $(NVCCFLAGS) $(LDFLAGS) $(LDLIBS) $(OBJS) -I /opt/X11/include -L /opt/X11/lib -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(CVFLAGS) $(addprefix -I,$(INCLUDE)) -c $< -o $@

%.o: %.cu
	$(NVCC) $(NVCCFLAGS) $(LDFLAGS) $(addprefix -I,$(INCLUDE)) -c $< -o $@

clean:
	rm *.o
