#################################################################################
# Design Compiler Reference Methodology Script for Top-Down MCMM Flow
# Script: dc.tcl
# Version: U-2022.12
# Copyright (C) 2007-2023 Synopsys, Inc. All rights reserved.
#################################################################################

source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_dc.tcl 
rm_source -file ./rm_setup/dc_setup.tcl
rm_source -file ./rm_dc_scripts/header_dc.tcl

#################################################################################
# Additional Variables
#
# Add any additional variables needed for your flow here.
#################################################################################

################################################################################
# You can enable inference of multibit registers from the buses defined in the RTL.
# The replacement of single-bit cells with multibit library cells occurs during execution 
# of the compile_ultra command. This variable has to be set before reading the RTL
#
# set_app_var hdlin_infer_multibit default_all
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
  set_app_var hdlin_infer_multibit default_all
}

# Enable the insertion of level-shifters on clock nets for a multivoltage flow
set_app_var auto_insert_level_shifters_on_clocks all

# Enable the support of via resistance for RC estimation to improve the timing 
# correlation with IC Compiler
set_app_var spg_enable_via_resistance_support true

rm_source -file $LIBRARY_DONT_USE_PRE_COMPILE_LIST -optional -print LIBRARY_DONT_USE_PRE_COMPILE_LIST

#################################################################################
# Setup for Formality Verification
#################################################################################

# In the event of an inconclusive (or hard) verification, we recommend using
# the set_verification_priority commands provided from the analyze_points command
# in Formality. The set_verification_priority commands target specific
# operators to reduce verification complexity while minimizing QoR impact.
# The set_verification_priority commands should be applied after the design
# is read and elaborated.

# For designs that don't have tight QoR constraints and don't have register retiming,
# you can use the following variable to enable the highest productivity single pass flow.
# This flow modifies the optimizations to make verification easier.
# This variable setting should be applied prior to reading in the RTL for the design.

# set_app_var simplified_verification_mode true

# For more information about facilitating formal verification in the flow, refer
# to the following SolvNet article:
# "Resolving Inconclusive and Hard Verifications in Design Compiler"
# https://solvnet.synopsys.com/retrieve/033140.html

# Define the verification setup file for Formality
set_svf ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.svf

#################################################################################
# Setup SAIF Name Mapping Database
#
# Include an RTL SAIF for better power optimization and analysis.
#
# saif_map should be issued prior to RTL elaboration to create a name mapping
# database for better annotation.
################################################################################

if {$SAIF_FILE != "" || $GENERATE_SAIFMAP_WITHOUT_SAIF} {
  saif_map -start
}

#################################################################################
# Read in the RTL Design
#
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  # The set_top_implementation_options command defines which blocks should be
  # read as block abstractions.
  # Note: You can use the -block_update_setup_script option to pass any variable 
  #       setting for the block update process. 
  if { (${DC_BLOCK_ABSTRACTION_DESIGNS} != "") || (${ICC2_BLOCK_ABSTRACTION_DESIGNS} != "")} {
    set HIER_DESIGNS [concat ${DC_BLOCK_ABSTRACTION_DESIGNS} ${ICC2_BLOCK_ABSTRACTION_DESIGNS}]

    set set_top_implementation_options_cmd "set_top_implementation_options -block_references \"$HIER_DESIGNS\""
    puts "RM-info: Running $set_top_implementation_options_cmd"
    eval ${set_top_implementation_options_cmd}
  }
}

rm_source -file $DCRM_PRE_ELABORATE_SCRIPT -optional -print DCRM_PRE_ELABORATE_SCRIPT

rm_source -file $DCRM_RTL_READ_SCRIPT -print DCRM_RTL_READ_SCRIPT

rm_source -file $DCRM_POST_ELABORATE_SCRIPT -optional -print DCRM_POST_ELABORATE_SCRIPT

## DFT Ports
rm_source -file $DFT_PORTS_FILE -optional -print "DFT_PORTS_FILE"

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  # Remove the RTL version of the hierarchical blocks in case they were read in
  set HIER_DESIGNS "${DDC_HIER_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS} ${ICC2_BLOCK_ABSTRACTION_DESIGNS}"
  
  foreach design $HIER_DESIGNS {
    if {[filter [get_designs -quiet *] "@hdl_template == $design"] != "" } {
      remove_design -hierarchy [filter [get_designs -quiet *] "@hdl_template == $design"]
    }
  }
}
  
# Store the elaborated design without the hierarchical physical blocks
write_file -hierarchy -format ddc -output ${OUTPUTS_DIR}/${DESIGN_NAME}.elab.ddc
  
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  #################################################################################
  # Load Hierarchical Designs
  #################################################################################
  
  # Read in compiled hierarchical blocks
  # For topographical mode top-level synthesis all physical blocks are required to
  # be compiled in topographical mode.
  
  foreach design ${DDC_HIER_DESIGNS} {
    set ddc_file ${design}.mapped.ddc
    puts "RM-info: Reading design $design as hierarchical DDC [which $ddc_file]"
    read_ddc $ddc_file
  }
  
  foreach design ${DC_BLOCK_ABSTRACTION_DESIGNS} {
    set ddc_file ${design}.mapped.ddc
    puts "RM-info: Reading design $design as block abstract [which $ddc_file]"
    read_ddc $ddc_file
  }

  foreach {design block} ${ICC2_BLOCK_ABSTRACTION_NDM} {
    puts "RM-info: Importing design $design from ICC2 block $block"
    import_ndm_block -blocks ${block} -output_dir hier_ndm
  }
}

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  if { ${BLOCK_DESIGN_HAS_SV_INTERFACE_PORTS} } {
    # Enable the linker to allow a period (.) as an alternative to an underscore (_)
    # when doing port name matching for the hierarchical flow, if the block level design
    # have SystemVerilog interfaces ports.
    set_app_var link_portname_allow_period_to_match_underscore true
  }
}

current_design ${DESIGN_NAME}
link

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  if { ${DC_BLOCK_ABSTRACTION_DESIGNS} != "" || ${ICC2_BLOCK_ABSTRACTION_DESIGNS} != "" } {
    create_link_block_abstraction -output_ndm_dir hier_ndm
  }
}

#################################################################################
# sets the multibit_mode attribute
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp"} {
  # Enable mapping to multibit only if the timing is not degraded. Adjust the critical Range as required by the design.
  set_multibit_options -mode timing_only -critical_range 0.1
}

#################################################################################
# Reports pre-synthesis congestion analysis.
#################################################################################
if { $ANALYZE_RTL_CONGESTION } {
  #Analyze the RTL constructs which may lead to congestion
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.analyze_rtl_congestion.rpt {analyze_rtl_congestion}
}

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  # Check to make sure that all the correct designs were linked
  # Pay special attention to the source location of your physical blocks
  list_designs -show_file
  
  # Report the block abstraction settings and usage
  if { (${DC_BLOCK_ABSTRACTION_DESIGNS} != "") || (${ICC2_BLOCK_ABSTRACTION_DESIGNS} != "") } {
    report_top_implementation_options
    report_block_abstraction
  }
  
  # Read in CTL test models for IC Compiler II block abstractions to ensure DFT info is present
  foreach ctl_file $CTL_FOR_ICC2_ABSTRACT_BLOCKS {
    read_test_model -format ctl -design ${design} $ctl_file
  }
  
  # Don't optimize ${DDC_HIER_DESIGNS}
  if { ${DDC_HIER_DESIGNS} != ""} {
    if {[shell_is_in_topographical_mode]} {
      # Hierarchical .ddc blocks must be marked as physical hierarchy
      # In case of multiply instantiated designs, only set_physical_hierarchy on ONE instance
      set_physical_hierarchy [sub_instances_of -hierarchy -master_instance -of_references ${DDC_HIER_DESIGNS} ${DESIGN_NAME}]
      puts "RM-info: Marked as physical hierarchy: [get_physical_hierarchy]"
    } else {
      # Don't touch these blocks in DC-WLM
      set_dont_touch [get_designs ${DDC_HIER_DESIGNS}]
    }
    create_link_block_abstraction
  }
  
  set HIER_DESIGNS "${DDC_HIER_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS} ${ICC2_BLOCK_ABSTRACTION_DESIGNS}"
  # Prevent optimization of top-level logic based on physical block contents
  # (required for hierarchical formal verification flow)
  set_boundary_optimization ${HIER_DESIGNS} false
  set_app_var compile_preserve_subdesign_interfaces true
  set_app_var compile_enable_constant_propagation_with_no_boundary_opt false
  
  #################################################################################
  # Propagate UPF Data from Hierarchical Blocks to Top
  #################################################################################
  
  # For the top-level design in a UPF hierarchical flow, remove the block-level
  # scenarios in memory before propagating the power supply data.
  
  remove_scenario -all
  
  propagate_constraints -power_supply_data
}

#################################################################################
# Load UPF MV Setup
#
# golden.upf, a UPF template file, can be used as a reference to develop a UPF-based
# low power intent file.
#
# You can also use Visual UPF in Design Vision to generate a UPF template for
# your design. To open the Visual UPF dialog box, choose Power > Visual UPF.
# For information about Visual UPF, see the Power Compiler User Guide.
#
#################################################################################

if {$UPF_MODE != "none"} {
  if {$UPF_FILE != ""} {
    set load_upf_cmd "load_upf ${UPF_FILE}"

    if {$UPF_MODE == "golden"} {lappend load_upf_cmd -strict_check true}

    puts "RM-info: Running $load_upf_cmd"
    eval ${load_upf_cmd}
  }
}

#################################################################################
# Set Up the Multicorner Multimode (MCMM) Scenarios
#
# Note: The MCMM flow is only supported in topographical mode and it requires
#       a license for Design Compiler Graphical. 
#################################################################################

# Use the dc.mcmm.scenarios.tcl example file as as reference for
# what should be included in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}

rm_source -file $DCRM_MCMM_SCENARIOS_SETUP_FILE -print DCRM_MCMM_SCENARIOS_SETUP_FILE

# To get the best memory and runtime performance, only define scenarios
# needed for optimization in Design Compiler.
# If additional scenarios are also included, use the following command to
# select the set of desired scenarios for optimization.

# set_active_scenarios <list of scenarios for synthesis optimization>

if {[shell_is_in_topographical_mode]} {
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mcmm.scenarios.rpt {report_scenarios}
  check_scenarios -output ${REPORTS_DIR}
}

#################################################################################
# Define Operating Voltages on Power Nets
#################################################################################

# Important Note: set_related_supply net settings should now be included in the
#                 RTL UPF otherwise Formality verification will fail.

# For MCMM, do not apply the set_voltage settings here.
# This should be done for each scenario in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}

# set_voltage commands will be written out in SDC version 1.8 and might
# be defined as a part of the SDC for your design.

if {${DESIGN_STYLE} == "hier" && ${PHYSICAL_HIERARCHY_LEVEL} == "top"} {
  if {${UPF_MODE} == "none" && ${ICC2_BLOCK_ABSTRACTION_DESIGNS} != ""} {
    # ICC2 block abstract is PG netlist even without UPF
    # following variable is required to prevent error in check_mv_design
    set_app_var dc_allow_rtl_pg true
  }
}

# Check and exit if any supply nets are missing a defined voltage.
set check_mv_design_failed false
if {[shell_is_in_topographical_mode]} {
  ## For MCMM, perform this check for each scenario.
  set current_scenario_saved [current_scenario]
  foreach scenario [all_active_scenarios] {
    current_scenario ${scenario}
    if {![check_mv_design -power_nets]} {
      set check_mv_design_failed true
      break
    }
  }
  current_scenario ${current_scenario_saved}
} else {
  if {![check_mv_design -power_nets]} {
    set check_mv_design_failed true
  }
}
if {$check_mv_design_failed} {
  puts "RM-error: One or more supply nets are missing a defined voltage.  Use the set_voltage command to set the appropriate voltage upon the supply."
  puts "This script will now exit."
  exit 1
}

#################################################################################
# Create Default Path Groups
#
# Separating these paths can help improve optimization.
# Remove these path group settings if user path groups have already been defined.
#################################################################################

if {[shell_is_in_topographical_mode]} {
  set current_scenario_saved [current_scenario]
  foreach scenario [all_active_scenarios] {
    current_scenario ${scenario}
    set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
    group_path -name REGOUT -to [all_outputs] 
    group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
    group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
  }
  current_scenario ${current_scenario_saved}
} else {
  set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
  group_path -name REGOUT -to [all_outputs] 
  group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
  group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
}

#################################################################################
# Power Optimization Section
#################################################################################

# Include a SAIF file, if possible, for dynamic power scenario.  If a SAIF file
# is not provided, the default switching activity values will be used on input port for propagating 
# switching activity.

if {$SAIF_FILE != ""} {
  if {[shell_is_in_topographical_mode]} {
    set current_scenario_saved [current_scenario]
    if {$SAIF_FILE_POWER_SCENARIO != ""} {
      current_scenario $SAIF_FILE_POWER_SCENARIO
    }
  }

  set read_saif_cmd "read_saif -auto_map_names -input $SAIF_FILE"
  if {$SAIF_FILE_SOURCE_INSTANCE != ""} {lappend read_saif_cmd -instance_name $SAIF_FILE_SOURCE_INSTANCE}
  if {$SAIF_FILE_TARGET_INSTANCE != ""} {lappend read_saif_cmd -target_instance $SAIF_FILE_TARGET_INSTANCE}
  if {$SAIF_FILE_SCALING_FACTOR != ""}  {lappend read_saif_cmd -scale $SAIF_FILE_SCALING_FACTOR}
  if {$SAIF_FILE_SCALING_UNIT != "" }   {lappend read_saif_cmd -unit_base $SAIF_FILE_SCALING_UNIT}
  puts "RM-info: Running $read_saif_cmd"
  eval ${read_saif_cmd}

  if {[shell_is_in_topographical_mode]} {
    current_scenario $current_scenario_saved
  }
}

if {$SAIF_FILE == "" && $GENERATE_SAIFMAP_WITHOUT_SAIF} {
  puts "RM-info: Manually updating saif_map database for generating map without SAIF file"

  # When SAIF file is not available and a PrimePower mapping file is still needed for
  # the design the following section is needed to manually update the saif_map database.

  set power_keep_license_after_power_commands true

  # Register cells
  set reg_cells [all_registers -edge_triggered]
  set reg_cells [filter_collection $reg_cells "full_name!~*\*cell\**"] ;# Removing DW objects
  foreach map_reg [get_object_name $reg_cells] {
    set RTL_NAME [regsub {_reg(?!.*_reg)} ${map_reg} {}]
    saif_map -add_name ${RTL_NAME} ${map_reg}
  }
  # Primary ports are optional because their names do not change.
  foreach map_pp [get_object_name [get_ports]] {
    saif_map -add_name $map_pp $map_pp
  }
     
  # Macro output pins
  foreach_in_collection macro_pin [get_pins -of [all_macro_cells] -filter "direction==out"] {
    set RTL_NAME [get_object_name [get_nets -of $macro_pin]]
    saif_map -add_name $RTL_NAME [get_object_name $macro_pin]
  }
     
  # RTL ICG
  foreach_in_collection icg [get_cells -hierarchical -filter "is_icg"] {
    set gated_clock_pin [get_pins -of $icg -filter "direction==out"]
    set RTL_NAME [get_object_name [get_nets -of $gated_clock_pin]]
    saif_map -add_name $RTL_NAME [get_object_name $gated_clock_pin]
  }
     
  set power_keep_license_after_power_commands false
}

if {$SAIF_FILE == "" && $OPTIMIZATION_FLOW == "hplp"} {
  if {[shell_is_in_topographical_mode]} {
    foreach scenario [get_scenarios -dynamic_power true -setup true -active true] {
      puts "RM-info: Running infer_switching_activity in scenario ${scenario} for hplp flow because SAIF_FILE is empty"
      infer_switching_activity -sci_based all -scenario $scenario -apply
    }
  }
}
 
if {[shell_is_in_topographical_mode]} {

  ##################################################################################
  # Apply Physical Design Constraints
  #
  # Optional: Floorplan information can be read in here if available.
  # This is highly recommended for irregular floorplans.
  #
  # Floorplan constraints can be provided from one of the following sources:
  # * extract_physical_constraints with a DEF file
  #    * read_floorplan with a floorplan file (written by write_floorplan)
  #    * User generated Tcl physical constraints
  #
  ##################################################################################

  # Specify ignored layers for routing to improve correlation
  # Use the same ignored layers that will be used during place and route

  if { ${MIN_ROUTING_LAYER} != ""} {
    set_ignored_layers -min_routing_layer ${MIN_ROUTING_LAYER}
  }
  if { ${MAX_ROUTING_LAYER} != ""} {
    set_ignored_layers -max_routing_layer ${MAX_ROUTING_LAYER}
  }

  report_ignored_layers

  # If the macro names change after mapping and writing out the design due to
  # ungrouping or Verilog change_names renaming, it may be necessary to translate 
  # the names to correspond to the cell names that exist before compile.

  # During DEF constraint extraction, extract_physical_constraints automatically
  # matches DEF names back to precompile names in memory using standard matching rules.
  # read_floorplan will also automatically perform this name matching.

  # Modify set_query_rules if other characters are used for hierarchy separators
  # or bus names. 

  # set_query_rules  -hierarchical_separators {/ _ .} \
  #                  -bus_name_notations {[] __ ()}   \
  #                  -class {cell pin port net}       \
  #                  -wildcard                        \
  #                  -regsub_cumulative               \
  #                  -show

  if {$DCRM_DESIGN_PLANNING} { 
    puts "RM-info: Loading design planning physical constraints"

    # For Tcl constraints, the name matching feature must be explicitly enabled
    # and will also use the set_query_rules setttings. This should be turned off
    # after the constraint read in order to minimize runtime.

    set_app_var enable_rule_based_query true
    rm_source -optional -file $DCRM_DP_PHYSICAL_CONSTRAINTS_INPUT_FILE -print DCRM_DP_PHYSICAL_CONSTRAINTS_INPUT_FILE
    set_app_var enable_rule_based_query false 

  } else {

    puts "RM-info: Loading floorplan files"

    ## For DEF floorplan input
    if {${DCRM_DEF_INPUT_FILE} != ""} {
      # If you have physical only cells as a part of your floorplan DEF file, you can use
      # the -allow_physical_cells option with extract_physical_constraints to include
      # the physical only cells as a part of the floorplan in Design Compiler to improve correlation.
      #
      # Note: With -allow_physical_cells, new logical cells in the DEF file
      #       that have a fixed location will also be added to the design in memory.
      #       See the extract_physical_constraints manpage for more information about
      #       identifying the cells added to the design when using -allow_physical_cells.
  
      # extract_physical_constraints -allow_physical_cells ${DCRM_DEF_INPUT_FILE}
  
      puts "RM-info: Reading in DEF file [which ${DCRM_DEF_INPUT_FILE}]\n"
      if { $OPTIMIZATION_FLOW == "hplp"} {
        extract_physical_constraints -allow_physical_cells ${DCRM_DEF_INPUT_FILE}  
      } else {
        extract_physical_constraints ${DCRM_DEF_INPUT_FILE}
      }
    }
      
    # OR
  
    ## For floorplan file input
  
    if {${DCRM_FLOORPLAN_INPUT_FILE} != ""} {
      # Read in the secondary floorplan file, previously written by write_floorplan in Design Compiler,
      # to restore physical-only objects back to the design, before reading the main floorplan file.
      if {[file exists [which ${DCRM_FLOORPLAN_INPUT_FILE}.objects]]} {
        puts "RM-info: Reading in secondary floorplan file [which ${DCRM_FLOORPLAN_INPUT_FILE}.objects]\n"
        read_floorplan ${DCRM_FLOORPLAN_INPUT_FILE}.objects
      }
      puts "RM-info: Reading in floorplan file [which ${DCRM_FLOORPLAN_INPUT_FILE}]\n"
      read_floorplan ${DCRM_FLOORPLAN_INPUT_FILE}
    }
  
    # OR
  
    ## For Tcl file input
  
    # For Tcl constraints, the name matching feature must be explicitly enabled
    # and will also use the set_query_rules setttings. This should be turned off
    # after the constraint read in order to minimize runtime.
  
    set_app_var enable_rule_based_query true
    rm_source -optional -file $DCRM_PHYSICAL_CONSTRAINTS_INPUT_FILE -print DCRM_PHYSICAL_CONSTRAINTS_INPUT_FILE
    set_app_var enable_rule_based_query false 
  
  
    # Use write_floorplan to save the applied floorplan.
  
    # Note: A secondary floorplan file ${DESIGN_NAME}.initial.fp.objects
    #       might also be written to capture physical-only objects in the design.
    #       This file should be read in before reading the main floorplan file.
  
    write_floorplan -all ${OUTPUTS_DIR}/${DESIGN_NAME}.initial.fp
  }

  # Verify that all the desired physical constraints have been applied
  # Add the -pre_route option to include pre-routes in the report
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.physical_constraints.rpt {report_physical_constraints}
}

#################################################################################
# Apply Additional Optimization Constraints
#################################################################################

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

#################################################################################
# Save the compile environment snapshot for the Consistency Checker utility.
#
# This utility checks for inconsistent settings between Design Compiler and
# IC Compiler which can contribute to correlation mismatches.
#
# Download this utility from SolvNet.  See the following SolvNet article for
# complete details:
#
# https://solvnet.synopsys.com/retrieve/026366.html
#
# The article is titled: "Using the Consistency Checker to Automatically Compare
# Environment Settings Between Design Compiler and IC Compiler"
#################################################################################

# Uncomment the following to snapshot the environment for the Consistency Checker
# for each active scenario.  You will also need to run the Consistency Checker
# utility for each scenario environment snapshot.

# set current_scenario_saved [current_scenario]
# foreach scenario [all_active_scenarios] {
#   current_scenario ${scenario}
#   write_environment -consistency -output ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.compile_ultra.env ${scenario}]
# }
# current_scenario ${current_scenario_saved}

#################################################################################
# Check for Design Problems 
#################################################################################

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
  # Check the readiness of the block abstraction
  if {(${DC_BLOCK_ABSTRACTION_DESIGNS} != "") || (${ICC2_BLOCK_ABSTRACTION_DESIGNS} != "")} {
    check_block_abstraction
  }
}

# Check the current design for consistency
check_design -summary
redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.check_design.rpt {check_design}

# The analyze_datapath_extraction command can help you to analyze why certain data 
# paths are no extracted, uncomment the following line to report analyisis.

# redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.analyze_datapath_extraction.rpt {analyze_datapath_extraction}


#################################################################################
# Multibit Register Reports pre-compile_ultra
#################################################################################

#################################################################################
# Uncomment the next line to verify that the desired bussed registers are grouped as multibit components 
# These multibit components are mapped to multibit registers during compile_ultra
#
# redirect ${REPORTS_DIR}/${DESIGN_NAME}.multibit.components.rpt {report_multibit -hierarchical }
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp"} {
  redirect ${REPORTS_DIR}/${DESIGN_NAME}.multibit.components.rpt {report_multibit -hierarchical }
}

#################################################################################
# Compile the Design
#
# Recommended Options:
#
#     -scan
#     -gate_clock (-self_gating)
#     -retime
#     -spg
#
# Use compile_ultra as your starting point. For test-ready compile, include
# the -scan option with the first compile and any subsequent compiles.
#
# Use -gate_clock to insert clock-gating logic during optimization.  This
# is now the recommended methodology for clock gating.
#
# Use -self_gating option in addition to -gate_clock for potentially saving 
# additional dynamic power, in topographical mode only. For registers 
# that are already clock gated, the inserted self-gate will be collapsed 
# with the existing clock gate. This behavior can be controlled 
# using the set_self_gating_options command
# XOR self gating should be performed along with clock gating, using -gate_clock
# and -self_gating options. XOR self gates will be inserted only if there is 
# potential power saving without degrading the timing.
# An accurate switching activity annotation either by reading in a saif 
# file or through set_switching_activity command is recommended.
# You can use "set_self_gating_options" command to specify self-gating 
# options.
#
# Use the -spg option to enable Design Compiler Graphical physical guidance flow.
# The physical guidance flow improves QoR, area and timing correlation, and congestion.
# It also improves place_opt runtime in IC Compiler.
#
# You can selectively enable or disable the congestion optimization on parts of 
# the design by using the set_congestion_optimization command.
# This option requires a license for Design Compiler Graphical.
#
# The constant propagation is enabled when boundary optimization is disabled. In 
# order to stop constant propagation you can do the following
#
# set_compile_directives -constant_propagation false <object_list>
#
# Note: Layer optimization is on by default in Design Compiler Graphical, to 
#       improve the the accuracy of certain net delay during optimization.
#       To disable the the automatic layer optimization you can use the 
#       -no_auto_layer_optimization option.
#
#################################################################################
## RM+ Variable and Command Settings before first compile_ultra
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp" || $OPTIMIZATION_FLOW == "tim" } {
  if {[shell_is_in_topographical_mode]} {
    # The set_qor_strategy -metric total_power recipe is focused on high-effort timing and total power reduction
    # The set_qor_strategy -metric timing recipe is focused only on high-effort timing reduction
    # The set_qor_strategy -reduced_effort option adjusts selected recipe for reduced runtime at the expense of timing QOR
    # A summary of application variables changed by this command are printed to the log file

    set set_qor_strategy_cmd "set_qor_strategy -stage synthesis -mode ${SET_QOR_STRATEGY_MODE}"
    if { $OPTIMIZATION_FLOW == "hplp" } {
      lappend set_qor_strategy_cmd -metric total_power
    } elseif { $OPTIMIZATION_FLOW == "tim" } {
      lappend set_qor_strategy_cmd -metric timing
    }
    if {$ENABLE_REDUCED_EFFORT} {lappend set_qor_strategy_cmd -reduced_effort}
    puts "RM-info: Running $set_qor_strategy_cmd"
    eval ${set_qor_strategy_cmd}
  }
}

if { $ENHANCED_TNS_OPTIMIZATION } {
  #The following variable, when set to true, runs additional optimizations to improve the timing of  the design at the cost of additional run time.
  set_app_var compile_enhanced_tns_optimization true
}

if { $OPTIMIZATION_FLOW == "hc"} {
  if {[shell_is_in_topographical_mode]} {

    # This command enables congestion aware Global buffering based on Zroutebased estimation,
    # reducing congestion along narrow channels across macros. Enabling this feature may have 
    # runtime and QOR impact. Enable this variable on macro intensive designs with narrow channels.
    # set_ahfs_options -global_route true


    # With the following variables set, Zroute-based congestion-driven placement is enabled
    # instead of virtual route based estimation. 
    # Enabling this feature may have runtime impact. Enable this for highly congested designs
    # set_app_var placer_congestion_effort medium
    # set_app_var placer_enable_enhanced_router true

    # Enabling the variable can lead to lower congestion for designs that have congestion due to
    # multiplexing logic in the RTL. This variable is supported only in the initial compile step,
    # Not supported in incremental compile.
    set_app_var compile_prefer_mux true
  }
}

if { (${OPTIMIZATION_FLOW} == "hc") || (${OPTIMIZATION_FLOW} == "hplp") } {
  if {[shell_is_in_topographical_mode]} {
    # Enable congestion-driven  placement  in incremental compile to improve congestion    
    # while preserving quality of results

    set_app_var spg_congestion_placement_in_incremental_compile true
  }
}

if {[shell_is_in_topographical_mode]} {
  ### DCNXT ICC2link flow is recommended for 7nm and lower node for better timing & congestion correlation with ICC2
  ### Set ICC2link related option:
  set dcnxt_use_icc2_link_cmd "dcnxt_use_icc2_link"

  if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {lappend dcnxt_use_icc2_link_cmd -auto_floorplan false}

  puts "RM-info: Running $dcnxt_use_icc2_link_cmd"
  eval ${dcnxt_use_icc2_link_cmd}

  ### Specify node name using set_technology command:
  if { $TECHNOLOGY_NODE != "" } {
      set_technology -node $TECHNOLOGY_NODE
  }
}

### analyze_mv_feasibility is the command that helps to identify if optimization will result in unmapped PM cells without running synthesis.
### analyze_mv_feasibility analyzes the UPF and design/library setup and provides feedback on whether all the isolation cells and enable level shifters can get mapped
analyze_mv_feasibility

rm_source -file $DCRM_PRE_COMPILE_SCRIPT -optional -print DCRM_PRE_COMPILE_SCRIPT

set compile_ultra_cmd "compile_ultra -gate_clock -scan"

if {[shell_is_in_topographical_mode]} {lappend compile_ultra_cmd -spg}
if { $INSERT_SELF_GATES } {lappend compile_ultra_cmd -self_gating}

puts "RM-info: Running $compile_ultra_cmd"
eval ${compile_ultra_cmd}

rm_source -file $DCRM_POST_COMPILE_SCRIPT -optional -print DCRM_POST_COMPILE_SCRIPT

# Writes tool reports or GUI layout images, and corresponding QORsum-compatible table data to disk
write_qor_data -label compile -report_group placed

#################################################################################
# Save Design after First Compile
#################################################################################

write_file -format ddc -hierarchy -output ${OUTPUTS_DIR}/${DESIGN_NAME}.compile_ultra.ddc

if {$DCRM_DESIGN_PLANNING} {
  puts "RM-info: Skipping physical MB banking, DFT insertion and compile incremental in design planning flow"
} else {
  #################################################################################
  # Performing placement aware multibit banking
  #################################################################################

  #################################################################################
  # You can use placement aware multibit banking to group single-bit register cells that are
  # physically near each other into a multibit registers. 
  # This has to be done before DFT insertion in Design Compiler
  # These commands require a Design Compiler Graphical license
  # Please use -wns_threshold option with identify_register_banks command if u want to 
  # exclude specific percentage of timing critical registers from multibit banking
  # identify_register_banks -output ${OUTPUTS_DIR}/${DESIGN_NAME}.register_bank.rpt
  # redirect ${REPORTS_DIR}/${DESIGN_NAME}.register_bank_report_file.rpt {rm_source -file ${OUTPUTS_DIR}/${DESIGN_NAME}.register_bank.rpt -print ${DESIGN_NAME}.register_bank.rpt}
  #################################################################################


  ################################################################################
  ## RM+ Variable and Command Settings before incremental compile
  ################################################################################
  if { $OPTIMIZATION_FLOW == "hplp" } {
    if {[shell_is_in_topographical_mode]} {
      # You can use placement aware multibit banking to group single-bit register cells that 
      # are physically near each other into a multibit registers
      # Please use -wns_threshold option with identify_register_banks command if u want to 
      # exclude specific percentage of timing critical registers from multibit banking
      identify_register_banks -output \
        ${OUTPUTS_DIR}/${DESIGN_NAME}.register_bank.rpt
      rm_source -file ${OUTPUTS_DIR}/${DESIGN_NAME}.register_bank.rpt -print ${DESIGN_NAME}.register_bank.rpt
    }
  }

  #################################################################################
  # DFT Compiler Optimization Section
  #################################################################################

  rm_source -file $DFT_SETUP_FILE -print DFT_SETUP_FILE

  #############################################################################
  # DFT Test Protocol Creation
  #############################################################################

  # Identify Clock Gates
  identify_clock_gating

  create_test_protocol

  #############################################################################
  # DFT Insertion
  #############################################################################

  dft_drc                                
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.dft_drc_configured.rpt {dft_drc -verbose}
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.scan_config.rpt {report_scan_configuration}
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.compression_config.rpt {report_scan_compression_configuration}
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.report_dft_insertion_config.preview_dft.rpt {report_dft_insertion_configuration}
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.preview_dft_summary.rpt {preview_dft}
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.preview_dft.rpt {preview_dft -show all -test_points all}

  # Uncomment following code when using DFTMAX Ultra:
  #redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.compression_config.rpt {report_streaming_compression_configuration}

  # Visualizing DFTMAX Ultra architecture
  # Use the streaming_dft_planner command to visualize the currently configured DFTMAX Ultra architecture.
  # Refer to the DFT Compiler, DFTMAX and DFTMAX Ultra User Guide, "Planning the Streaming DFT Architecture" section for more details.
  #streaming_dft_planner

  insert_dft

  #################################################################################
  # Re-create Default Path Groups
  #
  # In case of ports being created during insert_dft they need to be added
  # to those path groups.
  # Separating these paths can help improve optimization.
  #################################################################################

  if {[shell_is_in_topographical_mode]} {
    set current_scenario_saved [current_scenario]
    foreach scenario [all_active_scenarios] {
      current_scenario ${scenario}
      set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
      group_path -name REGOUT -to [all_outputs]
      group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}]
      group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
    }
    current_scenario ${current_scenario_saved}
  } else {
    set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
    group_path -name REGOUT -to [all_outputs]
    group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}]
    group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
  }

  rm_source -file $DCRM_POST_DFT_SCRIPT -optional -print DCRM_POST_DFT_SCRIPT

  rm_source -file $LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST -optional -print LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST

  #########################################################################
  # Incremental compile is required if netlist and/or constraints are 
  # changed after first compile
  # Example: DFT insertion, Placement aware multibit banking etc.       
  # Incremental compile is also recommended for final QoR signoff as well
  #########################################################################   

  rm_source -file $DCRM_PRE_INCR_COMPILE_SCRIPT -optional -print DCRM_PRE_INCR_COMPILE_SCRIPT

  set compile_ultra_incr_cmd "compile_ultra -incremental -scan"

  if {[shell_is_in_topographical_mode]} {lappend compile_ultra_incr_cmd -spg}

  puts "RM-info: Running $compile_ultra_incr_cmd"
  eval ${compile_ultra_incr_cmd}

  # Writes tool reports or GUI layout images, and corresponding QORsum-compatible table data to disk
  write_qor_data -label compile_incremental -report_group placed
}
#################################################################################
# Check for MV Violations
#################################################################################

if {[shell_is_in_topographical_mode]} {
  set current_scenario_saved [current_scenario]
  foreach scenario [all_active_scenarios] {
    current_scenario ${scenario}
    redirect -file ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mv_drc.final_summary.rpt ${scenario}] {check_mv_design}
    redirect -file ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mv_drc.final.rpt ${scenario}] {check_mv_design -verbose}
  }
  current_scenario ${current_scenario_saved}
} else {
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mv_drc.final_summary.rpt {check_mv_design}
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mv_drc.final.rpt {check_mv_design -verbose}
}

#################################################################################
# Write Out Final Design and Reports
#
#        .ddc:   Recommended binary format used for subsequent Design Compiler sessions
#        .v  :   Verilog netlist for ASCII flow (Formality, PrimeTime, VCS)
#       .spef:   Topographical mode parasitics for PrimeTime
#        .sdf:   SDF backannotated topographical mode timing for PrimeTime
#        .sdc:   SDC constraints for ASCII flow
#        .upf:   UPF multivoltage information for mapped design
#
#################################################################################

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "bottom"} {
  # If this will be a sub-block in a hierarchical design, uniquify with block unique names
  # to avoid name collisions when integrating the design at the top level
  set_app_var uniquify_naming_style "${DESIGN_NAME}_%s_%d"
  uniquify -force
}

change_names -rules verilog -hierarchy

if {$DESIGN_STYLE == "flat"} {
  set write_icc2_files_cmd "write_icc2_files -force -output ${OUTPUTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}"
  
  if {$UPF_MODE == "golden" || $CREATES_PG_NETLIST == "true"} {
    lappend write_icc2_files_cmd -pg
  }
  if {$UPF_MODE == "golden"} {
    lappend write_icc2_files_cmd -golden_upf ${UPF_FILE}
  }
  puts "RM-info: Running $write_icc2_files_cmd"
  eval ${write_icc2_files_cmd}
}

#############################################################################
# DFT Write out Test Protocols and Reports
#############################################################################

if {$DCRM_DESIGN_PLANNING} {
  puts "RM-info: Skipping DFT write out section in design planning flow"
} else {
  # write_scan_def adds SCANDEF information to the design database in memory, so 
  # this command must be performed prior to writing out the design database 
  # containing binary SCANDEF.

  write_scan_def -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.scandef

  if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {
    # Write out expanded SCANDEF for floorplanning purposes
    # Need to derive Tcl list of hierarchical cells that are not IC Compiler Block Abstractions for SCANDEF expansion
    if { (${DDC_HIER_DESIGNS} != "") || (${DC_BLOCK_ABSTRACTION_DESIGNS} != "") } {
      set hier_cells ""
      set HIER_DESIGNS "${DDC_HIER_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS}"
      foreach_in_collection hier_cell [sub_instances_of -hierarchy -of_references ${HIER_DESIGNS} ${DESIGN_NAME}] {
        lappend hier_cells [get_object_name $hier_cell]
      }
      write_scan_def -expand_elements ${hier_cells} -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.expanded.scandef
    }
  } else {
    write_test_model -format ctl -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.ctl
  }

  # DFT outputs for each test mode
  
  foreach m [all_test_modes] {
    if {$m == "Mission_mode"} {continue}
    puts "RM-info: Writing DFT outputs for $m test mode"
    current_test_mode $m
    write_test_protocol -test_mode $m -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.${m}.spf
    redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.scanpath.${m}.rpt {report_scan_path}
    dft_drc
    redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.dft_drc_inserted.${m}.rpt {dft_drc -verbose}
  }
  reset_test_mode
}

#################################################################################
# Write out Design Data
#################################################################################

if {[shell_is_in_topographical_mode]} {

  # Note: A secondary floorplan file ${DESIGN_NAME}.mapped.fp.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.fp

  # Standard cell physical guidance is created to support SPG ASCII hand-off
  # to IC Compiler by the write_def command.
  # Invoking write_def commands requires a Design Compiler Graphical license or an IC Compiler
  # Design Planning license.

  write_def -components -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.std_cell.def

  # Do not write out net RC info into SDC
  set_app_var write_sdc_output_lumped_net_capacitance false
  set_app_var write_sdc_output_net_resistance false

  set all_active_scenario_saved [all_active_scenarios]
  set current_scenario_saved [current_scenario]
  set_active_scenarios -all
  foreach scenario [all_active_scenarios] {
    current_scenario ${scenario}

    # Write parasitics data from Design Compiler Topographical placement for static timing analysis
    write_parasitics -output ${OUTPUTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.spef ${scenario}]

    # Write SDF backannotation data from Design Compiler Topographical placement for static timing analysis
    write_sdf ${OUTPUTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.sdf ${scenario}]

    write_sdc -nosplit ${OUTPUTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.sdc ${scenario}]
  }
  current_scenario ${current_scenario_saved}
  set_active_scenarios ${all_active_scenario_saved}
}

# Write out link library information for PrimeTime when using instance-based target library settings
write_link_library -out ${OUTPUTS_DIR}/${DESIGN_NAME}.link_library.tcl


if {$SAIF_FILE != "" || $GENERATE_SAIFMAP_WITHOUT_SAIF} {
  # Write out SAIF name mapping file for PrimeTime-PX and ICC2
  saif_map -type ptpx -write_map ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.saif.ptpx.map
  saif_map -write_map ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.saif.dc.map
}

#################################################################################
# Generate MV Reports
#################################################################################

# For MCMM, some MV reports could have different voltages for different scenarios
if {[shell_is_in_topographical_mode]} {
  # For MCMM, some MV reports could have different voltages for different scenarios
  set current_scenario_saved [current_scenario]
  foreach scenario [all_active_scenarios] {
    current_scenario ${scenario}
  
    # Report all power domains in the design
    redirect -file ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.power_domain.rpt ${scenario}] \
      {report_power_domain -hierarchy}
  
    # Report the top level supply nets
    redirect -file ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.supply_net.rpt ${scenario}] \
      {report_supply_net}
  
    # Report the level shifters in the design
    if {[sizeof_collection [get_power_domains * -hierarchical -quiet]] > 0} {
      redirect -file ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.level_shifter.rpt ${scenario}] \
        {report_level_shifter -domain [get_power_domains * -hierarchical]}
    } else {
      redirect -file ${REPORTS_DIR}/[dcrm_mcmm_filename ${DESIGN_NAME}.mapped.level_shifter.rpt ${scenario}] \
        {report_level_shifter}
    }
  }
  current_scenario ${current_scenario_saved}
} else {
  # Report all power domains in the design
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.power_domain.rpt \
    {report_power_domain -hierarchy}
  
  # Report the top level supply nets
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.supply_net.rpt \
    {report_supply_net}
  
  # Report the level shifters in the design
  if {[sizeof_collection [get_power_domains * -hierarchical -quiet]] > 0} {
    redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.level_shifter.rpt \
      {report_level_shifter -domain [get_power_domains * -hierarchical]}
  } else {
    redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.level_shifter.rpt \
      {report_level_shifter}
  }
}

#################################################################################
# Generate Final Reports
#################################################################################

update_timing

# Following commands are not supported by parallel_execute
if {[shell_is_in_topographical_mode]} {
  set parallel_all_active_scenarios [all_active_scenarios]
}
set parallel_get_power_domains    [get_object_name [get_power_domains * -hierarchical -quiet]]
set parallel_get_power_switches   [get_power_switches * -hierarchical -quiet]

set parallel_execute_cmds {
  "redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.qor.rpt {report_qor}"
  "redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.clock_gating.rpt {report_clock_gating -nosplit -multi_stage}"
  "redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.designware_area.rpt {report_area -designware}"
  "redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.final_resources.rpt {report_resources -hierarchy}"
  "redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.area.rpt {report_area -physical -nosplit}"
  "redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.pst.rpt {report_pst}"
}
if {[info exists parallel_all_active_scenarios]} {
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.timing.rpt {report_timing -scenarios $parallel_all_active_scenarios -transition_time -nets -attributes -nosplit}}
} else {
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.timing.rpt {report_timing -transition_time -nets -attributes -nosplit}}
}
if {[llength $parallel_get_power_domains] > 0} {
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.isolation_cell.rpt {report_isolation_cell -domain $parallel_get_power_domains}}
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.retention_cell.rpt {report_retention_cell -domain $parallel_get_power_domains}}
} else {
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.isolation_cell.rpt {report_isolation_cell}}
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.retention_cell.rpt {report_retention_cell}}
}
if {[llength $parallel_get_power_switches] > 0} {
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.power_switch.rpt {report_power_switch $parallel_get_power_switches}}
} else {
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.power_switch.rpt {report_power_switch}}
}
if {!$DCRM_DESIGN_PLANNING} {
  # Note: check_scan_def is not supported with subdesign abstraction
  if {$DESIGN_STYLE == "flat" || ($DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "bottom")} {
    lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.check_scan_def.rpt {check_scan_def}}
  }
  lappend parallel_execute_cmds {redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.dft_signals.rpt {report_dft_signal}}
}
parallel_execute $parallel_execute_cmds

# Generates the QORsum web application/report for viewing or comparing QOR results
compare_qor_data -force -run_locations ./qor_data

if { $OPTIMIZATION_FLOW == "hplp"} {
  redirect ${REPORTS_DIR}/${DESIGN_NAME}.multibit.banking.rpt {report_multibit_banking -nosplit }
}

if {[shell_is_in_topographical_mode]} {
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.power.rpt {report_power -scenarios [all_active_scenarios] -nosplit}
} else {
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.power.rpt {report_power -nosplit}
}

if { $INSERT_SELF_GATES } {
  redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.self_gating.rpt {report_self_gating -nosplit}
}

# Uncomment the next line to reports the number, area, and  percentage  of cells 
# for each threshold voltage group in the design.
# redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.threshold.voltage.group.rpt {report_threshold_voltage_group -nosplit}

if {[shell_is_in_topographical_mode]} {
  # report_congestion (topographical mode only) uses zroute for estimating and reporting 
  # routing related congestion which improves the congestion correlation with IC Compiler.
  # Design Compiler Topographical supports create_route_guide command to be consistent with IC
  # Compiler after topographical mode synthesis.
  # Those commands require a license for Design Compiler Graphical.

  if {$REPORT_CONGESTION} {
    redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.congestion.rpt {report_congestion}

    # Use the following to generate and write out a congestion map from batch mode
    # This requires a GUI session to be temporarily opened and closed so a valid DISPLAY
    # must be set in your UNIX environment.

    if {![info exists env(DISPLAY)]} {
      puts "RM-info: The DISPLAY environment variable is not set. Skipping congestion map generation"
    } else {
      gui_start

      # Create a layout window
      set MyLayout [gui_create_window -type LayoutWindow]

      # Build congestion map in case report_congestion was not previously run
      report_congestion -build_map

      # Display congestion map in layout window
      gui_show_map -map "Global Route Congestion" -show true

      # Zoom full to display complete floorplan
      gui_zoom -window [gui_get_current_window -view] -full

      # Write the congestion map out to an image file
      # You can specify the output image type with -format png | xpm | jpg | bmp

      # The following saves only the congestion map without the legends
      gui_write_window_image -format png -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.congestion_map.png

      # The following saves the entire congestion map layout window with the legends
      gui_write_window_image -window ${MyLayout} -format png -file ${REPORTS_DIR}/${DESIGN_NAME}.mapped.congestion_map_window.png

      gui_stop
    }
  }
}

#################################################################################
# Write out Design
#################################################################################

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {

  #################################################################################
  # Write out Top-Level Design Without Hierarchical Blocks
  #
  # Note: The write command will automatically skip writing .ddc physical hierarchical
  #       blocks in Design Compiler topographical mode and Design Compiler block
  #       abstractions blocks. DC NXT WLM mode still need to be removed before writing out
  #       the top-level design. In the same way for the multivoltage flow, save_upf will
  #       skip hierarchical blocks when saving the power intent data.
  #
  # When reading the design into other tools, read in all of the mapped hierarchical
  # blocks and the mapped top-level design.
  #
  # For IC Compiler II: Replace the Design Compiler block abstractions with the complete
  #                     block mapped netlist.
  # For Formality: Verify each block and top separately.
  #
  #################################################################################

  puts "RM-info: Writing out top level design without hierarchical blocks"
  
  # Remove the hierarchical designs before writing out the top-level mapped verilog design, in WLM mode.
  if {![shell_is_in_topographical_mode]} {
    if {[get_designs -quiet ${DDC_HIER_DESIGNS}] != "" } {
      remove_design -hierarchy [get_designs -quiet ${DDC_HIER_DESIGNS}]
    }
  }
  
  write_file -format verilog  -hierarchy -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.v
  
  # Remove the hierarchical designs before writing out the top-level mapped ddc design, in WLM mode.
  if {![shell_is_in_topographical_mode]} {
    if {[get_designs -quiet ${DDC_HIER_DESIGNS}] != "" } {
      remove_design -hierarchy [get_designs -quiet ${DDC_HIER_DESIGNS}]
    }
  }
  
  # Write out ddc mapped top-level design
  write_file -format ddc -hierarchy -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.ddc

} else {

  if {$DESIGN_STYLE == "flat"} {
    puts "RM-info: Writing out flat design"
  } else {
    puts "RM-info: Writing out bottom-level design"
    create_block_abstraction
  }

  if {$UPF_MODE == "golden"} {
    write_file -format verilog -hierarchy -pg -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.pg.v
  }
  write_file -format verilog -hierarchy -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.v
  write_file -format ddc     -hierarchy -output ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.ddc

}

if {$UPF_MODE != "none"} {
  set save_upf_cmd "save_upf"
  if {$UPF_MODE == "golden"} {
    lappend save_upf_cmd -include_supply_exceptions
    lappend save_upf_cmd -supplemental ${OUTPUTS_DIR}/${DESIGN_NAME}.supplement.upf
  } elseif {$UPF_MODE == "prime"} {
    lappend save_upf_cmd ${OUTPUTS_DIR}/${DESIGN_NAME}.mapped.upf
  }
  puts "RM-info: Running $save_upf_cmd"
  eval ${save_upf_cmd}
}

# Write and close SVF file and make it available for immediate use
set_svf -off

# Save NDM to disk
if {[shell_is_in_topographical_mode]} {
  save_lib
}

exit
