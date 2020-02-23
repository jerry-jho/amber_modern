SCRIPTS=$(A25_ROOT)/scripts

APP=smoke

WORK=work

BOOT_ADDR=1000 

MEM_SEL=MEM_IN

MEM_BASE=0x0

CHECK_A0=

MAIN_SRC=$(A25_ROOT)/src/src_files.yml

mkwork:
	mkdir -p $(WORK)    

gen_flist_verdi:mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k verdi,a25_core,a25_top,rtl,tb > flist_verdi

gen_flist_verdi_fpga: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k verdi,a25_core,rtl,fpga,tb_cmod_a7 > flist_verdi 
	
gen_flist_verdi_fpgasyn: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k verdi,fpga_syn,tb_cmod_a7 > flist_verdi   
    
exec_verdi: mkwork
	cd $(WORK) && $(SCRIPTS)/verdi.sh -f flist_verdi -ssf top.fsdb
	
verdi: gen_flist_verdi exec_verdi 

verdi_fpga: sw gen_flist_verdi_fpga exec_verdi 

verdi_fpgasyn: gen_flist_verdi_fpgasyn exec_verdi 
    
gen_flist_vcs: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k vcs,a25_core,rtl,tb > flist_vcs

gen_flist_vcs_fpga: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k vcs,a25_core,rtl,fpga,tb_cmod_a7 > flist_vcs
	
gen_flist_vcs_fpgasyn: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k vcs,fpga_syn,tb_cmod_a7 > flist_vcs   
    
exec_vcs_nowave: mkwork
	cd $(WORK) && $(SCRIPTS)/vcs.sh -f flist_vcs

exec_vcs: mkwork
	cd $(WORK) && rm -rf top.fsdb
	cd $(WORK) && $(SCRIPTS)/vcs.sh -f flist_vcs -fsdb +define+_FSDB | tee build.log

vcs: gen_flist_vcs exec_vcs

vcs_fpga: sw gen_flist_vcs_fpga exec_vcs  

vcs_fpgasyn: gen_flist_vcs_fpgasyn exec_vcs    
    
gen_flist_vivado: mkwork
	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -e -f $(MAIN_SRC) -k a25_core,rtl,fpga -s vivado > flist_vivado.tcl    

exec_vivado: mkwork gen_flist_vivado
	#export XILINX_PART="xc7k325tffg900-2" | "xc7z020clg400-2"
	cp $(A25_ROOT)/fpga/scripts/* $(WORK)/
	cd $(WORK) && vivado -mode batch -source fpga_run.tcl
    
#gen_flist_onefile: mkwork
#	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -c concat -f $(MAIN_SRC) -k ariane_concat_defines,ariane > ariane.sv
    
#gen_flist_verdi_concat: gen_flist_onefile
#	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k verdi,ariane_concat,tb > flist_verdi

#gen_flist_vcs_concat: gen_flist_onefile     
#	cd $(WORK) && python3 $(SCRIPTS)/process_flist_yml.py -f $(MAIN_SRC) -k vcs,ariane_concat,tb > flist_vcs

#vcs_concat:  gen_flist_vcs_concat exec_vcs   

#verdi_concat: gen_flist_verdi_concat exec_verdi 
    
sim: mkwork sw
	cd $(WORK) && ./simv +MEM_IN=$(A25_ROOT)/tests/$(APP)/app.m64
    
raw_sim:
	cd $(WORK) && ./simv
    
elf: mkwork
	make -f $(A25_ROOT)/sw/bin/Makefile elf2m64 \
        ELF=$(ELF) OUT=$(WORK)/app.m64 TEMPMEM=$(WORK)/app.mem BASE=$(MEM_BASE)
    
sim_elf: mkwork elf
	cd $(WORK) && ./simv +$(MEM_SEL)=app.m64 +BOOT_ADDR=$(BOOT_ADDR) $(CHECK_A0) 
    
sim_riscv-tests:
	make sim_elf MEM_SEL=MEM_XN BOOT_ADDR=80000000 MEM_BASE=0x80000000 ELF=$(ELF) CHECK_A0='+CHECK_A0=0'
    
   
    
sw:
	cd $(A25_ROOT)/tests/$(APP) && make -f $(A25_ROOT)/sw/bin/Makefile
	cp $(A25_ROOT)/tests/$(APP)/app.v $(WORK)/sram_sp_128x2048.v
