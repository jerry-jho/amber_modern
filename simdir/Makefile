
############### Configurations ###############

WORK=work
APP=smoke
FSDB_EN=1

############### ENV ###############

BOOT_ADDR=1000 
MEM_SEL=MEM_IN
MEM_BASE=0x0
CHECK_A0=

############### Common Tasks ###############
SCRIPTS=$(A25_ROOT)/scripts
MAIN_SRC=$(A25_ROOT)/src/src_files.yml
GEN_FLIST=python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k

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
	cd $(A25_ROOT)/tests/$(APP) && make -f $(A25_ROOT)/sw/bin/Makefile
	cp $(A25_ROOT)/tests/$(APP)/app.v $(WORK)/sram_sp_128x2048.v
    
############### CA7_FPGA_BEH = Cmod A7 Behavior The firmware is float ###############    
    
CA7_FPGA_BEH=a25_core,sram_generic,fpga_generic,rtl_cmod_a7,rom_generic,tb_cmod_a7
    
gen_flist_verdi_ca7_beh:mkwork
	cd $(WORK) && $(GEN_FLIST) verdi,$(CA7_FPGA_BEH) > flist_verdi

verdi_ca7_beh: gen_flist_verdi_ca7_beh exec_verdi

gen_flist_vcs_ca7_beh: mkwork
	cd $(WORK) && $(GEN_FLIST) vcs,$(CA7_FPGA_BEH) > flist_vcs

vcs_ca7_beh: gen_flist_vcs_ca7_beh exec_vcs


############### CA7_FPGA_RTL = Cmod A7 FPGA RTL, The firmware is embedded ############### 

CA7_FPGA_RTL=a25_core,sram_generic,fpga_generic,rtl_cmod_a7,rom_cmod_a7
CA7_FPGA_RTL_TB=$(CA7_FPGA_RTL),tb_cmod_a7

gen_flist_verdi_ca7_rtl:mkwork
	cd $(WORK) && $(GEN_FLIST) verdi,$(CA7_FPGA_RTL_TB) > flist_verdi

verdi_ca7_rtl: sw gen_flist_verdi_ca7_rtl exec_verdi

gen_flist_vcs_ca7_rtl: mkwork
	cd $(WORK) && $(GEN_FLIST) vcs,$(CA7_FPGA_RTL_TB) > flist_vcs

vcs_ca7_rtl: sw gen_flist_vcs_ca7_rtl exec_vcs

############### Execute Vivado ###############

gen_flist_vivado_ca7: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -e -f $(MAIN_SRC) -k $(CA7_FPGA_RTL) -s vivado > flist_vivado.tcl    

vivado_ca7: mkwork gen_flist_vivado_ca7 sw
	cp $(A25_ROOT)/fpga/scripts/* $(WORK)/
	cd $(WORK) && $(SCRIPTS)/vivado.sh -mode batch -source fpga_run.tcl
    
############### CA7_FPGA_SYN = Cmod A7 FPGA Post Synthesis, The firmware is embedded ###############     
    
CA7_FPGA_SYN=syn_cmod_a7
CA7_FPGA_SYN_TB=$(CA7_FPGA_SYN),tb_cmod_a7

gen_flist_verdi_ca7_syn:mkwork
	cd $(WORK) && $(GEN_FLIST) verdi,$(CA7_FPGA_SYN_TB) > flist_verdi

verdi_ca7_syn: gen_flist_verdi_ca7_syn exec_verdi

gen_flist_vcs_ca7_syn: mkwork
	cd $(WORK) && $(GEN_FLIST) vcs,$(CA7_FPGA_SYN_TB) > flist_vcs

vcs_ca7_syn: gen_flist_vcs_ca7_syn exec_vcs

sim_ca7_syn: vcs_ca7_syn sim

###############

clean:
	rm -rf $(WORK)
    
   
    

