#################################################################################
# VC-LP Verification Script for
# Design Compiler Reference Methodology Script for Top-Down Flow
# Script: vc_lp.tcl
# Version: U-2022.12
# Copyright (C) 2011-2023 Synopsys, Inc. All rights reserved.
#################################################################################

# Enable the default behavior of sh_continue_on_error to be same as DC 
# Change variable settings to improve QoR of VC LP and to better match
# results of check_mv_design 
set_app_var sh_continue_on_error true
set_app_var handle_hanging_crossover true
set_app_var enable_local_policy_match true
set_app_var upf_iso_filter_elements_with_applies_to ENABLE
set_app_var enable_multi_driver_analysis true
set_app_var enable_verdi_debug true

source ./rm_utilities/procs_global.tcl 
rm_source -file ./rm_setup/dc_setup.tcl

if {$UPF_MODE == "none"} {
    puts "RM-info: UPF mode disabled in dc_setup.tcl (UPF_MODE is \"none\")"
    puts "RM-info: End script [info script]\n"
    exit
}

set_app_var search_path ". ${ADDITIONAL_SEARCH_PATH} $search_path"

#################################################################################
# Read in the Design and UPF
#
# Read in the RTL/NETLIST and UPF files.
#################################################################################

if {$VCLP_RUN=="RTL"} {
  # Load the RTL design 
  switch $RTL_SOURCE_FORMAT {
    autoread {
      # Design Compiler does not write out RTL read script for VC-LP
      # RTL read script(VCLPRM_RTL_READ_SCRIPT) defined above needs to be used for autoread RTL_FORMAT option
      rm_source -file ${VCLPRM_RTL_READ_SCRIPT} -print VCLPRM_RTL_READ_SCRIPT
    }
    script {
      # VCLPRM_RTL_READ_SCRIPT should be the path to shell script
      rm_source -file ${VCLPRM_RTL_READ_SCRIPT} -print VCLPRM_RTL_READ_SCRIPT
    }
    vhdl {
      analyze -format vhdl -work work ${RTL_SOURCE_FILES} 
      elaborate ${DESIGN_NAME}
    }
    sverilog {
      analyze -format sverilog -work work ${RTL_SOURCE_FILES}
      elaborate ${DESIGN_NAME}
    }
    verilog {
      analyze -format verilog -work work ${RTL_SOURCE_FILES}
      elaborate ${DESIGN_NAME}
    }
  }

  # Load the UPF files
  if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
    set HIER_DESIGNS [concat ${DDC_HIER_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS} ${ICC2_BLOCK_ABSTRACTION_DESIGNS}]
    if {[catch {open [file join ${OUTPUTS_DIR} vclp_${DESIGN_NAME}.full_chip.RTL.upf] w} VCLP_INPUT_UPF_FILE]} {
       puts stderr "Error : Unable to create UPF file for VCLP runs"
    } else {
       puts ${VCLP_INPUT_UPF_FILE} "load_upf $DCRM_MV_UPF_INPUT_FILE"
       foreach design ${HIER_DESIGNS}  {
         set inst_name [get_object_name [all_instances ${design}]]
         puts ${VCLP_INPUT_UPF_FILE} "load_upf ${design}.upf -scope ${inst_name}"
       }
    }
    close ${VCLP_INPUT_UPF_FILE}
    read_upf vclp_${DESIGN_NAME}.full_chip.RTL.upf
  } else {
    read_upf ${UPF_FILE}
  }

# Use Netlist as the default mode to run VCLP checks
} else {
  # Load the design netlist
  if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
    set all_netlists ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.v
    foreach design ${HIER_DESIGNS} {
      lappend all_netlists ${design}.mapped.v
    }
    read_file -netlist -format verilog -top ${DESIGN_NAME} ${all_netlists}
  } else {
    read_file -netlist -format verilog -top ${DESIGN_NAME} ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.v
  }

  # Load the UPF files
  if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
    if {[catch {open [file join ${OUTPUTS_DIR} vclp_${DESIGN_NAME}.full_chip.upf] w} VCLP_UPF_FILE]} {
      puts stderr "Error : Unable to create UPF file for VC-LP runs"
    } else {
      puts ${VCLP_UPF_FILE} "load_upf ${DESIGN_NAME}.mapped.upf"
      foreach design ${HIER_DESIGNS}  {
        set inst_name [get_object_name [all_instances ${design}]]
        puts ${VCLP_UPF_FILE} "load_upf ${design}.mapped.upf -scope ${inst_name}"
      }
    }
    close ${VCLP_UPF_FILE}
    read_upf vclp_${DESIGN_NAME}.full_chip.upf
  } else {
    read_upf ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.upf 
  }
}

#################################################################################
# Check the Design
#################################################################################

# Validated the UPF completeness and consistence
check_lp -stage upf 

# Check design consistency with UPF
if {$VCLP_RUN =="NETLIST"} {
  check_lp -stage design
}

#################################################################################
# Generate Final Reports
#################################################################################

report_lp -file          ${REPORTS_DIR}/${DESIGN_NAME}.vclp_report_violations.${VCLP_RUN}.rpt
report_lp -verbose -file ${REPORTS_DIR}/${DESIGN_NAME}.vclp_report_violations.${VCLP_RUN}.verbose.rpt

puts "RM-info: End script [info script]\n"
exit

