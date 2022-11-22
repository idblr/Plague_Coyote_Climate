# ----------------------------------------------------------------- #
# Manuscript Supplemental Figure 6
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

# Restrict inference to within the inner polygon or "extent of coyote data" (i.e., more than "sparse data")
conserved_univar <- out_univar[out_univar$outside == FALSE, ]

#########################
# SUPPLEMENTAL FIGURE 6 #
#########################

f <- 2.5 # Graphical expansion factor

grDevices::png(file = "figures/SupplementalFigure6.png", width = 600*f, height = 550*f)
graphics::layout(matrix(c(1,2,3,4,5,6,7,8,9,9), ncol = 2, byrow = TRUE), heights = c(0.23,0.23,0.23,0.23,0.08))
graphics::par(pty = "m", oma = c(0, 0, 0, 0), mar = c(5.1, 6.1, 1.1, 2.1), family = "LM Roman 10")
# Precipitation
mgcv::plot.gam(mgcv::gam(rr ~ s(ppt), data = conserved_univar),
               residuals = FALSE,
               all.terms = FALSE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "precipitation (millimeters)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(ppt), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr) * 1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Maximum Temperature
mgcv::plot.gam(mgcv::gam(rr ~ s(tmax), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "maximum temperature (degrees Celsius)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(tmax), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Mean Temperature
mgcv::plot.gam(mgcv::gam(rr ~ s(tmean), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "mean temperature (degrees Celsius)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(tmean), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Minimum Temperature
mgcv::plot.gam(mgcv::gam(rr ~ s(tmin), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "minimum temperature (degrees Celsius)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(tmin),data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Dew Point Temperature
mgcv::plot.gam(mgcv::gam(rr ~ s(tdmean), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "dew point temperature (degrees Celsius)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(tdmean), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Maximum Vapor Pressure Deficit
mgcv::plot.gam(mgcv::gam(rr ~ s(vpdmax), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "maximum vapor pressure deficit (hectopascal)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(vpdmax), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Maximum Vapor Pressure Deficit
mgcv::plot.gam(mgcv::gam(rr ~ s(vpdmin), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "minimum vapor pressure deficit (hectopascal)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(vpdmin), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)
# Elevation
mgcv::plot.gam(mgcv::gam(rr ~ s(elev), data = conserved_univar),
               residuals = FALSE,
               all.terms = TRUE,
               shade = TRUE,
               col = "black",
               shade.col = "grey80",
               xlab = "elevation (meters)",
               ylab = expression("log"~hat("RR")["coyote+"]),
               select = 1,
               shift = stats::coef(mgcv::gam(rr ~ s(elev), data = conserved_univar))[1],
               ylim = c(-8, max(conserved_univar$rr)*1.5),
               cex = 1*f,
               cex.axis = 1*f,
               cex.lab = 1*f)
graphics::abline(h = 0, col = "black", lwd = 1*f, lty = 2)

graphics::plot.new()
graphics::legend(x = "top",
                 horiz = TRUE,
                 inset = 0,
                 legend = c(expression("null log"~hat("RR")["coyote+"]~"(reference)"),
                            "univariate generalized additive model",
                            "95% confidence interval"),
                 lty = c(2, 1, NA),
                 pch = c(NA, NA, 15),
                 col = c("black", "black", "grey80"),
                 lwd = 1*f,
                 cex = 1*f,
                 bty = "n")
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
