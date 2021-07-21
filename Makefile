EE_OBJS	= VURandom.o randomgen.o
EE_BIN = VURandom.elf
EE_LIBS = -lkernel -ldebug
EE_DVP = dvp-as
EE_VCL = vcl

all: $(EE_BIN)

%.vsm: %.vcl
	$(EE_VCL) $< >> $@

%.o: %.vsm
	$(EE_DVP) $< -o $@

clean:
	rm -f $(EE_BIN) $(EE_OBJS) 

run: $(EE_BIN)
	ps2client execee host:$(EE_BIN)

reset:
	ps2client reset
	ps2client netdump

include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
