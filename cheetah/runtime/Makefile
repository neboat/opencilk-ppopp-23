include ../config.mk

# With reducers
REDUCER_DEF = -DREDUCER_MODULE
#ABI_DEF imported from ../config.mk
#ALERT_DEF = -DALERT_LVL=0x000

RESOURCE_DIR=$(realpath ..)
MAIN = $(RTS_LIBDIR)/$(RTS_LIB)
BITCODE_ABI = $(MAIN)-abi.bc
SRCS = $(filter-out pedigree_ext.c, $(filter-out $(PEDIGREE_LIB_SRC).c, $(filter-out $(PERSON_C_SRC).c, $(filter-out $(PERSON_CPP_SRC).c, $(wildcard *.c)))))
HDRS = $(wildcard *.h)
OBJS = $(patsubst %.c,./build/%.o,$(SRCS))
INCLUDES = -I../include/
DEFINES = $(REDUCER_DEF) $(ABI_DEF) $(ALERT_DEF)
OPTIONS = $(OPT) $(DBG) $(ARCH) -Werror -Wall -fpic $(DEFINES) $(INCLUDES) -gdwarf-4

PERSON_C = $(RTS_LIBDIR)/$(RTS_C_PERSONALITY_LIB)
PERSON_CPP = $(RTS_LIBDIR)/$(RTS_CXX_PERSONALITY_LIB)
PERSON_C_SRC = personality-c
PERSON_CPP_SRC = personality-cpp
PEDIGREE_LIB = $(RTS_LIBDIR)/$(RTS_PEDIGREE_LIB)
PEDIGREE_LIB_SRC = pedigree_lib

.PHONY: all clean build

all: build $(RTS_LIBDIR) $(MAIN).a $(MAIN).so $(PERSON_C).a $(PERSON_C).so $(PERSON_CPP).a $(PERSON_CPP).so $(BITCODE_ABI)

$(MAIN).a: $(OBJS)
	ar rcs $@ $^

$(MAIN).so: $(OBJS)
	$(CC) -shared -o $@ $^ -lpthread

$(PERSON_C).a: build/$(PERSON_C_SRC).o
	ar rcs $@ $^

$(PERSON_C).so: build/$(PERSON_C_SRC).o
	$(CC) -shared -o $@ $^

$(PERSON_CPP).a: build/$(PERSON_CPP_SRC).o
	ar rcs $@ $^

$(PERSON_CPP).so: ./build/$(PERSON_CPP_SRC).o
	$(CC) -shared -o $@ $^

$(PEDIGREE_LIB).a: build/$(PEDIGREE_LIB_SRC).o
	ar rcs $@ $^

$(PEDIGREE_LIB).so: ./build/$(PEDIGREE_LIB_SRC).o
	$(CC) -shared -o $@ $^

build:
	mkdir -p $@

$(RTS_LIBDIR):
	mkdir -p $@

build/%.o: %.c $(HDRS)
	$(CC) -c $(OPTIONS) -o $@ $<

build/cilk2c_inlined.bc: cilk2c_inlined.c $(HDRS)
	$(CC) -O3 -DCHEETAH_API="" -DCHEETAH_INTERNAL_NORETURN='__attribute__((noreturn))' -DCHEETAH_INTERNAL="" -DCILK_DEBUG=0 -c -emit-llvm $(INCLUDES) -gdwarf-4 -g -o $@ $<

$(BITCODE_ABI) : build/cilk2c_inlined.bc
	cp $< $@

clean:
	rm -f $(OBJS) build/$(PERSON_C_SRC).o build/$(PERSON_CPP_SRC).o $(RTS_LIBDIR)/*.a $(RTS_LIBDIR)/*.so $(RTS_LIBDIR)/*.bc *~
	rm -f build/cilk2c_inlined.bc
