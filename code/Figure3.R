# ----------------------------------------------------------------- #
# Manuscript Figure 3
# 
# Author: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Date created: May 20, 2022
#
# Modified by: @idblr
# Modified on: November 22, 2022
#
# Notes:
# A) See pre-steps to prepare for model run
# B) 2022/06/29 - Changed color of "sparse data" from black to white
# ----------------------------------------------------------------- #

###############
# PREPARATION #
###############

# Step 1: You must download the elevation BIL zipfile at 4km resolution from the PRISM data portal https://www.prism.oregonstate.edu/normals/
# Step 2: Save the zipfile to the data directory in this repository
# Step 3: Set your own data paths to data in 'Paths.R' file

# Use the code found in 'Preparation.R' and 'Paths.R' files
## Loads eighteen objects
### A) "ca" a large 'SpatialPolygonsDataFrame" of California counties
### B) "ca_buffer" a small 'SpatialPolygonsDataFrame' of California state boundary geographically buffered a little larger
### C) "ca_buffer_proj" a small 'SpatialPolygonsDataFrame' of California state boundary geographically buffered a little larger and projected to UTM10N
### D) "CA_proj" a small 'SpatialPolygonsDataFrame' of California state boundary projected to UTM 10N
### E) "cdph_coyote_sp" a large 'SpatialPointsDataFrame" of CDPH coyote plague data
### F) "crop_pc1" a 'raster' of principal component 1 in California
### G) "crop_pc2" a 'raster' of principal component 1 in California 
### H) "crs_us" a 'string' of PROJ4 coordinate reference system for WG84
### I) "lrr_raster" a 'raster' of log RR_[coyote+] in "covariate space"
### j) "na_pts" a 'SpatialPoints' of gridded raster cells with "sparse data" in "geographic space" at UTM10N
### K) "naband_reclass" a 'raster' of "no data" in "geographic space" at UTM10N
### L) "Narrow2" a 'SpatialPolygons' of a North Arrow for figures at UTM10N
### M) "nfld" a 'numeric' value of k=25 folds of cross-validation
### N) "obs_dat" a 'data.frame' of observed coyote data with coordinates for "geographic space" and "covariate space" and a flag for  seropositivity
### O) "out" a 'list' object of the output from an envi::lrren model
### P) "out_univar" a 'data.frame' of log RR_[coyote+], significance levels, climate data, and elevation in "covariate space," includes a flag for outside of inner polygon or areas with "sparse data"
### Q) "predict_risk_reclass" a 'raster' of log RR_[coyote+] in "geographic space" at UTM10N
### R) "reclass_tol" a 'raster' of log RR_[coyote+] significant levels at two-tailed alpha levels in "geographic space" at UTM10N
source("code/Preparation.R") 

##################
# POSTPROCESSING #
##################

# Color Selection
plot.cols <- c("gold", "blue3", "cornflowerblue", "grey80", "firebrick1", "firebrick4")

############
# FIGURE 3 #
############

f <- 4 # Graphical expansion factor

grDevices::png(file = "figures/Figure3.png", width = 400*f, height = 480*f)
graphics::par(family = "LM Roman 10", mgp = c(0, 1, 0), mar = c(11.275, 1, 1, 1) + 0.1)
raster::image(reclass_tol,
              col = plot.cols[-1],
              xlab = "",
              ylab = "", 
              axes = F)
graphics::legend(raster::extent(ca_buffer_proj)[1] + 650000,
                 raster::extent(ca_buffer_proj)[3] + 867000,
                 bty = "n",
                 title = "p-value",
                 legend = c(expression(""<"0.005"), "0.005-0.024", "0.025-0.975",
                            "0.976-0.995", expression("">"0.995")),
                 pch = 15,
                 col = rev(plot.cols[-1]),
                 ncol = 1,
                 cex = 1*f)
raster::image(naband_reclass, col = plot.cols[1], add = TRUE)
sp::plot(na_pts, add = TRUE, pch = 4, cex = 0.2*f, col = "black")
sp::plot(CA_proj, add = TRUE, lwd = 1*f)
sp::plot(Narrow2, add = TRUE, col = "black")
raster::scalebar(d = 200000, # distance in km
                 xy = c(raster::extent(ca_buffer_proj)[1] + 100000, raster::extent(ca_buffer_proj)[3] + 20000),
                 type = "bar", 
                 divs = 2, 
                 below = "km", 
                 lonlat = FALSE,
                 label = c(0, 100, 200), 
                 lwd = 1*f,
                 cex = 0.5*f)
graphics::legend(x = raster::extent(ca_buffer_proj)[1] + 24000,
                 y = raster::extent(ca_buffer_proj)[3] + 260000,
                 legend = c("sparse data", "no data", "state border"),
                 bty = "n",
                 #bg = "grey80",
                 lty = c(NA, NA, 1),
                 lwd = c(NA, NA, 1*f),
                 pch = c(4, 15, NA),
                 col = c("black", plot.cols[1], "black"),
                 cex = 1*f)
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
