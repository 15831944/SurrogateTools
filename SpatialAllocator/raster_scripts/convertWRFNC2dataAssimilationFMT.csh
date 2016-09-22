#!/bin/csh -f
########################################################################
#
# Purpose: This scripts file converts a WRF-ready NetCDF file containing
# GOES satellite variables generated by computeGridGOES.exe program
# to data assimilation format.  It copies the original file and add 
# additional 3d variables with the same value, but one time step ahead. 
#
# 
# Written by:  LR, April 2009
#              the Institute for the Environment at UNC, Chapel Hill
#              in support of the EPA NOAA CMAS Modeling, 2008-2009.
# 
# Usage:  convertWRFNC2dataAssimilationFMT.csh
# 
########################################################################

#
# Input and output Files 
#
setenv INPUT_MM5_GOES_FILENAME  ../output/goes/wrf12km_goes_200608_0111.nc 
setenv OUTPUT_WRF_NETCDF_FILENAME   ../output/goes/wrf12km_goes_200608_0111_WRF.nc


#
# Run the tool
#
../src/raster/toDataAssimilationFMT.exe