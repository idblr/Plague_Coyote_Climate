# ----------------------------------------------------------------------------------------------- #
# Preparation for Manuscript Figures
# ----------------------------------------------------------------------------------------------- #
# 
# Created by: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Created on: 2022-05-20
#
# Most recently modified by: @idblr
# Most recently modified on: 2024-06-30
#
# Notes:
# Step 1: You must download the elevation BIL zip file at 4-km resolution from the PRISM data portal
#         https://www.prism.oregonstate.edu/normals/
# Step 2: Save the zip file to the 'prism' subdirectory within the 'data' directory of this repository
# Step 3: Set your own data paths to data in 'Paths.R' file
# ----------------------------------------------------------------------------------------------- #

# -------- #
# PACKAGES #
# -------- #

cat('Loading Packages...')

loadedPackages <- c(
  'dplyr', 'cowplot', 'cvAUC', 'envi', 'extrafont', 'fields', 'geodata', 'ggnewscale', 'ggplot2',
  'graphics', 'grDevices', 'grid', 'latticeExtra', 'mgcv', 'png', 'prism', 'raster', 'RColorBrewer',
  'ROCR', 'RStoolbox', 'sf', 'sp', 'stats', 'terra', 'tidyterra', 'utils'
)
suppressMessages(lapply(loadedPackages, require, character.only = TRUE))

# -------- #
# SETTINGS #
# -------- #

cat('Loading Settings...')

# Import data paths
source(file.path('code', 'Paths.R'))

# Assign directory to store PRISM data
options(prism.path = prism_path)

# Import Latin Modern Roman font
## # may need to install 'Rttf2pt1' v. 1.3.8
## https://stackoverflow.com/questions/61204259/how-can-i-resolve-the-no-font-name-issue-when-importing-fonts-into-r-using-ext
suppressMessages(font_import(pattern = 'lmroman10*', prompt = FALSE)) 

# Assign RNG
set.seed(88751) # reproducibility with manuscript (should only affect cross validation)
# ## uncomment for new random seed
# initial_seed <- as.integer(Sys.time())
# the_seed <- initial_seed %% 100000 # take the trailing five digits of the initial seed
# set.seed(the_seed)

# Number of Cross-Validation Folds
nfld <- 25

# ---------------- #
# DATA IMPORTATION #
# ---------------- #

cat('Loading Data...')

# Canada and Mexico
canada <- suppressMessages(gadm(country = 'Canada', level = 1, path = file.path('data', 'gadm')))
canada <- canada[canada$NAME_1 %in% c('British Columbia', 'Alberta', 'Saskatchewan')]
mx <- suppressMessages(gadm(country = 'Mexico', level = 1, path = file.path('data', 'gadm')))
mx <- mx[mx$NAME_1 %in% c('Baja California', 'Sonora', 'Chihuahua')]

# US Polygon Data
## State-level
us <- suppressMessages(gadm(country = 'USA', level = 1, path = file.path('data', 'gadm')))
pacs <- us[us$NAME_1 %in% c(
  'California', 'Arizona', 'Nevada', 'Utah', 'Idaho', 'Oregon'
  #, 'Washington', 'Montana', 'Wyoming', 'Colorado', 'New Mexico'
)]
suppressWarnings(pacs_proj <- project(pacs, crs('EPSG:26910')))
ca_state <- us[match(toupper('California'), toupper(us$NAME_1)), ]
suppressWarnings(ca_buffer <- buffer(ca_state, width = 2000)) # Add 2-km buffer to capture all of PRISM
suppressWarnings(CA_proj <- project(ca_state, crs('EPSG:26910')))
ca_buffer_proj <- project(ca_buffer, crs('EPSG:26910'))
## County-level
counties <- suppressMessages(gadm(country = 'USA', level = 2, path = file.path('data', 'gadm')))
counties$OBJECTID <- row.names(counties)
ca <- counties[counties$NAME_1 %in% 'California', ]

# CDPH Coyote Point Data
cdph_coyote <- read.csv(cdph_path) 
cdph_coyote_sp <- subset(cdph_coyote, GCL < 4)
cdph_coyote_sp <- cdph_coyote_sp[cdph_coyote_sp$Long_QC != 0, ]
cdph_coyote_sp <- st_as_sf(cdph_coyote_sp, coords = c('Long_QC', 'Lat_QC'), remove = FALSE)
st_crs(cdph_coyote_sp) <- st_crs(crs(ca_state)) # CDPH metadata: coordinates at WGS84, same as GADM data
cdph_coyote_sp$Long <- cdph_coyote_sp$Long_QC
cdph_coyote_sp$Lat <- cdph_coyote_sp$Lat_QC

# Download PRISM data
## NOTE: Below will automatically load version M4 (1991-2020). This analysis used M3 (1981-2010)
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'ppt', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'tdmean', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'tmax', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'tmean', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'tmin', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'vpdmax', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# suppressMessages(
#   capture.output(
#     get_prism_normals(type = 'vpdmin', resolution = '4km', annual = TRUE, keepZip = FALSE)
#   )
# )
# 
# unzip(zipfile = elevation_zip, exdir = file.path('data', 'prism'))

# Convert to Rasters
# prism_archive_ls()
ppt <- rast(pd_to_file(prism_archive_ls()[1]))
tdmean <- rast(pd_to_file(prism_archive_ls()[2]))
tmax <- rast(pd_to_file(prism_archive_ls()[3]))
tmean <- rast(pd_to_file(prism_archive_ls()[4]))
tmin <- rast(pd_to_file(prism_archive_ls()[5]))
vpdmax <- rast(pd_to_file(prism_archive_ls()[6]))
vpdmin <- rast(pd_to_file(prism_archive_ls()[7]))
elev <- rast(elevation_path)

# Reproject PRISM Rasters
crs_us <- crs(ca_state)
reproj_ppt <- project(ppt, crs(ca_state))
reproj_tdmean <- project(tdmean, crs(ca_state))
reproj_tmax <- project(tmax, crs(ca_state))
reproj_tmean <- project(tmean, crs(ca_state))
reproj_tmin <- project(tmin, crs(ca_state))
reproj_vpdmax <- project(vpdmax, crs(ca_state))
reproj_vpdmin <- project(vpdmin, crs(ca_state))
reproj_elev <- project(elev, crs(ca_state))

# Scale Rasters by Range Transformation (can do other scaling)
scaled_reproj_ppt <- (reproj_ppt-minmax(reproj_ppt)[1])/diff(minmax(reproj_ppt))
scaled_reproj_tdmean <- (reproj_tdmean-minmax(reproj_tdmean)[1])/diff(minmax(reproj_tdmean))
scaled_reproj_tmax <- (reproj_tmax-minmax(reproj_tmax)[1])/diff(minmax(reproj_tmax))
scaled_reproj_tmean <- (reproj_tmean-minmax(reproj_tmean)[1])/diff(minmax(reproj_tmean))
scaled_reproj_tmin <- (reproj_tmin-minmax(reproj_tmin)[1])/diff(minmax(reproj_tmin))
scaled_reproj_vpdmax <- (reproj_vpdmax-minmax(reproj_vpdmax)[1])/diff(minmax(reproj_vpdmax))
scaled_reproj_vpdmin <- (reproj_vpdmin-minmax(reproj_vpdmin)[1])/diff(minmax(reproj_vpdmin))

# Raster Stack for PCA
rasters_scaled <- c(
  scaled_reproj_ppt, scaled_reproj_tdmean, scaled_reproj_tmax, scaled_reproj_tmean,
  scaled_reproj_tmin, scaled_reproj_vpdmax, scaled_reproj_vpdmin
)

cat('Running PCA...')
# Spatial PCA
pca1 <- rasterPCA(rasters_scaled)
# summary(pca1$model) # PCA components
# pca_sum <- summary(pca1$model)
# pca_load <- pca1$model$loadings # PCA loadings
# eigs <- pca_sum[[1]]^2
# PoV <- eigs/sum(eigs)

# Extract Bands from PCA
pc1 <- pca1$map
pc1_b1 <- pc1[[1]] # PC1
pc1_b2 <- pc1[[2]] # PC2

# Mask scaled rasters by study area (window, i.e., California)
mask_pc1 <- crop(pc1_b1, ca_buffer, mask = TRUE)
mask_pc2 <- crop(pc1_b2, ca_buffer, mask = TRUE)
proj_pc1 <- project(mask_pc1, crs(ca_buffer_proj)) # NAD83/UTM Zone 10N 
proj_pc2 <- project(mask_pc2, crs(ca_buffer_proj)) # NAD83/UTM Zone 10N 

# ---------------- #
# DATA PREPARATION #
# ---------------- #

cat('Preparing Data...')

# Prediction Data
extract_points_ca <- as.points(mask_pc1)
extract_points_ca <- st_as_sf(extract_points_ca)
predict_locs <- data.frame(
  st_coordinates(extract_points_ca),
  extract(pc1_b1, extract_points_ca, ID = FALSE),
  extract(pc1_b2, extract_points_ca, ID = FALSE)
)
names(predict_locs) <- c('x', 'y', 'pc1', 'pc2')

# CDPH Data
names(cdph_coyote_sp)
obs_dat <- st_drop_geometry(cdph_coyote_sp)[ , c(1, 60, 61, 30)]
names(obs_dat) <- c('id', 'x', 'y', 'mark')
obs_dat$mark <- ifelse(obs_dat$mark == 'NEG', 0, 1)
obs_dat$pc1 <- extract(pc1_b1, obs_dat[ , 2:3], ID = FALSE, raw = TRUE)
obs_dat$pc2 <- extract(pc1_b2, obs_dat[ , 2:3], ID = FALSE, raw = TRUE)
colnames(obs_dat) <- c('id', 'x', 'y', 'mark', 'pc1', 'pc2')
dimnames(obs_dat$pc1) <- NULL
dimnames(obs_dat$pc2) <- NULL

# --------- #
# MODEL RUN #
# --------- #

cat('Running Model...')

# Conserved, Automatic (Non Adaptive)
out <- lrren(
  obs_locs = obs_dat,
  predict_locs = predict_locs,
  adapt = FALSE,
  edge = 'diggle',
  predict = TRUE,
  p_correct = 'none',
  conserve = FALSE,
  cv = TRUE,
  kfold = nfld,
  balance = TRUE,
  verbose = FALSE,
  poly_buffer = NULL
)

# -------------- #
# POSTPROCESSING #
# -------------- #

cat('Processing Results...')

# For Figure 1
## Formatted 'Covariate Space'
rx <- rep(out$out$obs$rr$xcol, length(out$out$obs$rr$yrow))
for(i in 1:length(out$out$obs$rr$yrow)){
  if (i == 1){
    ry <- rep(out$out$obs$rr$yrow[i], length(out$out$obs$rr$xcol))
  }
  if (i != 1){
    ry <- c(ry, rep(out$out$obs$rr$yrow[i], length(out$out$obs$rr$xcol)))
  }
}
## create data frame of coordinates and p-values per pixel
out_lrr <- data.frame(x = rx, y = ry, lrr = as.vector(t(out$out$obs$rr$v)))
lrr_raster <- rast(out_lrr)
## truncate values to show more variability near null expectation
lrr_raster[lrr_raster <= -minmax(lrr_raster)[2]] <- -minmax(lrr_raster)[2]

## Create separate layer for climate profiles outside inner polygon or 'extent of coyote data' (i.e., 'sparse data')
inner_poly <- st_polygon(x = out$out$inner_poly)
predict_pts <- st_as_sf(
  out$out$predict, 
  coords = c('predict_locs.pc1', 'predict_locs.pc2'), 
  remove = FALSE
)
predict_pts$outside <- sapply(st_intersects(predict_pts, inner_poly), function(x){length(x) == 0})
predict_pts <- st_as_sf(
  st_drop_geometry(predict_pts), 
  coords = c('predict_locs.x', 'predict_locs.y'), 
  remove = FALSE, crs = crs_us
)
pred_rast <- mask_pc1
predict_risk <- rasterize(predict_pts, pred_rast, field = 'rr')
predict_pval <- rasterize(predict_pts, pred_rast, field = 'pval')
predict_sparse <- rasterize(predict_pts, pred_rast, field = 'outside')
predict_na <- predict_risk
predict_na[is.na(predict_na)] <- 9999
predict_na <- clamp(predict_na, lower = 9999, value = FALSE)
reclass_naband <- subst(predict_na, 9999, 'no coyote data')
reclass_naband <- droplevels(reclass_naband)
reclass_naband <- crop(reclass_naband, ca_buffer, mask = TRUE)
reclass_naband <- project(reclass_naband, crs(CA_proj))

# Figure 2    
predict_risk_reclass <- predict_risk
predict_risk_reclass <- project(predict_risk_reclass, crs(CA_proj))
## truncate values to show more variability near null expectation
predict_risk_reclass[predict_risk_reclass <= -minmax(predict_risk_reclass)[2]] <- -minmax(predict_risk_reclass)[2]

predict_sparse_reclass <- c(predict_sparse, predict_risk)
names(predict_sparse_reclass) <- c('outside', 'rr')
predict_sparse_reclass$sparse <- predict_sparse_reclass$outside == 1 &
  is.finite(predict_sparse_reclass$rr) &
  !is.na(predict_sparse_reclass$rr)

predict_sparse_reclass <- clamp(predict_sparse_reclass$sparse, lower = 1, value = FALSE)
predict_sparse_reclass <- subst(predict_sparse_reclass$sparse, 1, 'sparse coyote data')
na_risk <- project(predict_sparse_reclass, crs(CA_proj))
na_risk <- mask(as.polygons(na_risk, aggregate = FALSE), as.polygons(reclass_naband), inverse = TRUE)

# Figure 3
reclass_tol <- classify(predict_pval, c(-Inf, 0.005, 0.025,  0.975,  0.995,  Inf))
reclass_tol <- project(reclass_tol, crs(CA_proj))

# For Supplemental Figure 1 and Supplemental Figure 2
## North Arrow
arrow1 <-  layout.north.arrow(type = 1)
### shift the coordinates
### shift = c(x,y) direction
Narrow1 <- st_as_sf(arrow1)
st_geometry(Narrow1) <- st_geometry(Narrow1) + c(ext(ca_buffer)[1] + 0.25, ext(ca_buffer)[3] + 0.25)
st_crs(Narrow1) <- crs_us
Narrow2 <- st_transform(Narrow1, crs(CA_proj)) # NAD83/UTM Zone 10N

# For Supplemental Figure 6 and Supplemental Figure 7
## Result values for univariate response curves
out_univar <- data.frame(
  rr = out$out$predict$rr,
  pval = out$out$predict$pval,
  outside = predict_pts$outside,
  ppt = extract(reproj_ppt, predict_locs[ , 1:2], ID = FALSE),
  tmax = extract(reproj_tmax, predict_locs[ , 1:2], ID = FALSE),
  tmean = extract(reproj_tmean, predict_locs[ , 1:2], ID = FALSE),
  tmin = extract(reproj_tmin, predict_locs[ , 1:2], ID = FALSE),
  tdmean = extract(reproj_tdmean, predict_locs[ , 1:2], ID = FALSE),
  vpdmax = extract(reproj_vpdmax, predict_locs[ , 1:2], ID = FALSE),
  vpdmin = extract(reproj_vpdmin, predict_locs[ , 1:2], ID = FALSE),
  elev = extract(reproj_elev, predict_locs[ , 1:2], ID = FALSE)
)
names(out_univar) <- c(
  'rr', 'pval', 'outside', 'ppt', 'tmax', 'tmean', 'tmin', 'tdmean', 'vpdmax', 'vpdmin', 'elev'
)
out_univar <- na.omit(out_univar[is.finite(out_univar$rr), ]) # remove NAs

# ------- #
# CLEANUP #
# ------- #

cat('Cleaing Up...')

rm(
  list = setdiff(
    ls(), 
    c(
      'ca', 'ca_buffer', 'ca_buffer_proj', 'CA_proj', 'cdph_coyote_sp', 'mask_pc1', 'mask_pc2', 
      'crs_us', 'lrr_raster', 'predict_risk_reclass', 'Narrow2', 'nfld', 'obs_dat', 'out', 
      'out_univar', 'reclass_tol'
    )
  )
)

cat('Done!\n')

# ----------------------------------------- END OF CODE ----------------------------------------- #
