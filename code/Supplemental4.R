# ----------------------------------------------------------------- #
# Manuscript Supplemental Figure 4
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

case_locs <- subset(obs_dat, obs_dat$mark == 1)
control_locs <- subset(obs_dat, obs_dat$mark == 0)
names_obs <- names(obs_dat)
names_obs[5:6] <- c("principal component 1", "principal component 2")

x_con <- control_locs[ , 5] 
y_con <- control_locs[ , 6] 
x_cas <- case_locs[ , 5] 
y_cas <- case_locs[ , 6] 
p_all <- cbind(c(x_cas,x_con), c(y_cas,y_con))
inner_poly <- cbind(out$out$inner_poly[ , 1],
                    out$out$inner_poly[ , 2])
outer_poly <- cbind(out$out$outer_poly[ , 1],
                    out$out$outer_poly[ , 2])
out_xcol_con <- out$out$obs$g$z$xcol
out_yrow_con <- out$out$obs$g$z$yrow
out_xcol_cas <- out$out$obs$f$z$xcol
out_yrow_cas <- out$out$obs$f$z$yrow

#########################
# SUPPLEMENTAL FIGURE 4 #
#########################

# Visualizing observed kernel densities and density ratio
## Densities of Cases and Controls
f <- 2 # graphical expansion factor
grDevices::png(file = "figures/SupplementalFigure4.png", width = 600*f, height = 500*f)
graphics::layout(matrix(c(1, 2), ncol = 2, byrow = TRUE), heights = 1)
graphics::par(oma = c(0, 0, 0, 0), mar = c(0.1, 5.1, 4.1, 2.1), pty = "s",family = "LM Roman 10")

# Figure 3A
plot(x_cas,
     y_cas,
     xlab = names_obs[5],
     ylab = names_obs[6],
     xlim = c(-1,1),
     ylim = c(-1.1, 0.5),
     type = "n",
     cex = 1*f,
     cex.lab = 1*f,
     cex.axis = 1*f)
graphics::points(x_cas, y_cas, pch = 16, cex = 0.15*f, col = "firebrick4")
graphics::title("(a)", cex.main = 1.1*f)
graphics::contour(x = out_xcol_cas,
                  y = out_yrow_cas,
                  z = t(out$out$obs$f$z$v),
                  add = T,
                  lwd = 1*f,
                  vfont = c("sans serif", "bold"),
                  nlevels = 10,
                  drawlabels = F,
                  col = "black")
graphics::polygon(inner_poly, lty = 2, border = "gold", lwd = 1*f)
graphics::polygon(outer_poly, lty = 1, border = "gold", lwd = 1*f)
graphics::legend(x= "bottomleft",
                 inset = 0,
                 ncol = 1,
                 legend = c("seropositive location", "one bandwidth", "extent of coyote data", "extent of climate data"),
                 col = c("firebrick4", "black", "gold", "gold"),
                 lwd = 1*f,
                 lty = c(NA, 1, 2, 1),
                 pch = c(16, NA, NA, NA),
                 cex = 0.75*f,
                 bty = "n")
# Figure 3B
plot(x_con,
     y_con,
     xlab = names_obs[5],
     ylab = names_obs[6],
     xlim = c(-1, 1),
     ylim = c(-1.1, 0.5),
     type = "n",
     cex = 1*f,
     cex.lab = 1*f,
     cex.axis = 1*f)

graphics::points(x_con, y_con, pch = 16, cex = 0.15*f, col = "blue3")
graphics::title("(b)", cex.main = 1.1*f)
graphics::contour(x = out_xcol_con,
                  y = out_yrow_con,
                  z = t(out$out$obs$g$z$v),
                  add = T,
                  lwd = 1*f,
                  vfont = c("sans serif", "bold"),
                  nlevels = 10,
                  drawlabels = F,
                  col = "black")
graphics::polygon(inner_poly, lty = 2, border = "gold", lwd = 1*f)
graphics::polygon(outer_poly, lty = 1, border = "gold", lwd = 1*f)
graphics::legend(x = "bottomleft",
                 inset = 0,
                 ncol = 1,
                 legend = c("seronegative location", "one bandwidth", "extent of coyote data", "extent of climate data"),
                 col = c("blue3", "black", "gold", "gold"),
                 lwd = 1*f,
                 lty = c(NA, 1, 2, 1),
                 pch = c(16, NA, NA, NA),
                 cex = 0.75*f,
                 bty = "n")
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
