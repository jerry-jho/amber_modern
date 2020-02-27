
############### Configurations ###############

WORK=work_$(A25_CHIP)_$(A25_BOARD)
APP=smoke
FSDB_EN=1
OPTS=
A25_CHIP ?= xilinx7
A25_BOARD ?= ca7

############### Common Tasks ###############
SCRIPTS=$(A25_ROOT)/scripts
FLIST_GEN=python3 $(SCRIPTS)/process_flist_yml.py
MAIN_SRC=$(A25_ROOT)/src/src.yml
MAIN_GEN=$(FLIST_GEN) -f $(MAIN_SRC) -k
CHIP_SRC=$(A25_ROOT)/chip/$(A25_CHIP)/src/src.yml
CHIP_GEN=$(FLIST_GEN) -f $(CHIP_SRC) -k
BOARD_SRC=$(A25_ROOT)/board/$(A25_BOARD)/src/src.yml
BOARD_GEN=$(FLIST_GEN) -f $(BOARD_SRC) -k

mkwork:
	mkdir -p $(WORK)  

exec_verdi: mkwork
	cd $(WORK) && $(SCRIPTS)/verdi.sh -f flist_verdi -ssf top.fsdb

exec_vcs: mkwork
	cd $(WORK) && rm -rf top.fsdb
	cd $(WORK) && $(SCRIPTS)/vcs.sh -f flist_vcs -fsdb +define+_FSDB | tee build.log
    
sim: mkwork sw
	cd $(WORK) && ./simv +MEM_IN=$(A25_ROOT)/tests/$(APP)/app.m64 +FSDB_EN=$(FSDB_EN)    

sw: mkwork
	cd $(A25_ROOT)/tests/$(APP) && make -f $(A25_ROOT)/sw/bin/Makefile OPTS=$(OPTS)
	cp $(A25_ROOT)/tests/$(APP)/app.v $(WORK)/sram_sp_128x2048.v
    
############### FPGA_BEH = Behavior: The firmware is float ###############    
    
KEY_BEH=a25_core,sram_generic,rom_generic
KEY_CHIP_BEH=rtl
KEY_BOARD_BEH=rtl,tb
    
gen_flist_verdi_beh:mkwork
	cd $(WORK) && $(MAIN_GEN) verdi,$(KEY_BEH) > flist_verdi
	cd $(WORK) && $(CHIP_GEN) $(KEY_CHIP_BEH) >> flist_verdi
	cd $(WORK) && $(BOARD_GEN) $(KEY_BOARD_BEH) >> flist_verdi
    
verdi_beh: gen_flist_verdi_beh exec_verdi

gen_flist_vcs_beh: mkwork
	cd $(WORK) && $(MAIN_GEN) vcs,$(KEY_BEH) > flist_vcs
	cd $(WORK) && $(CHIP_GEN) $(KEY_CHIP_BEH) >> flist_vcs
	cd $(WORK) && $(BOARD_GEN) $(KEY_BOARD_BEH) >> flist_vcs

vcs_beh: gen_flist_vcs_beh exec_vcs


############### FPGA_RTL = FPGA RTL, The firmware is embedded ############### 

KEY_RTL=a25_core,sram_generic
KEY_CHIP_RTL=rtl,rom
KEY_BOARD_RTL=rtl,tb

gen_flist_verdi_rtl:mkwork
	cd $(WORK) && $(MAIN_GEN) verdi,$(KEY_RTL) > flist_verdi
	cd $(WORK) && $(CHIP_GEN) $(KEY_CHIP_RTL) >> flist_verdi
	cd $(WORK) && $(BOARD_GEN) $(KEY_BOARD_RTL) >> flist_verdi

verdi_rtl: sw gen_flist_verdi_rtl exec_verdi

gen_flist_vcs_rtl: mkwork
	cd $(WORK) && $(MAIN_GEN) vcs,$(KEY_RTL) > flist_vcs
	cd $(WORK) && $(CHIP_GEN) $(KEY_CHIP_RTL) >> flist_vcs
	cd $(WORK) && $(BOARD_GEN) $(KEY_BOARD_RTL) >> flist_vcs

vcs_rtl: sw gen_flist_vcs_rtl exec_vcs

############### Execute Vivado ###############

gen_flist_vivado: mkwork
	cd $(WORK) && $(FLIST_GEN) -f $(MAIN_SRC) -e -k $(KEY_RTL) -s vivado > flist_vivado.tcl    
	cd $(WORK) && $(FLIST_GEN) -f $(CHIP_SRC) -e -k $(KEY_CHIP_RTL) -s vivado >> flist_vivado.tcl 
	cd $(WORK) && $(FLIST_GEN) -f $(BOARD_SRC) -e -k rtl -s vivado >> flist_vivado.tcl 
    
vivado: mkwork gen_flist_vivado sw
	cp $(A25_ROOT)/chip/$(A25_CHIP)/scripts/* $(WORK)/
	cp $(A25_ROOT)/board/$(A25_BOARD)/scripts/* $(WORK)/
	cd $(WORK) && $(SCRIPTS)/vivado.sh -mode batch -source run.tcl
    
############### CA7_FPGA_SYN = Cmod A7 FPGA Post Synthesis, The firmware is embedded ###############     
    
KEY_SYN=syn,tb

gen_flist_verdi_syn:mkwork
	cd $(WORK) && $(MAIN_GEN) verdi > flist_verdi
	cd $(WORK) && $(BOARD_GEN) $(KEY_SYN) >> flist_verdi

verdi_syn: gen_flist_verdi_syn exec_verdi

gen_flist_vcs_syn: mkwork
	cd $(WORK) && $(MAIN_GEN) vcs > flist_vcs
	cd $(WORK) && $(BOARD_GEN) $(KEY_SYN) >> flist_vcs

vcs_syn: gen_flist_vcs_syn exec_vcs


###############

clean:
	rm -rf $(WORK)
    
   
    

