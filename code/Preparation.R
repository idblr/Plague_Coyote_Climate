# ----------------------------------------------------------------- #
# Preparation for Manuscript Figures
# 
# Author: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Date created: May 20, 2022
#
# Modified by: @idblr
# Modified on: November 22, 2022
#
# Notes:
# Step 1: You must download the elevation BIL zipfile at 4km resolution from the PRISM data portal https://www.prism.oregonstate.edu/normals/
# Step 2: Save the zipfile to the data directory in this repository
# Step 3: Set your own data paths to data in 'Paths.R' file
# Step 4: Change the path in the `source()` call on line 32 from "Paths_private.R" to "Paths.R"
# ----------------------------------------------------------------- #

############
# PACKAGES #
############
cat("Loading Packages...")

loadedPackages <- c("envi", "extrafont", "graphics", "grDevices", "latticeExtra",
                    "mgcv", "prism", "raster", "RColorBrewer", "RStoolbox", "sf",
                    "sp", "stats", "utils")
suppressMessages(lapply(loadedPackages, require, character.only = TRUE))

############
# SETTINGS #
############
cat("Loading Settings...")

# Import data paths
source("code/Paths.R")

# Assign directory to store PRISM data
options(prism.path = prism_path)

# Import Latin Modern Roman font
## # may need to install "Rttf2pt1" v. 1.3.8
## https://stackoverflow.com/questions/61204259/how-can-i-resolve-the-no-font-name-issue-when-importing-fonts-into-r-using-ext
suppressMessages(extrafont::font_import(pattern = "lmroman10*", prompt = FALSE)) 

# Assign RNG
set.seed(88751) # reproducibility with manuscript
# ## uncomment for new random seed
# initial_seed <- as.integer(Sys.time())
# the_seed <- initial_seed %% 100000 # take the trailing five digits of the initial seed
# set.seed(the_seed)

# Number of Cross-Validation Folds
nfld <- 25

####################
# DATA IMPORTATION #
####################
cat("Loading Data...")

# US Polygon Data
## State-level
us <- suppressMessages(raster::getData("GADM", country = "USA", level = 1, path = "data"))
ca_state <- us[match(toupper("California"), toupper(us$NAME_1)), ]
suppressWarnings(ca_buffer <- rgeos::gBuffer(ca_state, width = 0.1, byid = TRUE)) # Add 0.1 degree buffer to capture all of PRISM
suppressWarnings(CA_proj <- sp::spTransform(ca_state, sp::CRS(SRS_string = "EPSG:26910")))
ca_buffer_proj <- sp::spTransform(ca_buffer, sp::CRS(SRS_string = "EPSG:26910"))
## County-level
counties <- suppressMessages(raster::getData("GADM", country = "USA", level = 2, path = "data"))
counties$OBJECTID <- row.names(counties)
ca <- counties[counties$NAME_1 %in% "California", ]

# CDPH Coyote Point Data
cdph_coyote <- read.csv(cdph_path) 
cdph_coyote_sp <- subset(cdph_coyote, GCL < 4)
cdph_coyote_sp <- cdph_coyote_sp[cdph_coyote_sp$Long_QC != 0, ]
sp::coordinates(cdph_coyote_sp) <- ~ Long_QC + Lat_QC
suppressWarnings(sp::proj4string(cdph_coyote_sp) <- sp::proj4string(ca_state)) # CDPH metadata: coordinates at WGS84, same as GADM data
cdph_coyote_sp$Long <- sp::coordinates(cdph_coyote_sp)[ , 1]
cdph_coyote_sp$Lat <- sp::coordinates(cdph_coyote_sp)[ , 2]

# Download PRISM data
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "ppt",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "tdmean",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "tmax",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "tmean",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "tmin",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "vpdmax",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
suppressMessages(utils::capture.output(prism::get_prism_normals(type = "vpdmin",
                                                                resolution = "4km",
                                                                annual = TRUE,
                                                                keepZip = FALSE)))
unzip(zipfile = elevation_zip, exdir = "data/prismtmp")

# Convert to Rasters
#prism::prism_archive_ls()
ppt <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[1]))
tdmean <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[2]))
tmax <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[3]))
tmean <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[4]))
tmin <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[5]))
vpdmax <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[6]))
vpdmin <- raster::raster(prism::pd_to_file(prism::prism_archive_ls()[7]))
elev <- raster::raster(elevation_path)

# Reproject PRISM Rasters
crs_us <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
reproj_ppt <- raster::projectRaster(ppt, crs = raster::crs(crs_us))
reproj_tdmean <- raster::projectRaster(from = tdmean, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")
reproj_tmax <- raster::projectRaster(from = tmax, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")
reproj_tmean <- raster::projectRaster(from = tmean, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")
reproj_tmin <- raster::projectRaster(from = tmin, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")
reproj_vpdmax <- raster::projectRaster(from = vpdmax, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")
reproj_vpdmin <- raster::projectRaster(from = vpdmin, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")
reproj_elev <- raster::projectRaster(from = elev, to = reproj_ppt, crs = raster::crs(crs_us), method = "bilinear")

# Scale Rasters by Range Transformation (can do other scaling)
scaled_reproj_ppt <- (reproj_ppt-min(na.omit(reproj_ppt@data@values)))/(max(na.omit(reproj_ppt@data@values))-min(na.omit(reproj_ppt@data@values)))
scaled_reproj_tdmean <- (reproj_tdmean-min(na.omit(reproj_tdmean@data@values)))/(max(na.omit(reproj_tdmean@data@values))-min(na.omit(reproj_tdmean@data@values)))
scaled_reproj_tmax <- (reproj_tmax-min(na.omit(reproj_tmax@data@values)))/(max(na.omit(reproj_tmax@data@values))-min(na.omit(reproj_tmax@data@values)))
scaled_reproj_tmean <- (reproj_tmean-min(na.omit(reproj_tmean@data@values)))/(max(na.omit(reproj_tmean@data@values))-min(na.omit(reproj_tmean@data@values)))
scaled_reproj_tmin <- (reproj_tmin-min(na.omit(reproj_tmin@data@values)))/(max(na.omit(reproj_tmin@data@values))-min(na.omit(reproj_tmin@data@values)))
scaled_reproj_vpdmax <- (reproj_vpdmax-min(na.omit(reproj_vpdmax@data@values)))/(max(na.omit(reproj_vpdmax@data@values))-min(na.omit(reproj_vpdmax@data@values)))
scaled_reproj_vpdmin <-(reproj_vpdmin-min(na.omit(reproj_vpdmin@data@values)))/(max(na.omit(reproj_vpdmin@data@values))-min(na.omit(reproj_vpdmin@data@values)))

# Raster Stack for PCA
rasters_scaled <- raster::stack(scaled_reproj_ppt,
                                scaled_reproj_tdmean,
                                scaled_reproj_tmax,
                                scaled_reproj_tmean,
                                scaled_reproj_tmin,
                                scaled_reproj_vpdmax,
                                scaled_reproj_vpdmin)

cat("Running PCA...")
# Spatial PCA
pca1 <- RStoolbox::rasterPCA(rasters_scaled)
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
mask_pc1 <- raster::mask(pc1_b1, ca_buffer)
mask_pc2 <- raster::mask(pc1_b2, ca_buffer)
proj_pc1 <- raster::projectRaster(from = mask_pc1, crs = sp::CRS(SRS_string = "EPSG:26910"), method = "bilinear") # NAD83/UTM Zone 10N 
proj_pc2 <- raster::projectRaster(from = mask_pc2, to = proj_pc1, crs = sp::CRS(SRS_string = "EPSG:26910"), method = "bilinear") # NAD83/UTM Zone 10N 
crop_pc1 <- raster::crop(raster::mask(proj_pc1, CA_proj), ca_buffer_proj)
crop_pc2 <- raster::crop(raster::mask(proj_pc2, CA_proj), ca_buffer_proj)

####################
# DATA PREPARATION #
####################
cat("Preparing Data...")

# Prediction Data
extract_points_ca <- raster::rasterToPoints(mask_pc1)
extract_points_ca <- extract_points_ca[ , 1:2]
predict_locs <- data.frame(sp::coordinates(extract_points_ca),
                           raster::extract(pc1_b1, extract_points_ca),
                           raster::extract(pc1_b2, extract_points_ca))
names(predict_locs) <- c("x", "y", "pc1", "pc2")

# CDPH Data
obs_dat <- cdph_coyote_sp[ , c(1, 51, 50, 29)]
names(obs_dat) <- c("id", "x", "y", "mark")
obs_dat$mark <- ifelse(obs_dat$mark == "NEG", 0, 1)
obs_dat$pc1 <- raster::extract(pc1_b1, obs_dat[ , 2:3])
obs_dat$pc2 <- raster::extract(pc1_b2, obs_dat[ , 2:3])
obs_dat <- obs_dat@data

#############
# MODEL RUN #
#############
cat("Running Model...")

# Conserved, Automatic (Non Adaptive)
out <- envi::lrren(obs_locs = obs_dat,
                   predict_locs = predict_locs,
                   adapt = FALSE,
                   edge = "diggle",
                   predict = TRUE,
                   p_correct = "none",
                   conserve = FALSE,
                   cv = TRUE,
                   kfold = nfld,
                   balance = TRUE,
                   verbose = FALSE,
                   poly_buffer = NULL)

##################
# POSTPROCESSING #
##################
cat("Processing Results...")

# For Figure 1
## Formatted "Covariate Space" 
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
out_lrr <- as.data.frame(dplyr::tibble(x = rx,
                                       y = ry,
                                       lrr = as.vector(t(out$out$obs$rr$v)))) # create dataframe of coordinates and p-values per pixel
sp::coordinates(out_lrr) <- ~ x + y # convert to spatialpixelsdataframe
sp::gridded(out_lrr) <- TRUE # gridded
lrr_raster <- raster::raster(out_lrr)  # create raster
values(lrr_raster)[values(lrr_raster) <= -max(values(lrr_raster), na.rm = TRUE)] <- -max(values(lrr_raster), na.rm = TRUE)

# For Figure 2
# Transform result from "Covariate Space" to "Geographic Space"
predict_risk <- as.data.frame(dplyr::tibble(x = out$out$predict$predict_locs.x,
                                            y = out$out$predict$predict_locs.y,
                                            rr = out$out$predict$rr))
naband <- predict_risk # save for next step
sp::coordinates(predict_risk) <- ~ x + y # coordinates
sp::gridded(predict_risk) <- TRUE # gridded
predict_risk_raster <- raster::raster(predict_risk)
crs(predict_risk_raster) <- crs_us
predict_risk_raster <- raster::projectRaster(predict_risk_raster,
                                             crs = sp::CRS(SRS_string = "EPSG:26910"), method = "bilinear")
predict_risk_raster <- raster::crop(predict_risk_raster, ca_buffer_proj)
predict_risk_raster <- raster::mask(predict_risk_raster, CA_proj)
predict_risk_reclass <- predict_risk_raster
predict_risk_reclass[predict_risk_reclass <= -predict_risk_raster@data@max] <- -predict_risk_raster@data@max

# For Figure 2 and Figure 3
## Create separate layer for NAs (i.e., "no data")
naband$rr <- ifelse(is.na(naband$rr), 9999, naband$rr)
sp::coordinates(naband) <- ~ x + y # coordinates
sp::gridded(naband) <- TRUE # gridded
NA_risk_raster <- raster(naband)
crs(NA_risk_raster) <- crs_us
reclass_naband <- raster::reclassify(NA_risk_raster, c(-Inf, 9998, NA, 9998, Inf, 1))
naband_reclass <- raster::projectRaster(from = reclass_naband, to = predict_risk_reclass, crs = sp::CRS(SRS_string = "EPSG:26910"), method = "ngb")
naband_reclass <- raster::crop(naband_reclass, ca_buffer_proj)
naband_reclass <- raster::mask(naband_reclass, CA_proj)

## Create separate layer for climate profiles outside inner polygon or "extent of coyote data" (i.e., "sparse data")
inner_poly <- sf::st_polygon(x = list(out$out$inner_poly))
predict_pts <- sf::st_as_sf(out$out$predict,
                            coords = c("predict_locs.pc1", "predict_locs.pc2"))
outside <- sapply(sf::st_intersects(predict_pts, inner_poly), function(x){length(x) == 0})
outside_pts <- predict_pts[outside, ]
outside_xy <- sf::st_as_sf(sf::st_drop_geometry(outside_pts), coords = c("predict_locs.x", "predict_locs.y"))
sf::st_crs(outside_xy) <- 4326
na_risk <- data.frame(x = sf::st_coordinates(outside_xy)[ , 1],
                      y = sf::st_coordinates(outside_xy)[ , 2],
                      rr = 1)
sp::coordinates(na_risk) <- ~ x + y # coordinates
suppressWarnings(sp::gridded(na_risk) <- TRUE) # gridded
na_risk <- raster::raster(na_risk)
crs(na_risk) <- crs_us
na_risk <- raster::mask(na_risk, raster::rasterToPolygons(reclass_naband, dissolve = TRUE), inverse = TRUE)
na_risk <- raster::projectRaster(from = na_risk, to = predict_risk_reclass, crs = sp::CRS(SRS_string = "EPSG:26910"), method = "ngb")
na_risk <- raster::crop(na_risk, ca_buffer_proj)
na_risk <- raster::mask(na_risk, CA_proj)
na_pts <- data.frame(raster::rasterToPoints(na_risk))[ , 1:2]
sp::coordinates(na_pts) <- ~ x + y # coordinates
crs(na_pts) <- sp::CRS(SRS_string = "EPSG:26910")

## North Arrow
arrow1 <-  sp::layout.north.arrow(type = 1)
### shift the coordinates 
### shift = c(x,y) direction
Narrow1 <- maptools::elide(arrow1,
                           shift = c(raster::extent(ca_buffer)[1] + 0.25,
                                     raster::extent(ca_buffer)[3] + 0.05))
suppressWarnings(sp::proj4string(Narrow1) <- sp::proj4string(ca_buffer))
Narrow2 <- sp::spTransform(Narrow1, sp::CRS(SRS_string = "EPSG:26910")) # NAD83/UTM Zone 10N 

# For Figure 3
# Transform result from "Covariate Space" to "Geographic Space"
predict_tol <- as.data.frame(dplyr::tibble(x = out$out$predict$predict_locs.x,
                                           y = out$out$predict$predict_locs.y,
                                           pval = out$out$predict$pval))
naband <- predict_tol # save for next step
sp::coordinates(predict_tol) <- ~ x + y # coordinates
sp::gridded(predict_tol) <- TRUE # gridded
predict_tol_raster <- raster::raster(predict_tol)
raster::crs(predict_tol_raster) <- crs_us
reclass_tol <- raster::reclassify(predict_tol_raster, c(-Inf, 0.005, 5,
                                                        0.005, 0.025, 4,
                                                        0.025, 0.975, 3,
                                                        0.975, 0.995, 2,
                                                        0.995, Inf, 1))
reclass_tol <- raster::projectRaster(from = reclass_tol, to = predict_risk_reclass, crs = sp::CRS(SRS_string = "EPSG:26910"), method = "ngb")
reclass_tol <- raster::crop(reclass_tol, ca_buffer_proj)
reclass_tol <- raster::mask(reclass_tol, CA_proj)

# For Supplemental Figure 6 and Supplemental Figure 7
## Result values for univariate response curves
out_univar <- as.data.frame(dplyr::tibble(rr = out$out$predict$rr,
                                          pval = out$out$predict$pval,
                                          outside = outside,
                                          ppt = raster::extract(reproj_ppt, predict_locs[,1:2]),
                                          tmax = raster::extract(reproj_tmax, predict_locs[,1:2]),
                                          tmean = raster::extract(reproj_tmean, predict_locs[,1:2]),
                                          tmin = raster::extract(reproj_tmin, predict_locs[,1:2]),
                                          tdmean = raster::extract(reproj_tdmean, predict_locs[,1:2]),
                                          vpdmax = raster::extract(reproj_vpdmax, predict_locs[,1:2]),
                                          vpdmin = raster::extract(reproj_vpdmin, predict_locs[,1:2]),
                                          elev = raster::extract(reproj_elev, predict_locs[,1:2])))
out_univar <- na.omit(out_univar[is.finite(out_univar$rr),]) # remove NAs

###########
# CLEANUP #
###########
cat("Cleaing Up...")

rm(list = setdiff(ls(), c("ca", "ca_buffer", "ca_buffer_proj", "CA_proj", "cdph_coyote_sp", "crop_pc1", "crop_pc2", 
                          "crs_us", "lrr_raster", "predict_risk_reclass", "na_pts", "naband_reclass", "Narrow2",
                          "nfld", "obs_dat", "out", "out_univar", "reclass_tol")))
cat("Done!\n")

# -------------------------- END OF CODE -------------------------- #
