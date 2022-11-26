# ----------------------------------------------------------------- #
# Manuscript Figure 1
# 
# Author: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Date created: May 20, 2022
#
# Modified by: @idblr
# Modified on: November 22, 2022
#
# Notes:
# A) See pre-steps to prepare for model run
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
plot.cols <- c("yellow", "blue3", "cornflowerblue", "grey80", "firebrick1", "firebrick4")

# Custom Color Palette
rho_hat_values <- as.vector(lrr_raster)
upperhalf <- length(rho_hat_values[rho_hat_values > 0 & !is.na(rho_hat_values)])
lowerhalf <- length(rho_hat_values[rho_hat_values < 0 & !is.na(rho_hat_values)])
nhalf <- length(rho_hat_values[!is.na(rho_hat_values)])/2
max_absolute_value <- max(rho_hat_values[is.finite(rho_hat_values)], na.rm = T) #what is the maximum absolute value of raster?
min_absolute_value <- min(rho_hat_values[is.finite(rho_hat_values)], na.rm = T) #what is the maximum absolute value of raster?
Thresh <- 0
## Make vector of colors for values below threshold
rc1 <- grDevices::colorRampPalette(colors = c(plot.cols[2], plot.cols[4]), space = "Lab")(lowerhalf)
## Make vector of colors for values above threshold
rc2 <- grDevices::colorRampPalette(colors = c(plot.cols[4], plot.cols[6]), space = "Lab")(upperhalf)
rampcols <- c(rc1, rc2)

# Custom Color Breaks
rb1 <- seq(min_absolute_value, Thresh, length.out = lowerhalf + 1)
rb2 <- seq(Thresh, max_absolute_value, length.out = upperhalf + 1)[-1]
rampbreaks <- c(rb1, rb2)

############
# FIGURE 1 #
############

f <- 2 # Graphical expansion factor

grDevices::png(file = "figures/Figure1.png", width = 500*f, height = 500*f)
graphics::par(oma = c(0, 0, 0, 1), mar = c(9.1, 6.1, 4.1, 4.1), pty = "m", family = "LM Roman 10")
fields::image.plot(lrr_raster,
                   col = rampcols,
                   breaks = rampbreaks,
                   xlim = c(-1, 1),
                   ylim = c(-1.1, 0.5),
                   xlab = "principal component 1",
                   ylab = "principal component 2",
                   axes = T,
                   cex = 1*f,
                   cex.axis = 1*f,
                   cex.lab = 1.1*f,
                   legend.shrink = 0.5,
                   horizontal = TRUE,
                   legend.args = list(text = expression("log"~hat("RR")["coyote+"]), line = 0.5*f, cex = 1*f),
                   axis.args = list(labels = c(expression(""<="-3.12"), "-1.56", "0", "1.56",
                                               paste(round(max(out$out$obs$rr$v, na.rm=T),
                                                           digits = 2))),
                                    at = c(min(values(lrr_raster), na.rm = TRUE),
                                           -1.56, 0, 1.56,
                                           max(values(lrr_raster), na.rm = TRUE)),
                                    cex.axis = 1*f))
graphics::contour(x = out$out$obs$P$xcol,
                  y = out$out$obs$P$yrow,
                  z = t(out$out$obs$P$v),
                  add = TRUE,
                  levels = c(0.005, 0.025, 0.5, 0.975, 0.995),
                  drawlabels = F,
                  col = "black",
                  lwd = c(1,2,3,2,1)*f,
                  lty = c(2,2,1,3,3))
graphics::polygon(out$out$inner_poly, lty = 2, lwd = 1*f, border = "gold")
graphics::polygon(out$out$outer_poly, lty = 1, lwd = 1*f, border = "gold")
graphics::legend(x= "bottomleft",
                 inset = 0,
                 ncol = 1,
                 legend=c(expression("p-value"<="0.005"),
                          expression("p-value"<="0.025"),
                          expression("p-value"=="0.500"),
                          expression("p-value">="0.975"),
                          expression("p-value">="0.995"),
                          "extent of coyote data",
                          "extent of climate data"),
                 col = c("black", "black", "black", "black", "black", "gold", "gold"),
                 lwd = c(1,2,3,2,1,1,1)*f,
                 lty = c(2,2,1,3,3,2,1),
                 bty = "n",
                 cex = 1*f)
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
