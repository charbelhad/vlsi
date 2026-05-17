#################################################################################
# RTL read script for Design Compiler NXT Reference Methodology
# Script: dc.read_design.tcl
# Version: U-2022.12
# Copyright (C) 2007-2023 Synopsys, Inc. All rights reserved.
#################################################################################

define_design_lib WORK -path ./WORK

# The following variable helps verification when there are differences between DC and FM while inferring logical hierarchies
set_app_var hdlin_enable_hier_map true

switch $RTL_SOURCE_FORMAT {
  autoread {
    analyze -autoread \
      -rebuild \
      -recursive \
      -top ${DESIGN_NAME} \
      -output_script ${OUTPUTS_DIR}/${DESIGN_NAME}.autoread_rtl.tcl \
      ${RTL_SOURCE_FILES}
  }
  vhdl {
    analyze -format vhdl ${RTL_SOURCE_FILES}
  }
  sverilog {
    # By default, the tool uses  simple  names  for  elements  inferred  from
    # unions in SystemVerilog. Setting this variable to true enables the tool
    # to use the name of the first union member as a reference for the  port,
    # net, and cell names associated with the union data type.
    set_app_var hdlin_sv_union_member_naming true

    analyze -format sverilog ${RTL_SOURCE_FILES}
  }
  verilog {
    analyze -format verilog ${RTL_SOURCE_FILES}
  }
  ddc {
    read_ddc ${DESIGN_NAME}.elab.ddc
  }
}

if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL == "bottom" && $RTL_SOURCE_FORMAT == "sverilog" && ${SV_WRAPPER_DESIGN_NAME} != ""} {
  # Use the wrapper to elaborate the design with interface ports
  puts "RM-info: Elaborating SystemVerilog wrapper design ${SV_WRAPPER_DESIGN_NAME}"
  elaborate ${SV_WRAPPER_DESIGN_NAME}
  current_design [get_designs -quiet * -filter "@hdl_template == ${DESIGN_NAME}"]
  remove_design -quiet $SV_WRAPPER_DESIGN_NAME
  rename_design [current_design_name] ${DESIGN_NAME}
} else {
  puts "RM-info: Elaborating design ${DESIGN_NAME}"
  elaborate ${DESIGN_NAME}
}
set_verification_top

