# ----------------------------------------------------------------- #
# Manuscript Supplemental Figure 1
# 
# Author: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Date created: May 20, 2022
#
# Modified by: @idblr
# Modified on: November 22, 2022
#
# Notes:
# A) See pre-steps to prepare for model run
# B) 2022/06/29 - Suppress counties with n<15 coyote observations
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

# Count samples per county
res_tot <- sp::over(cdph_coyote_sp, ca)
tab_tot <- as.data.frame(table(res_tot$OBJECTID))

# Assign 0 values to counties without observation
tab_count <- NULL
tab_count$id <- ca@data$OBJECTID
tab_merge <- merge(tab_count, tab_tot, by.y = "Var1", by.x = "id", all.x = T, sort = T)
#tab_merge$Freq <- ifelse(is.na(tab_merge$Freq), 0, tab_merge$Freq)

# Restrict to counties with at least 10 coyotes
tab_merge$Freq10 <- ifelse(tab_merge$Freq < 15, NA, tab_merge$Freq)
customlabs <- c("15", "200", "400", "600", "800", "1,000", "1,200", "1,400")

# Prevalence per county
res_pos <- sp::over(cdph_coyote_sp[cdph_coyote_sp$Res == "POS", ], ca)
tab_pos <- as.data.frame(table(res_pos$OBJECTID))
tab_merge <- merge(tab_merge, tab_pos, by.y = "Var1", by.x = "id", all.x = T, sort = T)
colnames(tab_merge) <- c("id", "total", "total10", "pos")
tab_merge$pos[is.na(tab_merge$pos)] <- 0
tab_merge$prev <- round(tab_merge$pos / tab_merge$total10, digits = 2)*100
#tab_merge$prev[is.na(tab_merge$prev)] <- 0
customlabs1 <- c("0.0", "10.0", "20.0", "30.0", "40.0")
customat1 <- c(0, 10.0, 20.0, 30.0, 40.0)

# Add attribute to spdf
ca@data <- dplyr::left_join(ca@data, tab_merge, by = c("OBJECTID" = "id"))

# Create Plot
ca_aea <- sp::spTransform(ca, sp::CRS(SRS_string = "EPSG:26910")) # NAD83/UTM Zone 10N 
ca_aea@data$id <- rownames(ca_aea@data)

ca_buffer_aea <- sp::spTransform(ca_buffer, sp::CRS(SRS_string = "EPSG:26910")) # NAD83/UTM Zone 10N 

# Add north arrow
North <- list("SpatialPolygonsRescale",
              sp::layout.north.arrow(type = 1), 
              offset = c(raster::extent(ca_buffer_aea)[1] + 20000,
                         raster::extent(ca_buffer_aea)[3] + 10000),
              scale = 100000)

# Add scale bar
scale1 <- list("SpatialPolygonsRescale",
               sp::layout.scale.bar(), 
               offset = c(raster::extent(ca_buffer_aea)[1] + 100000,
                          raster::extent(ca_buffer_aea)[3] + 30000),
               scale = 200000,
               fill = c("transparent", "black"))
s1_text0 <- list("sp.text",
                 c(raster::extent(ca_buffer_aea)[1] + 100000, raster::extent(ca_buffer_aea)[3] + 50000),
                 "0",
                 cex = 2,
                 fontfamily = "LM Roman 10")
s1_text1 <- list("sp.text",
                 c(raster::extent(ca_buffer_aea)[1] + 300000, raster::extent(ca_buffer_aea)[3] + 50000),
                 "200",
                 cex = 2,
                 fontfamily = "LM Roman 10")
s1_text2 <- list("sp.text",
                c(raster::extent(ca_buffer_aea)[1] + 200000, raster::extent(ca_buffer_aea)[3] + 50000),
                "100",
                cex = 2,
                fontfamily = "LM Roman 10")
s1_text3 <- list("sp.text",
                 c(raster::extent(ca_buffer_aea)[1] + 200000, raster::extent(ca_buffer_aea)[3] + 20000),
                 "km",
                 cex = 2,
                 fontfamily = "LM Roman 10")

# Color Palettes
palA <- grDevices::colorRampPalette(RColorBrewer::brewer.pal(n = 9, name = "YlGn"))(16)
palB <- grDevices::colorRampPalette(RColorBrewer::brewer.pal(n = 9, name = "YlOrRd"))(16)

#########################
# SUPPLEMENTAL FIGURE 1 #
#########################

f <- 4 # Graphical expansion factor

grDevices::png(file = "figures/Supplemental1A.png", width = 400*f, height = 525*f)
graphics::par(family = "LM Roman 10", mar = c(5, 1, 4, 1) + 0.1)
sp::spplot(obj = ca_aea,
           zcol = "total10",
           col.regions = palA,
           par.settings = list(axis.line = list(col =  "transparent")),
           colorkey = list(space ="bottom",
                           width = 0.5*f,
                           height = 0.2*f,
                           labels = list(cex = 1*f,
                                         fontfamily = "LM Roman 10",
                                         fontface = 1,
                                         labels = customlabs)),
           main = list(label = "(a)",
                       cex = 2*f,
                       fontfamily = "LM Roman 10"),
           sp.layout = list(North, scale1, s1_text0, s1_text1, s1_text2, s1_text3)) +
  latticeExtra::layer_(sp::sp.polygons(ca_aea, fill = "grey80"))
grid::grid.text("number of coyotes tested",
                x = grid::unit(0.5, "npc"),
                y = grid::unit(0.02, "npc"),
                gp = grid::gpar(fontsize = 12*f, fontfamily = "LM Roman 10"))
grDevices::dev.off()

grDevices::png(file = "figures/Supplemental1B.png", width = 400*f, height = 525*f)
graphics::par(family = "LM Roman 10", mar = c(5, 1, 4, 1) + 0.1)
sp::spplot(obj = ca_aea, 
           zcol = "prev", 
           col.regions = palB,
           par.settings = list(axis.line = list(col =  "transparent")),
           colorkey = list(space = "bottom",
                           width = 0.5*f,
                           height = 0.2*f,
                           labels = list(cex = 1*f,
                                         fontfamily = "LM Roman 10",
                                         fontface = 1,
                                         at = customat1,
                                         labels = customlabs1)),
           main = list(label = "(b)",
                       cex = 2*f,
                       fontfamily = "LM Roman 10"),
           sp.layout = list(North, scale1, s1_text0, s1_text1, s1_text2, s1_text3)) +
  latticeExtra::layer_(sp::sp.polygons(ca_aea, fill = "grey80"))
grid::grid.text(substitute(paste(italic("Yersinia pestis"), " seroprevalence (%)")),
                x = grid::unit(0.5, "npc"),
                y = grid::unit(0.02, "npc"),
                gp = grid::gpar(fontsize = 12*f, fontfamily = "LM Roman 10"))
grDevices::dev.off()

# -------------------------- END OF CODE -------------------------- #
