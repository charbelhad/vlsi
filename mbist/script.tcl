define_design_lib WORK -path ./work 

set PDK_DIR /ip/synopsys/saed32/v02_2024/lib
set_app_var search_path "$PDK_DIR/stdcell_lvt/db_nldm ./"

set_app_var target_library "saed32lvt_ss0p75v125c.db"
set_app_var link_library "* $target_library"
analyze -f sverilog {decoder.sv multiplexer.sv sram.sv controller.sv comparator.sv counter.sv bist.sv}

elaborate bist
list_libs
list_designs
source bist_constraint.sdc
compile_ultra

report_timing > timing.rpt
