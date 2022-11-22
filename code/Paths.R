# ----------------------------------------------------------------- #
# Manuscript Data Paths (Public Version as Exemplar)
# 
# Author: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Date created: May 20, 2022
#
# Modified on:
# Modified by:
#
# Notes:
# A) You must change the path to `cdph_path` for your own directory
# ----------------------------------------------------------------- #

# Path to CDPH coyote plague data
cdph_path <- "INSERT PATH TO DATA"

# Path to save and access PRISM data
prism_path <- paste(getwd(), "/data/prismtmp", sep = "")

# Paths to access elevation data
elevation_zip <- paste(prism_path, "/PRISM_us_dem_4km_bil.zip", sep = "") # ZIP file
elevation_path <- paste(prism_path, "/PRISM_us_dem_4km_bil.bil", sep = "") # BIL file

# -------------------------- END OF CODE -------------------------- #
