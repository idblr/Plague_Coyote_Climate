# ----------------------------------------------------------------- #
# Manuscript Figure 2
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

# Color Selection
plot.cols <- c("gold", "blue3", "cornflowerblue", "grey80", "firebrick1", "firebrick4")

# Custom Color Palette
upperhalf <- length(predict_risk_reclass@data@values[predict_risk_reclass@data@values > 0 & !is.na(predict_risk_reclass@data@values)])
lowerhalf <- length(predict_risk_reclass@data@values[predict_risk_reclass@data@values < 0 & !is.na(predict_risk_reclass@data@values)])
max_absolute_value <- max(predict_risk_reclass@data@values[is.finite(predict_risk_reclass@data@values)]) #what is the maximum absolute value of raster?
min_absolute_value <- min(predict_risk_reclass@data@values[is.finite(predict_risk_reclass@data@values)]) #what is the maximum absolute value of raster?
Thresh <- 0
## Make vector of colors for values below threshold
rc1 <- grDevices::colorRampPalette(colors = c(plot.cols[2], plot.cols[4]), space = "Lab")(lowerhalf)
## Make vector of colors for values above threshold
rc2 <- grDevices::colorRampPalette(colors = c(plot.cols[4], plot.cols[6]), space = "Lab")(upperhalf)
rampcols <- c(rc1, rc2)

# Custom Color Breaks
rb1 <- seq(min_absolute_value, Thresh, length.out = lowerhalf+1)
rb2 <- seq(Thresh, max_absolute_value, length.out = upperhalf+1)[-1]
rampbreaks <- c(rb1, rb2)

# Custom Legend
ticks <- c(predict_risk_reclass@data@min, predict_risk_reclass@data@min/2, 0, predict_risk_reclass@data@max/2, predict_risk_reclass@data@max)
tick_labels <- c(expression(""<="-3.12"), "-1.56", "0", "1.56", "3.12")

# Subplot
CA_ref <- png::readPNG("figures/subplot/California_Regions.png")
# resolution 2550×3300

# https://stackoverflow.com/a/56018973/6784787
addImg <- function(
    obj, # an image file imported as an array (e.g. png::readPNG, jpeg::readJPEG)
    x = NULL, # mid x coordinate for image
    y = NULL, # mid y coordinate for image
    width = NULL, # width of image (in x coordinate units)
    interpolate = TRUE, # (passed to graphics::rasterImage) A logical vector (or scalar) indicating whether to apply linear interpolation to the image when drawing. 
    ...){
  if(is.null(x) | is.null(y) | is.null(width)){stop("Must provide args 'x', 'y', and 'width'")}
  USR <- par()$usr # A vector of the form c(x1, x2, y1, y2) giving the extremes of the user coordinates of the plotting region
  PIN <- par()$pin # The current plot dimensions, (width, height), in inches
  DIM <- dim(obj) # number of x-y pixels for the image
  ARp <- DIM[1]/DIM[2] # pixel aspect ratio (y/x)
  WIDi <- width/(USR[2]-USR[1])*PIN[1] # convert width units to inches
  HEIi <- WIDi * ARp # height in inches
  HEIu <- HEIi/PIN[2]*(USR[4]-USR[3]) # height in units
  rasterImage(image = obj,
              xleft = x-(width/2), xright = x+(width/2),
              ybottom = y-(HEIu/2), ytop = y+(HEIu/2), 
              interpolate = interpolate, ...)
}

############
# FIGURE 2 #
############

f <- 4 # Graphical expansion factor

grDevices::png(file = "figures/Figure2.png", width = 400*f, height = 480*f)
graphics::par(family = "LM Roman 10", mgp = c(0, 1, 0), mar = c(5, 1, 1, 1) + 0.1)
fields::image.plot(predict_risk_reclass,
                   col = rampcols,
                   breaks = rampbreaks,
                   xlab = "", ylab = "",
                   axes = F,
                   legend.width = 1.2,
                   legend.shrink = 0.5,
                   legend.mar = 5.1,
                   horizontal = T,
                   legend.args = list(text = expression("log"~hat("RR")["coyote+"]), line = 0.5*f, cex = 1*f),
                   axis.args = list(at = ticks, labels = tick_labels, cex.axis = 1*f, mgp = c(3, 0.75, 0)*f))
raster::image(naband_reclass, col = plot.cols[1], add = TRUE)
sp::plot(na_pts, add = TRUE, pch = 4, cex = 0.2*f, col = "black")
sp::plot(CA_proj, add = TRUE, lwd = 1*f)
sp::plot(Narrow2, add = TRUE, col = "black")
raster::scalebar(d = 200000, # distance in km
                 xy = c(raster::extent(ca_buffer_proj)[1]+100000, raster::extent(ca_buffer_proj)[3]+20000),
                 type = "bar", 
                 divs = 2, 
                 below = "km", 
                 lonlat = FALSE,
                 label = c(0, 100, 200), 
                 lwd = 1*f, 
                 cex = 0.5*f)
graphics::legend(x = raster::extent(ca_buffer_proj)[1]+24000,
                 y = raster::extent(ca_buffer_proj)[3]+260000,
                 legend = c("sparse data", "no data", "state border"),
                 bty = "n",
                 #bg = "grey80",
                 lty = c(NA, NA, 1),
                 lwd = c(NA, NA, 1*f),
                 pch = c(4, 15, NA),
                 col = c("black", plot.cols[1], "black"),
                 cex = 1*f)
# add miniplot in upper right corner of plot 
addImg(CA_ref, 1076500, 4360000, width = 450000, angle = 1)
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #\
