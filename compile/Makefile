
# -------------------------------------
# Testbench Makefile for Verilog Simulation using verilator
# -------------------------------------
NPROC = $$((`nproc`-1))

# Simulator configuration
VERILATOR := verilator
ifdef VERILATOR_ROOT
VERILATOR := $(VERILATOR_ROOT)/bin/verilator
endif



# Simulation configuration
SIM_NAME ?= sim
TOP_MODULE = ahb_top_tb

# Compilation arguments
COMPILE_ARGS += --prefix $(SIM_NAME)
COMPILE_ARGS += -o $(SIM_NAME)
COMPILE_ARGS += --trace

# Extra simulation arguments
EXTRA_ARGS += --timing \
              --error-limit 100 \
              --cc \
              --exe \
              --main \
							--sv 


# Warning suppression
WARNING_ARGS += -Wno-WIDTHTRUNC
WARNING_ARGS += -Wno-CASEINCOMPLETE
WARNING_ARGS += -Wno-INITIALDLY
WARNING_ARGS += -Wno-IGNOREDRETURN
WARNING_ARGS += -Wno-PINMISSING
# WARNING_ARGS += -Wno-BLKANDNBLK
# WARNING_ARGS += -Wno-LATCH

compile :
	@echo "Running verilator"
	$(VERILATOR) \
	-f filelist.f \
	$(EXTRA_ARGS) \
	$(COMPILE_ARGS) \
	$(WARNING_ARGS) \
	$(TESTBENCH_FILES)

	@make -C obj_dir -f $(SIM_NAME).mk

run :
	@echo "Running simulation"
	@./obj_dir/$(SIM_NAME) +TESTNAME=${TESTNAME}

clean:

	@echo "Cleaning up"
	rm -rf $(SIM_DIR)
	rm -rf obj_dir
	rm -rf *.log
	rm -rf *.vcd
	rm -rf *.txt

wave: 
	gtkwave *.vcd
