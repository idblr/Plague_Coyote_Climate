# ----------------------------------------------------------------------------------------------- #
# Manuscript Supplemental Figure 5
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

## ROC AUC
out_cv_rr <- cvAUC(lapply(out$cv$cv_predictions_rr, unlist), out$cv$cv_labels)
out_ci_rr <- ci.cvAUC(lapply(out$cv$cv_predictions_rr, unlist), out$cv$cv_labels, confidence = 0.95)

## Precision Recall
pred_rr <- prediction(lapply(out$cv$cv_predictions_rr, unlist),out$cv$cv_labels)
perf_rr <- performance(pred_rr, 'prec', 'rec') # PRREC same as 'ppv', 'tpr'

case_locs <- subset(obs_dat, obs_dat$mark == 1)

# --------------------- #
# SUPPLEMENTAL FIGURE 5 #
# --------------------- #

f <- 2

png(file = file.path('figures', 'SupplementalFigure5.png'), width = 8*f, height = 5*f, units = 'in', res = 200*f)
layout(matrix(c(1, 2), ncol = 2, byrow = TRUE), heights = 1)
par(mar = c(0.1, 5.1, 3.1, 4.1), pty = 's', family = 'LM Roman 10', cex.axis = 1*f)

# Supplemental Figure 5A
plot(
  out_cv_rr$perf,
  col = 'black',
  lty = 3,
  xlab = 'false positive rate',
  ylab = 'true positive rate',
  cex = 1*f,
  cex.lab = 1*f
) #Plot fold AUCs
abline(0, 1, col = 'black', lty = 2, lwd = 1*f)
plot(out_cv_rr$perf, col = 'black', avg = 'vertical', add = TRUE, lwd = 2*f) #Plot CV AUC
legend(
  x = 'bottomright',
  inset = 0,
  legend = c(
    'iteration',
    'average',
    'luck (reference)'
  ),
  lty = c(3,1,2),
  lwd = c(1*f, 2*f, 1*f),
  col = c('black', 'black', 'black'),
  bty = 'n',
  cex = 0.67*f
)
title('(a)', cex.main = 0.8*f)

# Supplemental Figure 5B
plot(
  perf_rr,
  ylim = c(0,1),
  xlim = c(0,1),
  lty = 3,
  xlab = 'true positive rate',
  ylab = 'positive predictive value',
  cex = 1*f,
  cex.lab = 1*f
)
abline(
  a = (nrow(case_locs)/nfld)/length(out$cv$cv_labels[[1]]),
  b = 0,
  lty = 2,
  col = 'black',
  lwd = 1*f
)
# Average PRREC
lines(
  colMeans(do.call(rbind, perf_rr@x.values)),
  colMeans(do.call(rbind, perf_rr@y.values)),
  col = 'black',
  lty = 1,
  lwd = 2*f
) 
title('(b)', cex.main = 0.8*f)
legend(
  x = 'bottomright',
  inset = 0,
  legend = c(
    'iteration',
    'average',
    'luck (reference)'
  ),
  lty = c(3, 1, 2),
  lwd = c(1*f, 2*f, 1*f),
  col = c('black', 'black', 'black'),
  bty = 'n',
  cex = 0.67*f
)
dev.off()

# ----------------------------------------- END OF CODE ----------------------------------------- #
