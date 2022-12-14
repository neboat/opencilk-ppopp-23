include ../config.mk

SRCS = $(wildcard *.c)
HDRS = $(wildcard *.h)
OBJS = $(patsubst %.c,%.o,$(SRCS))

MANY = 8 # how many cores is a lot?
ENABLE_X11 = false

CTESTS   = intlist serialsum intsum multispawnsum repeatedintsum # cilksan_test
CXXTESTS = 
DIRTESTS = nqueens quad_tree
TESTS    = $(CTESTS) $(CXXTESTS) $(DIRTESTS)
WARN     = -W -Wno-mismatched-tags -Wno-unused-parameter -Werror
OPTIONS  = $(OPT) $(SAN) $(ARCH) $(DBG) $(RTS_OPT) $(WARN) # -fno-omit-frame-pointer

# $(CTESTS): RTS_PERSONALITY_LIB = $(RTS_LIBDIR)/$(RTS_C_PERSONALITY_LIB).a
# $(CXXTESTS): RTS_PERSONALITY_LIB = $(RTS_LIBDIR)/$(RTS_CXX_PERSONALITY_LIB).a

# RTS_LIBS = $(RTS_PERSONALITY_LIB) $(RTS_DIR)/$(RTS_LIB).a $(patsubst %,../runtime/%/module.a,$(MODS))
RTS_LIBS = -fopencilk # --opencilk-resource-dir=$(RESOURCE_DIR) $(patsubst %,../runtime/%/module.a,$(MODS))

TIMING_COUNT := 1

.PHONY: all check clean $(DIRTESTS)

all: $(TESTS)

$(CTESTS): %: %.o ktiming.o getoptions.o
	$(CC) $^ -o $@ $(RTS_LIBS) $(RTS_LIB_FLAG) $(SAN) -lm

$(CXXTESTS): %: %.o ktiming.o getoptions.o
	$(CXX) $^ -o $@ $(RTS_LIBS) $(RTS_LIB_FLAG) $(SAN) -lm

$(DIRTESTS):
	$(MAKE) -C $@ $(TOPASS)

%.o: %.c
	$(CC) -c $(OPTIONS) -DTIMING_COUNT=$(TIMING_COUNT) -o $@ $<

%.o: %.cpp
	$(CXX) -c $(OPTIONS) -DTIMING_COUNT=$(TIMING_COUNT) -o $@ $<

check:
	$(MAKE) TIMING_COUNT=5 $(TOPASS)
	CILK_NWORKERS=2 ./intlist 40000000
	CILK_NWORKERS=1 ./serialsum 200000000
	CILK_NWORKERS=1 ./intsum 200000000
	CILK_NWORKERS=$(MANY) ./intsum 200000000
	CILK_NWORKERS=2 ./multispawnsum 100000000
	$(MAKE) -C nqueens check $(TOPASS)
	if $(ENABLE_X11); then $(MAKE) -C quad_tree check $(TOPASS) ; else : ; fi

stress:
	$(MAKE) TIMING_COUNT=5 $(TOPASS)
	CILK_NWORKERS=$(MANY) ./intlist 40000000
	CILK_NWORKERS=$(MANY) ./intsum 200000000
	if $(ENABLE_X11); then $(MAKE) -C quad_tree check $(TOPASS) ; else : ; fi
#	 Assertion failure: SPA resize not supported yet!
#	CILK_NWORKERS=$(MANY) ./repeatedintsum 10000000

#redcheck:
#	$(MAKE) clean; $(MAKE) TIMING_COUNT=1 $(TOPASS) > /dev/null 2>&1
#	CILK_NWORKERS=2 ./intlist 2048
#redgdb:
#	$(MAKE) clean; $(MAKE) TIMING_COUNT=1 $(TOPASS) > /dev/null 2>&1
#	CILK_NWORKERS=2 gdb --args ./intlist 2048

clean:
	rm -f *.o *~ $(CTESTS) $(CXXTESTS) core.*
	$(foreach test,$(DIRTESTS),$(MAKE) -C $(test) clean;)

intlist.o: ktiming.h
intsum.o: ktiming.h
ktiming.o: ktiming.h
multispawnsum.o: ktiming.h
repeatedintsum.o: ktiming.h
serialsum.o: ktiming.h
