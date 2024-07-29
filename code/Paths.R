# ----------------------------------------------------------------------------------------------- #
# Manuscript Data Paths (Public Version as Exemplar)
# 
# Created by: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Created on: 2022-05-20
#
# Most recently modified by: @idblr
# Most recently modified on: 2024-06-30
#
# Notes:
# A) You must change the file name in `cdph_path`
# ----------------------------------------------------------------------------------------------- #

# Path to CDPH coyote plague data
cdph_path <- file.path('data', 'cdph', 'INSERT NAME OF DATA FILE')

# Path to save and access PRISM data
prism_path <- file.path('data', 'prism')

# Path to save and access GADM data
prism_path <- file.path('data', 'gadm')

# Paths to access elevation data
elevation_zip <- file.path(prism_path, 'PRISM_us_dem_4km_bil.zip') # ZIP file
elevation_path <- file.path(prism_path, 'PRISM_us_dem_4km_bil.bil') # BIL file

# ----------------------------------------- END OF CODE ----------------------------------------- #
