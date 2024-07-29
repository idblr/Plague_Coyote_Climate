# ----------------------------------------------------------------------------------------------- #
# Manuscript Supplemental Figure 2
# ----------------------------------------------------------------------------------------------- #
# 
# Created by: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Created on: 2022-05-20
#
# Most recently modified by: @idblr
# Most recently modified on: 2024-07-01
#
# Notes:
# A) See pre-steps to prepare for model run
# ----------------------------------------------------------------------------------------------- #

# ----------- #
# PREPARATION #
# ----------- #

# Step 1: You must download the elevation BIL zipfile at 4-km resolution from the PRISM data portal https://www.prism.oregonstate.edu/normals/
# Step 2: Save the zipfile to the data directory in this repository
# Step 3: Set your own data paths to data in 'Paths.R' file

# Use the code found in 'Preparation.R' and 'Paths.R' files
## Loads sixteen objects
### A) 'ca' a large 'SpatVector' of California counties
### B) 'ca_buffer' a small 'SpatVector' of California state boundary geographically buffered a little larger
### C) 'ca_buffer_proj' a small 'SpatVector' of California state boundary geographically buffered a little larger and projected to UTM10N
### D) 'CA_proj' a small 'SpatVector' of California state boundary projected to UTM 10N
### E) 'cdph_coyote_sp' a large 'sf' of CDPH coyote plague data
### F) 'mask_pc1' a 'SpatRaster' of principal component 1 in California
### G) 'mask_pc2' a 'SpatRaster' of principal component 2 in California 
### H) 'crs_us' a 'string' of PROJ4 coordinate reference system for WG84
### I) 'lrr_raster' a 'SpatRaster ' of log RR_[coyote+] in 'covariate space'
### J) 'Narrow2' a 'sf' of a North Arrow for figures at UTM10N
### K) 'nfld' a 'numeric' value of k=25 folds of cross-validation
### L) 'obs_dat' a 'data.frame' of observed coyote data with coordinates for 'geographic space' and 'covariate space' and a flag for  seropositivity
### M) 'out' a 'list' of the output from an envi::lrren model
### N) 'out_univar' a 'data.frame' of log RR_[coyote+], significance levels, climate data, and elevation in 'covariate space,' includes a flag for outside of inner polygon or areas with 'sparse data'
### O) 'predict_risk_reclass' a 'SpatRaster' of log RR_[coyote+] in 'geographic space' at UTM10N
### P) 'reclass_tol' a 'SpatRaster' of log RR_[coyote+] significant levels at two-tailed alpha levels in 'geographic space' at UTM10N

source(file.path('code', 'Preparation.R'))

# -------------- #
# POSTPROCESSING #
# -------------- #

# Color Palettes
palA <- rev(brewer.pal(n = 9, name = 'PuOr'))
palB <- brewer.pal(n = 9, name = 'BrBG')

# ---------------------- #
# SUPPLEMENTAL FIGURE 2A #
# ---------------------- #

# Custom Color Palette
midpoint <- 0
tmp <- proj_pc1
lowerhalf <- length(tmp[tmp < midpoint & !is.na(tmp)])
upperhalf <- length(tmp[tmp > midpoint & !is.na(tmp)])
min_absolute_value <- min(tmp[is.finite(tmp)], na.rm = TRUE)
max_absolute_value <- max(tmp[is.finite(tmp)], na.rm = TRUE)
rc1 <- (colorRampPalette(colors = c(palA[1], palA[5]), space = 'Lab'))(lowerhalf)
rc2 <- (colorRampPalette(colors = c(palA[5], palA[9]), space = 'Lab'))(upperhalf)
rampcols <- c(rc1, rc2)
rb1 <- seq(min_absolute_value, midpoint, length.out = lowerhalf + 1)
rb2 <- seq(midpoint, max_absolute_value, length.out = upperhalf + 1)[-1]
rampbreaks <- c(rb1, rb2)
rbr <- max_absolute_value - min_absolute_value
rbt <- rbr/4
rbs <- seq(min_absolute_value, max_absolute_value, rbt)
rbm <- which.min(abs(rbs - midpoint))
rbs[rbm] <- midpoint
rbl <- round(rbs, digits = 2)

f <- 4 # graphical expansion factor

png(file = file.path('figures', 'SupplementalFigure2A.png'), width = 400*f, height = 480*f)
par(family = 'LM Roman 10', mgp = c(0, 1, 0), mar = c(5, 1, 1, 1) + 0.1)
image.plot(
  raster(proj_pc1),
  col = rampcols,
  breaks = rampbreaks,
  xlab = '', ylab = '',
  axes = FALSE,
  legend.shrink = 0.5,
  legend.mar = 5.1,
  horizontal = TRUE,
  legend.args = list(text = 'principal component coefficient', line = 0.5*f, cex = 1*f),
  axis.args = list(at = rbs, labels = rbl, cex.axis = 1*f, mgp = c(3, 0.75, 0)*f)
)
plot(as(CA_proj, 'Spatial'), add = T, lwd = 1*f)
title('(a)', line = -1*f, cex.main = 2*f)
plot(Narrow2, add = TRUE, col = 'black')
scalebar(
  d = 200000, # distance in km
  xy = c(ext(ca_buffer_proj)[1] + 100000, ext(ca_buffer_proj)[3] + 20000),
  type = 'bar', 
  divs = 2, 
  below = 'km', 
  lonlat = FALSE,
  label = c(0, 100, 200), 
  lwd = 1*f, 
  cex = 0.5*f
)
legend(
  x = ext(ca_buffer_proj)[1] + 5000,
  y = ext(ca_buffer_proj)[3] + 200000,
  bty = 'n',
  lty = 1,
  lwd = 1*f,
  cex = 1*f,
  col = 'black',
  legend = 'state border'
)
dev.off()

# ---------------------- #
# SUPPLEMENTAL FIGURE 2B #
# ---------------------- #

# Custom Color Palette
midpoint <- 0
tmp <- proj_pc2
lowerhalf <- length(tmp[tmp < midpoint & !is.na(tmp)])
upperhalf <- length(tmp[tmp > midpoint & !is.na(tmp)])
min_absolute_value <- min(tmp[is.finite(tmp)], na.rm = TRUE)
max_absolute_value <- max(tmp[is.finite(tmp)], na.rm = TRUE)
rc1 <- (colorRampPalette(colors = c(palB[1], palB[5]), space = 'Lab'))(lowerhalf)
rc2 <- (colorRampPalette(colors = c(palB[5], palB[9]), space = 'Lab'))(upperhalf)
rampcols <- c(rc1, rc2)
rb1 <- seq(min_absolute_value, midpoint, length.out = lowerhalf + 1)
rb2 <- seq(midpoint, max_absolute_value, length.out = upperhalf + 1)[-1]
rampbreaks <- c(rb1, rb2)
rbr <- max_absolute_value - min_absolute_value
rbt <- rbr/4
rbs <- seq(min_absolute_value, max_absolute_value, rbt)
rbm <- which.min(abs(rbs - midpoint))
rbs[rbm] <- midpoint
rbl <- round(rbs, digits = 2)

png(file = file.path('figures', 'SupplementalFigure2B.png'), width = 400*f, height = 480*f)
par(family = 'LM Roman 10', mgp = c(0, 1, 0), mar = c(5, 1, 1, 1) + 0.1)
image.plot(
  raster(proj_pc2),
  col = rampcols,
  breaks = rampbreaks,
  xlab = '', ylab = '',
  axes = FALSE,
  legend.shrink = 0.5,
  legend.mar = 5.1,
  horizontal = TRUE,
  legend.args = list(text = 'principal component coefficient', line = 0.5*f, cex = 1*f),
  axis.args = list(at = rbs, labels = rbl, cex.axis = 1*f, mgp = c(3, 0.75, 0)*f)
)
plot(as(CA_proj, 'Spatial'), add = T, lwd = 1*f)
title('(b)', line = -1*f, cex.main = 2*f)
plot(Narrow2, add = TRUE, col = 'black')
scalebar(
  d = 200000, # distance in km
  xy = c(ext(ca_buffer_proj)[1] + 100000, ext(ca_buffer_proj)[3] + 20000),
  type = 'bar', 
  divs = 2, 
  below = 'km', 
  lonlat = FALSE,
  label = c(0, 100, 200), 
  lwd = 1*f, 
  cex = 0.5*f
)
legend(
  x = ext(ca_buffer_proj)[1] + 5000,
  y = ext(ca_buffer_proj)[3] + 200000,
  bty = 'n',
  lty = 1,
  lwd = 1*f,
  cex = 1*f,
  col = 'black',
  legend = 'state border'
)
dev.off()

# ----------------------------------------- END OF CODE ----------------------------------------- #
