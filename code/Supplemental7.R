# ----------------------------------------------------------------------------------------------- #
# Manuscript Supplemental Figure 7
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

# Step 1: You must download the elevation BIL zipfile at 4km resolution from the PRISM data portal https://www.prism.oregonstate.edu/normals/
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

# Restrict inference to within the inner polygon or 'extent of coyote data' (i.e., more than 'sparse data')
conserved_univar <- out_univar[out_univar$outside == FALSE, ]

# --------------------- #
# SUPPLEMENTAL FIGURE 7 #
# --------------------- #

f <- 2.5 # Graphical expansion factor

png(file = file.path('figures', 'SupplementalFigure7.png'), width = 6*f, height = 7*f, units = 'in', res = 200*f)
layout(matrix(c(1,2,3,4,5,6,7,8,9,9), ncol = 2, byrow = TRUE), heights = c(0.23,0.23,0.23,0.23,0.08))
par(pty = 'm', oma = c(0, 0, 0, 0), mar = c(5.1, 6.1, 1.1, 2.1), family = 'LM Roman 10')
# Precipitation
plot.gam(
  gam(pval ~ s(ppt), data = conserved_univar),
  residuals = FALSE,
  all.terms = FALSE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'precipitation (millimeters)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(ppt), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Maximum Temperature
plot.gam(
  gam(pval ~ s(tmax), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'maximum temperature (degrees Celsius)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(tmax), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Mean Temperature
plot.gam(
  gam(pval ~ s(tmean), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'mean temperature (degrees Celsius)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(tmean), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Minimum Temperature
plot.gam(
  gam(pval ~ s(tmin), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'minimum temperature (degrees Celsius)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(tmin),data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Dew Point Temperature
plot.gam(
  gam(pval ~ s(tdmean), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'dew point temperature (degrees Celsius)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(tdmean), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Maximum Vapor Pressure Deficit
plot.gam(
  gam(pval ~ s(vpdmax), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'maximum vapor pressure deficit (hectopascal)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(vpdmax), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Maximum Vapor Pressure Deficit
plot.gam(
  gam(pval ~ s(vpdmin), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'minimum vapor pressure deficit (hectopascal)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(vpdmin), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)
# Elevation
plot.gam(
  gam(pval ~ s(elev), data = conserved_univar),
  residuals = FALSE,
  all.terms = TRUE,
  shade = TRUE,
  col = 'black',
  shade.col = 'grey80',
  xlab = 'elevation (meters)',
  ylab = 'p-value',
  select = 1,
  shift = coef(gam(pval ~ s(elev), data = conserved_univar))[1],
  ylim = c(-0.1, 1.1),
  cex = 1*f,
  cex.axis = 0.8*f,
  cex.lab = 1*f
)
abline(h = 0.025, col = 'black', lwd = 1*f, lty = 2)
abline(h = 0.975, col = 'black', lwd = 1*f, lty = 2)

plot.new()
legend(
  x = 'top',
  horiz = TRUE,
  inset = 0,
  legend = c('two-tailed 0.05 alpha level (reference)',
             'univariate generalized additive model',
             '95% confidence interval'),
  lty = c(2, 1, NA),
  pch = c(NA, NA, 15),
  col = c('black', 'black', 'grey80'),
  lwd = 1*f,
  cex = 0.8*f,
  bty = 'n'
)
dev.off()

# ----------------------------------------- END OF CODE ----------------------------------------- #
