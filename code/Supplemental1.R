# --------------------------------------------------------------------------------- #
# Manuscript Supplemental Figure 1
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
# B) 2022-06-29 (@idblr): Suppress counties with n<15 coyote observations
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

ca_coyote <- ca

# Count samples per county
ca_coyote$Freq <- colSums(
  st_intersects(cdph_coyote_sp, st_as_sf(ca_coyote), sparse = FALSE)
)

# Restrict to counties with at least 15 coyotes
ca_coyote$Freq15 <- ifelse(ca_coyote$Freq < 15, NA, ca_coyote$Freq)
customlabs <- c('15', '200', '400', '600', '800', '1,000', '1,200', '1,400')
customat <- c(15, 200, 400, 600, 800, 1000, 1200, 1400)

# Prevalence per county
ca_coyote$pos <- colSums(
  st_intersects(
    cdph_coyote_sp[cdph_coyote_sp$Res == 'POS', ],
    st_as_sf(ca_coyote),
    sparse = FALSE
  )
)
ca_coyote$pos[is.na(ca_coyote$pos)] <- 0
ca_coyote$prev <- round(ca_coyote$pos / ca_coyote$Freq15, digits = 2)*100
customlabs1 <- c('0.0', '10.0', '20.0', '30.0', '40.0')
customat1 <- c(0, 10.0, 20.0, 30.0, 40.0)

# Create Plot
ca_aea <- st_transform(st_as_sf(ca_coyote), crs = 26910) # NAD83/UTM Zone 10N 
ca_aea <- as(ca_aea, 'Spatial')
# ca_aea@data$id <- rownames(ca_aea@data)

# NAD83/UTM Zone 10N
ca_buffer_aea <- as(st_transform(st_as_sf(ca_buffer), crs = 26910), 'Spatial') 

# Add north arrow
North <- list(
  'SpatialPolygonsRescale',
  layout.north.arrow(type = 1),
  offset = c(extent(ca_buffer_aea)[1] + 20000, extent(ca_buffer_aea)[3] + 10000),
  scale = 100000
)

# Add scale bar
scale1 <- list(
  'SpatialPolygonsRescale',
  layout.scale.bar(),
  offset = c(extent(ca_buffer_aea)[1] + 100000, extent(ca_buffer_aea)[3] + 30000),
  scale = 200000,
  fill = c('transparent', 'black')
)
s1_text0 <- list(
  'sp.text',
  c(extent(ca_buffer_aea)[1] + 100000, extent(ca_buffer_aea)[3] + 50000),
  '0',
  cex = 2,
  fontfamily = 'LM Roman 10'
)
s1_text1 <- list(
  'sp.text',
  c(extent(ca_buffer_aea)[1] + 300000, extent(ca_buffer_aea)[3] + 50000),
  '200',
  cex = 2,
  fontfamily = 'LM Roman 10'
)
s1_text2 <- list(
  'sp.text',
  c(extent(ca_buffer_aea)[1] + 200000, extent(ca_buffer_aea)[3] + 50000),
  '100',
  cex = 2,
  fontfamily = 'LM Roman 10'
)
s1_text3 <- list(
  'sp.text',
  c(extent(ca_buffer_aea)[1] + 200000, extent(ca_buffer_aea)[3] + 20000),
  'km',
  cex = 2,
  fontfamily = 'LM Roman 10'
)

# Color Palettes
palA <- colorRampPalette(brewer.pal(n = 9, name = 'YlGn'))(16)
palB <- colorRampPalette(brewer.pal(n = 9, name = 'YlOrRd'))(16)

# ---------------------- #
# SUPPLEMENTAL FIGURE 1A #
# ---------------------- #

f <- 4 # Graphical expansion factor

png(
  file = file.path('figures', 'SupplementalFigure1A.png'), 
  width = 400*f, 
  height = 525*f
)
par(family = 'LM Roman 10', mar = c(5, 1, 4, 1) + 0.1)
spplot(
  obj = ca_aea,
  zcol = 'Freq15',
  col.regions = palA,
  par.settings = list(axis.line = list(col =  'transparent')),
  colorkey = list(
    space ='bottom',
    width = 0.5*f,
    height = 0.2*f,
    labels = list(cex = 1*f,
                  fontfamily = 'LM Roman 10',
                  fontface = 1,
                  at = customat,
                  labels = customlabs)
  ),
  main = list(label = '(a)', cex = 2*f, fontfamily = 'LM Roman 10'),
  sp.layout = list(North, scale1, s1_text0, s1_text1, s1_text2, s1_text3)
) +
  layer_(sp.polygons(ca_aea, fill = 'grey80'))
grid.text(
  'number of coyotes tested',
  x = unit(0.5, 'npc'),
  y = unit(0.02, 'npc'),
  gp = gpar(fontsize = 12*f, fontfamily = 'LM Roman 10')
)
dev.off()

# ---------------------- #
# SUPPLEMENTAL FIGURE 1B #
# ---------------------- #

png(
  file = file.path('figures', 'SupplementalFigure1B.png'), 
  width = 400*f, 
  height = 525*f
)
par(family = 'LM Roman 10', mar = c(5, 1, 4, 1) + 0.1)
spplot(
  obj = ca_aea, 
  zcol = 'prev', 
  col.regions = palB,
  par.settings = list(axis.line = list(col =  'transparent')),
  colorkey = list(
    space = 'bottom',
    width = 0.5*f,
    height = 0.2*f,
    labels = list(cex = 1*f,
                  fontfamily = 'LM Roman 10',
                  fontface = 1,
                  at = customat1,
                  labels = customlabs1)
  ),
  main = list(label = '(b)', cex = 2*f, fontfamily = 'LM Roman 10'),
  sp.layout = list(North, scale1, s1_text0, s1_text1, s1_text2, s1_text3)
) +
  layer_(sp.polygons(ca_aea, fill = 'grey80'))
grid.text(
  substitute(paste(italic('Yersinia pestis'), ' seroprevalence (%)')),
  x = unit(0.5, 'npc'),
  y = unit(0.02, 'npc'),
  gp = gpar(fontsize = 12*f, fontfamily = 'LM Roman 10')
)
dev.off()

# ---------------------------------- END OF CODE ---------------------------------- #
