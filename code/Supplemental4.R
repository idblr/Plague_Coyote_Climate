# --------------------------------------------------------------------------------- #
# Manuscript Supplemental Figure 4
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

case_locs <- subset(obs_dat, obs_dat$mark == 1)
control_locs <- subset(obs_dat, obs_dat$mark == 0)
names_obs <- names(obs_dat)
names_obs[5:6] <- c('principal component 1', 'principal component 2')

x_con <- control_locs[ , 5] 
y_con <- control_locs[ , 6] 
x_cas <- case_locs[ , 5] 
y_cas <- case_locs[ , 6] 
p_all <- cbind(c(x_cas,x_con), c(y_cas,y_con))
inner_poly <- out$out$inner_poly
outer_poly <- out$out$outer_poly
out_xcol_con <- out$out$obs$g$z$xcol
out_yrow_con <- out$out$obs$g$z$yrow
out_xcol_cas <- out$out$obs$f$z$xcol
out_yrow_cas <- out$out$obs$f$z$yrow

# --------------------- #
# SUPPLEMENTAL FIGURE 4 #
# --------------------- #

# Visualizing observed kernel densities and density ratio
## Densities of Cases and Controls
f <- 2 # graphical expansion factor
png(
  file = file.path('figures', 'SupplementalFigure4.png'), 
  width = 8*f, 
  height = 5*f, 
  units = 'in', 
  res = 200*f
)
layout(matrix(c(1, 2), ncol = 2, byrow = TRUE), heights = 1)
par(
  oma = c(0, 0, 0, 0), mar = c(0.1, 5.1, 4.1, 2.1), pty = 's',family = 'LM Roman 10'
)

# Supplemental Figure 4A
plot(
  x_cas,
  y_cas,
  xlab = names_obs[5],
  ylab = names_obs[6],
  xlim = c(-1,1),
  ylim = c(-1.1, 0.5),
  type = 'n',
  cex = 1*f,
  cex.lab = 1*f,
  cex.axis = 1*f
)
points(x_cas, y_cas, pch = 16, cex = 0.15*f, col = 'firebrick4')
title('(a)', cex.main = 1.1*f)
contour(
  x = out_xcol_cas,
  y = out_yrow_cas,
  z = t(out$out$obs$f$z$v),
  add = T,
  lwd = 1*f,
  vfont = c('sans serif', 'bold'),
  nlevels = 10,
  drawlabels = F,
  col = 'black'
)
plot(inner_poly, lty = 2, border = 'gold', lwd = 1*f, add = TRUE)
plot(outer_poly, lty = 1, border = 'gold', lwd = 1*f, add = TRUE)
legend(
  x = 'bottomleft',
  inset = 0,
  ncol = 1,
  legend = c(
    'seropositive location', 'one bandwidth', 'extent of coyote data', 
    'extent of climate data'
  ),
  col = c('firebrick4', 'black', 'gold', 'gold'),
  lwd = 1*f,
  lty = c(NA, 1, 2, 1),
  pch = c(16, NA, NA, NA),
  cex = 0.75*f,
  bty = 'n'
)

# Supplemental Figure 4B
plot(
  x_con,
  y_con,
  xlab = names_obs[5],
  ylab = names_obs[6],
  xlim = c(-1, 1),
  ylim = c(-1.1, 0.5),
  type = 'n',
  cex = 1*f,
  cex.lab = 1*f,
  cex.axis = 1*f
)
points(x_con, y_con, pch = 16, cex = 0.15*f, col = 'blue3')
title('(b)', cex.main = 1.1*f)
contour(
  x = out_xcol_con,
  y = out_yrow_con,
  z = t(out$out$obs$g$z$v),
  add = T,
  lwd = 1*f,
  vfont = c('sans serif', 'bold'),
  nlevels = 10,
  drawlabels = F,
  col = 'black'
)
plot(inner_poly, lty = 2, border = 'gold', lwd = 1*f, add = TRUE)
plot(outer_poly, lty = 1, border = 'gold', lwd = 1*f, add = TRUE)
legend(
  x = 'bottomleft',
  inset = 0,
  ncol = 1,
  legend = c(
    'seronegative location', 'one bandwidth', 'extent of coyote data', 
    'extent of climate data'
  ),
  col = c('blue3', 'black', 'gold', 'gold'),
  lwd = 1*f,
  lty = c(NA, 1, 2, 1),
  pch = c(16, NA, NA, NA),
  cex = 0.75*f,
  bty = 'n'
)
dev.off()

# ---------------------------------- END OF CODE ---------------------------------- #
