##########################################################################################
# Version: U-2022.12
# Copyright (C) 2014-2023 Synopsys, Inc. All rights reserved.
##########################################################################################

set_host_options -max_cores $DC_MAX_CORES

set_app_var search_path ". ./rm_dc_scripts ${ADDITIONAL_SEARCH_PATH} $search_path"

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "top"} {

  set ICC2_BLOCK_ABSTRACTION_DESIGNS [dict keys $ICC2_BLOCK_ABSTRACTION_NDM]

  # For a hierarchical flow, add the block-level results directories to the
  # search path to find the block-level design files.
  
  set HIER_DESIGNS "${DDC_HIER_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS}"
  foreach design $HIER_DESIGNS {
    lappend search_path ../${design}/results
  }
  
  # For a hierarchical UPF flow, add the results directory to the search path for
  # Formality to find the output UPF files.
  
  lappend search_path ${OUTPUTS_DIR}
}

# Change alib_library_analysis_path to point to a central cache of analyzed libraries
# to save runtime and disk space.  The following setting only reflects the
# default value and should be changed to a central location for best results.

set_app_var alib_library_analysis_path $DCRM_ALIB_CACHE

if {![file exists $OUTPUTS_DIR]} {file mkdir $OUTPUTS_DIR} ;# do not change this line or directory may not be created properly
if {![file exists $REPORTS_DIR]} {file mkdir $REPORTS_DIR} ;# do not change this line or directory may not be created properly

if {$UPF_MODE == "golden"} {
  # Enable the Golden UPF mode to use same originla UPF script file throughout the synthesis,
  # physical implementation, and verification flow.

  set_app_var enable_golden_upf true
}

# In cases where RTL has VHDL generate loops or SystemVerilog structs, switching 
# activity annotation from SAIF may be rejected, the following variable setting 
# improves SAIF annotation, by making sure that synthesis object names follow same 
# naming convention as used by RTL simulation. 

set_app_var hdlin_enable_upf_compatible_naming true

#################################################################################
# Library Setup
#################################################################################

set_app_var target_library ${TARGET_LIBRARY_FILES}
set_app_var synthetic_library dw_foundation.sldb
set_app_var link_library "* $target_library $synthetic_library ${ADDITIONAL_LINK_LIB_FILES}"

if {[shell_is_in_topographical_mode]} {
  if {[info exists view_target] && [file exists $DCRM_NDM_LIBRARY_NAME]} {
    puts "RM-info: opening existing lib $DCRM_NDM_LIBRARY_NAME"
    open_lib $DCRM_NDM_LIBRARY_NAME
  } else {
    if {[file exists $DCRM_NDM_LIBRARY_NAME]} {
      puts "RM-info: deleting existing lib $DCRM_NDM_LIBRARY_NAME"
      file delete -force $DCRM_NDM_LIBRARY_NAME
    }
   
    set create_lib_cmd "create_lib -technology $TECH_FILE $DCRM_NDM_LIBRARY_NAME"
    if {${REFERENCE_LIBRARY} != ""} { append create_lib_cmd " -ref_libs \"${REFERENCE_LIBRARY}\""}
    puts "RM-info: Running $create_lib_cmd"
    eval ${create_lib_cmd}
  }
}

set set_check_library_cmd "set_check_library_options -mcmm"
if {$UPF_MODE != "none"} {lappend set_check_library_cmd -upf}
puts "RM-info: Running $set_check_library_cmd"
eval ${set_check_library_cmd}

redirect -file ${REPORTS_DIR}/${DESIGN_NAME}.check_library.rpt {check_library}

#################################################################################
# Library Modifications
#
# Apply library modifications after the libraries are loaded.
#################################################################################

rm_source -file ${LIBRARY_DONT_USE_FILE} -optional -print LIBRARY_DONT_USE_FILE

########################################################################################## 
## Message handling
##########################################################################################

# The following setting removes new variable info messages from the end of the log file

set_app_var sh_new_variable_message false


