# ----------------------------------------------------------------- #
# Manuscript Supplemental Figure 5
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

## ROC AUC
out_cv_rr <- cvAUC::cvAUC(out$cv$cv_predictions_rr, out$cv$cv_labels)
out_ci_rr <- cvAUC::ci.cvAUC(out$cv$cv_predictions_rr, out$cv$cv_labels, confidence = 0.95)

## Precision Recall
pred_rr <- ROCR::prediction(out$cv$cv_predictions_rr,out$cv$cv_labels)
perf_rr <- ROCR::performance(pred_rr, "prec", "rec") # PRREC same as "ppv", "tpr"

case_locs <- subset(obs_dat, obs_dat$mark == 1)

#########################
# SUPPLEMENTAL FIGURE 5 #
#########################

f <- 2

grDevices::png(file = "figures/SupplementalFigure5.png", width = 600*f, height = 550*f)
graphics::layout(matrix(c(1, 2), ncol = 2, byrow = TRUE), heights = 1)
graphics::par(mar = c(0.1, 5.1, 3.1, 4.1), pty = "s", family = "LM Roman 10", cex.axis = 1*f)
# Supplemental Figure 2A
plot(out_cv_rr$perf,
     col = "black",
     lty = 3,
     xlab = "false positive rate",
     ylab = "true positive rate",
     cex = 1*f,
     cex.lab = 1*f) #Plot fold AUCs
graphics::abline(0, 1, col = "black", lty = 2, lwd = 1*f)
plot(out_cv_rr$perf, col = "black", avg = "vertical", add = TRUE, lwd = 2*f) #Plot CV AUC
graphics::legend(x = "bottomright",
                 inset = 0,
                 legend = c("iteration",
                            "average",
                            "luck (reference)"),
                 lty = c(3,1,2),
                 lwd = c(1*f,2*f,1*f),
                 col = c("black", "black", "black"),
                 bty = "n",
                 cex = 0.67*f)
graphics::title("(a)", cex.main = 0.8*f)
# Supplemental Figure 2B
plot(perf_rr,
     ylim = c(0,1),
     xlim = c(0,1),
     lty = 3,
     xlab = "true positive rate",
     ylab = "positive predictive value",
     cex = 1*f,
     cex.lab = 1*f)
graphics::abline(a = (nrow(case_locs)/nfld)/length(out$cv$cv_labels[[1]]),
                 b = 0,
                 lty = 2,
                 col = "black",
                 lwd = 1*f)
# Average PRREC
graphics::lines(colMeans(do.call(rbind, perf_rr@x.values)),
                colMeans(do.call(rbind, perf_rr@y.values)),
                col = "black",
                lty = 1,
                lwd = 2*f) 
graphics::title("(b)", cex.main = 0.8*f)
graphics::legend(x = "bottomright",
                 inset = 0, #title = "Legend",
                 legend = c("iteration",
                            "average",
                            "luck (reference)"),
                 lty = c(3, 1, 2),
                 lwd = c(1*f,2*f,1*f),
                 col = c("black", "black", "black"),
                 bty = "n",
                 cex = 0.67*f)
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
