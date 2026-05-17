##########################################################################################
# Variables for Design Compiler methodology scripts
# Script: dc_setup.tcl
# Version: U-2022.12
# Copyright (C) 2007-2023 Synopsys, Inc. All rights reserved.
##########################################################################################

##################################################################
# Design variables
##################################################################

set DESIGN_NAME                                 ""    ;#  The name of the design
set DCRM_NDM_LIBRARY_NAME                       ${DESIGN_NAME}.ndm
set INSERT_SELF_GATES                           false ;# Insert self-gating during compile
set ANALYZE_RTL_CONGESTION                      false ;# Include pre-synthesis analyze_rtl_congestion in final reports
set REPORT_CONGESTION                           false ;# Include report_congestion in final reports
set ENHANCED_TNS_OPTIMIZATION                   false ;# Enable enhanced TNS optimization
set OPTIMIZATION_FLOW                           none  ;# Specify one flow out of: none | hplp | hc | tim
set ENABLE_REDUCED_EFFORT                       false ;# Use reduced effort for lower runtime in hplp and tim flows (false | true)
set SET_QOR_STRATEGY_MODE                       "balanced" ;# balanced|early_design; default is balanced;
                                                           ;# Specify one mode for set_qor_strategy -mode option and the settings will be configured for the target mode
set DFT_CONFIGURATION                           SCAN  ;# DFT Configuration options are: DC-CODEC_COREWRAP_TP_SCAN | THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN | TP_SCAN | SCAN
set DFT_CLOCK_LIST                              ""    ;# Block specific clocks used as dft signals
set DFT_RESET_INFO                              ""    ;# Block specific resets and presets used as dft signals. Specify as pairs showing {name sense}. e.g. {{reset 0} {preset_n 1}}
set DFT_CONSTANT_INFO                           ""    ;# Block specific constants used as dft signals. Specify as pairs showing {name sense}. e.g. {{scan_mode 0}}
set DFT_INTERNAL_SCAN_CHAIN_COUNT               8     ;# Scan chain count for Internal_scan test mode (see dft_ports.tcl and scan_configuration.dc.tcl)
set DFT_WRAPPER_CHAIN_COUNT                     8     ;# Scan chain count used for core wrap DFT (see dft_ports.tcl and scan_configuration.dc.tcl)
set DFT_COMPRESSION_SCAN_CHAIN_COUNT            64    ;# Scan chain count used in compression DFT (see dft_ports.tcl and scan_configuration.dc.tcl)
set SAIF_FILE                                   ""    ;# SAIF file path
set SAIF_FILE_SOURCE_INSTANCE                   ""    ;# Name of the instance of the current design as it appears in SAIF file.
set SAIF_FILE_TARGET_INSTANCE                   ""    ;# Name of the target instance on which activity is to be annotated.
set SAIF_FILE_POWER_SCENARIO                    ""    ;# Specify a power scenario where the SAIF is to be applied
set SAIF_FILE_SCALING_FACTOR                    ""    ;# Scaling factor for toggle rate annotated from SAIF file
set SAIF_FILE_SCALING_UNIT                      ""    ;# Time unit annotated in SAIF file
set GENERATE_SAIFMAP_WITHOUT_SAIF               true  ;# Initialize SAIF map when there is no SAIF_FILE
set CREATES_PG_NETLIST                          true  ;# Include PG network when writing netlist

##########################################################################################
# Hierarchical Flow Design Variables
##########################################################################################

set DESIGN_STYLE                                "flat"   ;# Specify the design style; flat|hier; default is flat;
set PHYSICAL_HIERARCHY_LEVEL                    "bottom" ;# Specify the current level of hierarchy for the hierarchical flow; top|bottom;
set BLOCK_DESIGN_HAS_SV_INTERFACE_PORTS         false    ;# Set to true if in top level and integrating a block that has SystemVerilog interface ports
set CTL_FOR_ICC2_ABSTRACT_BLOCKS                ""       ;# provide a list of the full path to each ctl model required by top level compile

##########################################################################################
# Hierarchical Flow Blocks
#
# If you are performing a hierarchical flow, define the hierarchical designs here.
# List the reference names of the hierarchical blocks.  Cell instance names will
# be automatically derived from the design names provided.
#
# Note: These designs are expected to be unique. There should not be multiple
#       instantiations of physical hierarchical blocks.
#
##########################################################################################

set DDC_HIER_DESIGNS                            ""    ;# List of Design Compiler hierarchical design names (.ddc will be read)
set DC_BLOCK_ABSTRACTION_DESIGNS                ""    ;# List of Design Compiler block abstraction hierarchical designs (.ddc will be read)
                                                       # without transparent interface optimization
set ICC2_BLOCK_ABSTRACTION_NDM                  ""    ;# List of Fusion Compiler and/or IC Compiler II block abstraction hierarchical design names and NDM path
                                                       # Use format: {<design_name1> <ndm_path1>:<block_name1> <design_name2> <ndm_path2>:<block_name2> ...}

##########################################################################################
# Wrapper Design name For Hierarchical Design with Interface ports
#
# If you are performing an hierachical flow, and the hierachical design have SystemVerilog
# interface ports, define here the name of the wrapper design to be elaborated.
# The wrapper will specify interface information and capture the correct design name.
#
# For more informacion how to write the wrapper design refer to the following solvnet
# article:
# "Building SystemVerilog Designs Using a Bottom-Up Approach"
# https://solvnet.synopsys.com/retrieve/039318.html
#
##########################################################################################

set SV_WRAPPER_DESIGN_NAME                      ""    ;# Define the wrapper design name to correctly
                                                       # elaborate the hierachical design

##########################################################################################
# Tool Setup Variables
##########################################################################################

set DC_MAX_CORES     8 ;# Max number of cores used by DC
set DCRM_ALIB_CACHE  . ;# Location to store analyze library data

##########################################################################################
# Library Setup Variables
##########################################################################################

set TARGET_LIBRARY_FILES          ""  ;# Target technology logical libraries, DB and Fusion Library formats supported
set REFERENCE_LIBRARY             ""  ;# NDM reference library, optional when using Fusion Library format only
set ADDITIONAL_SEARCH_PATH        ""  ;# Additional search path to be added to the default search path (used by all tools)
set MAP_FILE                      ""  ;# Mapping file for TLUplus  (used by DCNXT)
set ADDITIONAL_LINK_LIB_FILES     ""  ;# Extra link logical libraries not included in TARGET_LIBRARY_FILES, DB and Fusion Library formats supported
set TECH_FILE                     ""  ;# Milkyway technology file (used by DCNXT)
set MIN_ROUTING_LAYER             ""  ;# Min routing layer (used by DCNXT)
set MAX_ROUTING_LAYER             ""  ;# Max routing layer (used by DCNXT)
set TECHNOLOGY_NODE               ""  ;# Choose library node: 28nm, 16nm, etc

set LIBRARY_DONT_USE_FILE                  "" ;# Tcl file with library modifications for dont_use
set LIBRARY_DONT_USE_PRE_COMPILE_LIST      "" ;# Tcl file for customized don't use list before first compile
set LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST "" ;# Tcl file with library modifications for dont_use before incr compile

####################
# Pre/Post scripts #
####################

set DCRM_PRE_ELABORATE_SCRIPT          "" ;# Optional file to insert user code prior to elaboration
set DCRM_POST_ELABORATE_SCRIPT         "" ;# Optional file to insert user code after elaboration
set DCRM_PRE_COMPILE_SCRIPT            "" ;# Optional file to insert user code prior to compile
set DCRM_POST_COMPILE_SCRIPT           "" ;# Optional file to insert user code after compile
set DCRM_POST_DFT_SCRIPT               "" ;# Optional file to insert user code after DFT insertion
set DCRM_PRE_INCR_COMPILE_SCRIPT       "" ;# Optional file to insert user code prior to incremental compile

###########
# Reports #
###########

set REPORTS_DIR reports

################
# Output Files #
################

set OUTPUTS_DIR results

#################################################################################
# Flow Files
#################################################################################

###################
# Input Files #
###################

set DCRM_RTL_READ_SCRIPT                                dc.read_design.tcl
set RTL_SOURCE_FORMAT                                   verilog ;# verilog | vhdl | sverilog | autoread | ddc
set RTL_SOURCE_FILES                                    "" ;# Enter the list of source RTL files if reading from RTL
set DCRM_DESIGN_PLANNING                                false ;# Fast compile flow for DP
set DCRM_PHYSICAL_CONSTRAINTS_INPUT_FILE                ""
set DCRM_DP_PHYSICAL_CONSTRAINTS_INPUT_FILE             "mpc.tcl" ;# Minimal physical constraints for design planning 
set DCRM_DEF_INPUT_FILE                                 ""
set DCRM_MCMM_SCENARIOS_SETUP_FILE                      ""
set DCRM_FLOORPLAN_INPUT_FILE                           ""
set DCRM_MV_SET_VOLTAGE_INPUT_FILE                      "" 
set DCRM_SDC_INPUT_FILE                                 "" 
set DCRM_CONSTRAINTS_INPUT_FILE                         "" 

################
# Output Files #
################

set DCRM_FINAL_DESIGN_ICC2                              ICC2_files

#################################################################################
# DFT Flow Files
#################################################################################

###################
# DFT Input Files #
###################

set DFT_SETUP_FILE                                  "scan_configuration.dc.tcl" ;# DFT scan configuration setup file 
set DFT_PORTS_FILE                                  "dft_ports.tcl"             ;# DFT related port creation file
set DFT_TEST_POINT_FILE                             "dft_test_point.example.tcl"

#################################################################################
# MV Flow Files
#################################################################################

###################
# MV Input Files  #
###################

set UPF_FILE                                            ""
set UPF_MODE                                            prime ;# prime | golden | none

##################
# FM Variables #
##################

set FMRM_RTL_READ_SCRIPT                                "" ;# Read RTL script for Formality

##################
# VCLP Variables #
##################

set VCLP_RUN                                            "NETLIST" ;# Choose the stage you want to run VC Static. Allowed values are RTL or NETLIST
set VCLPRM_RTL_READ_SCRIPT                              ""        ;# Read RTL script for VCLP

