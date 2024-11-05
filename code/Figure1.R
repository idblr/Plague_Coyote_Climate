# --------------------------------------------------------------------------------- #
# Manuscript Figure 1
# --------------------------------------------------------------------------------- #
# 
# Created by: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Created on: 2022-05-20
#
# Most recently modified by: @idblr
# Most recently modified on: 2024-08-06
#
# Notes:
# A) See pre-steps to prepare for model run
# --------------------------------------------------------------------------------- #

# ----------- #
# PREPARATION #
# ----------- #

# Step 1: You must download the elevation BIL file at 4-km resolution from the 
#         PRISM data portal https://www.prism.oregonstate.edu/normals/
# Step 2: Save the BIL file to the data directory in this repository
# Step 3: Set your own file paths to the data in the 'Paths.R' file

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

# Color Selection
plot.cols <- c(
  'yellow', 'blue3', 'cornflowerblue', 'grey80', 'firebrick1', 'firebrick4'
)

# Custom Color Palette
rho_hat_values <- as.vector(lrr_raster)
upperhalf <- length(rho_hat_values[rho_hat_values > 0 & !is.na(rho_hat_values)])
lowerhalf <- length(rho_hat_values[rho_hat_values < 0 & !is.na(rho_hat_values)])
nhalf <- length(rho_hat_values[!is.na(rho_hat_values)])/2
max_absolute_value <- max(rho_hat_values[is.finite(rho_hat_values)], na.rm = TRUE)
min_absolute_value <- min(rho_hat_values[is.finite(rho_hat_values)], na.rm = TRUE)
Thresh <- 0
## Make vector of colors for values below threshold
rc1 <- colorRampPalette(
  colors = c(plot.cols[2], plot.cols[4]), space = 'Lab'
)(lowerhalf)
## Make vector of colors for values above threshold
rc2 <- colorRampPalette(
  colors = c(plot.cols[4], plot.cols[6]), space = 'Lab'
)(upperhalf)
rampcols <- c(rc1, rc2)

# Custom Color Breaks
rb1 <- seq(min_absolute_value, Thresh, length.out = lowerhalf + 1)
rb2 <- seq(Thresh, max_absolute_value, length.out = upperhalf + 1)[-1]
rampbreaks <- c(rb1, rb2)

# -------- #
# FIGURE 1 #
# -------- #

f <- 2 # Graphical expansion factor

png(
  file = file.path('figures', 'Figure1.png'), 
  width = 5*f, 
  height = 5*f, 
  units = 'in', 
  res = 200*f
)
par(
  oma = c(0, 0, 0, 1), 
  mar = c(9.1, 6.1, 4.1, 4.1), 
  pty = 'm', 
  family = 'LM Roman 10'
)
image.plot(
  lrr_raster,
  col = rampcols,
  breaks = rampbreaks,
  xlim = c(-1, 1),
  ylim = c(-1.1, 0.5),
  xlab = 'principal component 1',
  ylab = 'principal component 2',
  axes = TRUE,
  cex = 1*f,
  cex.axis = 1*f,
  cex.lab = 1.1*f,
  legend.shrink = 0.5,
  horizontal = TRUE,
  legend.args = list(
    text = expression('log'~hat('RR')['coyote+']), 
    line = 0.5*f, 
    cex = 1*f
  ),
  axis.args = list(
    labels = c(
      expression(''<='-3.06'), '-1.53', '0', '1.53',
      paste(round(max(out$out$obs$rr$v, na.rm = TRUE), digits = 2))
    ),
    at = c(minmax(lrr_raster)[1], -1.53, 0, 1.53, minmax(lrr_raster)[2]),
    cex.axis = 1*f
  )
)
contour(
  x = out$out$obs$P$xcol,
  y = out$out$obs$P$yrow,
  z = t(out$out$obs$P$v),
  add = TRUE,
  levels = c(0.005, 0.025, 0.5, 0.975, 0.995),
  drawlabels = F,
  col = 'black',
  lwd = c(1, 2, 3, 2, 1)*f,
  lty = c(2, 2, 1, 3, 3)
)
plot(out$out$inner_poly, lty = 2, lwd = 1*f, border = 'gold', add = TRUE)
plot(out$out$outer_poly, lty = 1, lwd = 1*f, border = 'gold', add = TRUE)
legend(
  x = 'bottomleft',
  inset = 0,
  ncol = 1,
  legend = c(
    expression('p-value'<='0.005'),
    expression('p-value'<='0.025'),
    expression('p-value'=='0.500'),
    expression('p-value'>='0.975'),
    expression('p-value'>='0.995'),
    'extent of coyote data',
    'extent of climate data'
  ),
  col = c('black', 'black', 'black', 'black', 'black', 'gold', 'gold'),
  lwd = c(1, 2, 3, 2, 1, 1, 1)*f,
  lty = c(2, 2, 1, 3, 3, 2, 1),
  bty = 'n',
  cex = 0.67*f
)
dev.off()

# ---------------------------------- END OF CODE ---------------------------------- #
