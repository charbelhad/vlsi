##########################################################################################
# Version: U-2022.12
# Copyright (C) 2014-2023 Synopsys, Inc. All rights reserved.
##########################################################################################

# The following procedure is used to control the naming of the scenario-specific
# MCMM input and output files. 
# The naming convention inserts the scenario name before the file extension.

proc dcrm_mcmm_filename { filename scenario } {
  if {$filename == ""} {
    return ""
  }
  return [file rootname $filename].$scenario[file extension $filename]
}

