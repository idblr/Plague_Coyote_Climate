# ----------------------------------------------------------------- #
# Manuscript Supplemental Figure 2
# 
# Author: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Date created: May 20, 2022
#
# Modified by: @idblr
# Modified on: May 21, 2022
#
# Notes:
# A) See pre-steps to prepare for model run
# ----------------------------------------------------------------- #

###############
# PREPARATION #
###############

# Step 1: You must download the elevation BIL zipfile at 4km resolution from the PRISM data portal https://www.prism.oregonstate.edu/normals/
# Step 2: Save the zipfile to the data directory in this repository
# Step 3: Set your own data paths to data in 'Paths_public.R' file
# Step 4: Change the path in the `source()` call on line 32 in 'Preparation.R' file from "Paths_private.R" to "Paths.R"

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

# Color Palettes
palA <- rev(RColorBrewer::brewer.pal(n = 9, name = "PuOr"))
palB <- RColorBrewer::brewer.pal(n = 9, name = "BrBG")

##########################
# SUPPLEMENTAL FIGURE 2A #
##########################

# Custom Color Palette
midpoint <- 0
tmp <- crop_pc1
lowerhalf <- length(tmp[tmp < midpoint & !is.na(tmp)])
upperhalf <- length(tmp[tmp > midpoint & !is.na(tmp)])
min_absolute_value <- min(tmp[is.finite(tmp)], na.rm = TRUE)
max_absolute_value <- max(tmp[is.finite(tmp)], na.rm = TRUE)
rc1 <- (grDevices::colorRampPalette(colors = c(palA[1], 
                                               palA[5]), space = "Lab"))(lowerhalf)
rc2 <- (grDevices::colorRampPalette(colors = c(palA[5], 
                                               palA[9]), space = "Lab"))(upperhalf)
rampcols <- c(rc1, rc2)
rb1 <- seq(min_absolute_value, midpoint, length.out = lowerhalf + 
             1)
rb2 <- seq(midpoint, max_absolute_value, length.out = upperhalf + 
             1)[-1]
rampbreaks <- c(rb1, rb2)
rbr <- max_absolute_value - min_absolute_value
rbt <- rbr/4
rbs <- seq(min_absolute_value, max_absolute_value, rbt)
rbm <- which.min(abs(rbs - midpoint))
rbs[rbm] <- midpoint
rbl <- round(rbs, digits = 2)

f <- 4 # graphical expansion factor

grDevices::png(file = "figures/SupplementalFigure2A.png", width = 400*f, height = 480*f)
graphics::par(family = "LM Roman 10", mgp = c(0, 1, 0), mar = c(5, 1, 1, 1) + 0.1)
fields::image.plot(crop_pc1,
                   col = rampcols,
                   breaks = rampbreaks,
                   xlab = "", ylab = "",
                   axes = FALSE,
                   legend.shrink = 0.5,
                   legend.mar = 5.1,
                   horizontal = TRUE,
                   legend.args = list(text = "principal component coefficient", line = 0.5*f, cex = 1*f),
                   axis.args = list(at = rbs, labels = rbl, cex.axis = 1*f, mgp = c(3, 0.75, 0)*f))
sp::plot(CA_proj, add = T, lwd = 1*f)
graphics::title("(a)", line = -1*f, cex.main = 2*f)
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
graphics::legend(x = raster::extent(ca_buffer_proj)[1] + 5000,
                 y = raster::extent(ca_buffer_proj)[3] + 200000,
                 bty = "n",
                 lty = 1,
                 lwd = 1*f,
                 cex = 1*f,
                 col = "black",
                 legend = "state border")
grDevices::dev.off()

##########################
# SUPPLEMENTAL FIGURE 2B #
##########################

# Custom Color Palette
midpoint <- 0
tmp <- crop_pc2
lowerhalf <- length(tmp[tmp < midpoint & !is.na(tmp)])
upperhalf <- length(tmp[tmp > midpoint & !is.na(tmp)])
min_absolute_value <- min(tmp[is.finite(tmp)], na.rm = TRUE)
max_absolute_value <- max(tmp[is.finite(tmp)], na.rm = TRUE)
rc1 <- (grDevices::colorRampPalette(colors = c(palB[1], 
                                               palB[5]), space = "Lab"))(lowerhalf)
rc2 <- (grDevices::colorRampPalette(colors = c(palB[5], 
                                               palB[9]), space = "Lab"))(upperhalf)
rampcols <- c(rc1, rc2)
rb1 <- seq(min_absolute_value, midpoint, length.out = lowerhalf + 
             1)
rb2 <- seq(midpoint, max_absolute_value, length.out = upperhalf + 
             1)[-1]
rampbreaks <- c(rb1, rb2)
rbr <- max_absolute_value - min_absolute_value
rbt <- rbr/4
rbs <- seq(min_absolute_value, max_absolute_value, rbt)
rbm <- which.min(abs(rbs - midpoint))
rbs[rbm] <- midpoint
rbl <- round(rbs, digits = 2)

grDevices::png(file = "figures/SupplementalFigure2B.png", width = 400*f, height = 480*f)
graphics::par(family = "LM Roman 10", mgp = c(0, 1, 0), mar = c(5, 1, 1, 1) + 0.1)
fields::image.plot(crop_pc2,
                   col = rampcols,
                   breaks = rampbreaks,
                   xlab = "", ylab = "",
                   axes = FALSE,
                   legend.shrink = 0.5,
                   legend.mar = 5.1,
                   horizontal = TRUE,
                   legend.args = list(text = "principal component coefficient", line = 0.5*f, cex = 1*f),
                   axis.args = list(at = rbs, labels = rbl, cex.axis = 1*f, mgp = c(3, 0.75, 0)*f))
sp::plot(CA_proj, add = T, lwd = 1*f)
graphics::title("(b)", line = -1*f, cex.main = 2*f)
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
graphics::legend(x = raster::extent(ca_buffer_proj)[1] + 5000,
                 y = raster::extent(ca_buffer_proj)[3] + 200000,
                 bty = "n",
                 lty = 1,
                 lwd = 1*f,
                 cex = 1*f,
                 col = "black",
                 legend = "state border")
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
