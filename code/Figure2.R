# ----------------------------------------------------------------------------------------------- #
# Manuscript Figure 2
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
# B) 2022/06/29 - Changed color of 'sparse data' from black to white
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

# Color Selection
plot.cols <- c('gold', 'blue3', 'cornflowerblue', 'grey80', 'firebrick1', 'firebrick4')

# Custom Legend
ticks <- c(
  minmax(predict_risk_reclass)[1],
  minmax(predict_risk_reclass)[1] / 2,
  0,
  minmax(predict_risk_reclass)[2] / 2,
  minmax(predict_risk_reclass)[2]
)
tick_labels <- c(expression(''<='-2.83'), '-1.41', '0', '1.41', '2.83')

# -------- #
# FIGURE 2 #
# -------- #

main_p <- ggplot() +
  geom_sf(
    data = pacs_proj[pacs_proj$NAME_1 != 'California'],
    fill = 'grey90', 
    color = 'white', 
    linetype = 1, 
    linewidth = 2
  ) +
  geom_sf(
    data = mx %>% project(crs(pacs_proj)), 
    fill = 'grey90', 
    color = 'white', 
    linetype = 1, 
    linewidth = 2
  ) +
  geom_spatraster(data = predict_risk_reclass, aes(fill = last)) +
  scale_fill_gradient2(
    low = plot.cols[2],
    mid = plot.cols[4],
    high = plot.cols[6],
    na.value = 'transparent',
    limits = c(minmax(predict_risk_reclass)),
    breaks = round(ticks, digits = 1),
    guide = guide_colorbar(order = 1),
    labels = tick_labels
  ) +
  labs(fill = expression('log'~hat('RR')['coyote+'])) +
  new_scale_fill() +
  geom_spatraster(data = reclass_naband, aes(fill = value), na.rm = TRUE) +
  scale_fill_manual(
    values = plot.cols[1], 
    na.value = 'transparent', 
    na.translate = FALSE, 
    guide = guide_legend(order = 2)
  ) +
  geom_sf(data = na_risk, aes(color = 'black'), fill = 'transparent') +
  scale_color_manual(
    values = c('black', 'white'),
    labels = c('sparse coyote data', 'state boundary'),
    na.value = 'transparent',
    guide = guide_legend(order = 3)
  ) +
  geom_sf(data = CA_proj, fill = 'transparent', aes(color = 'white'), linetype = 1, size = 4) +
  labs(color = '', fill = '', value = '') +
  guides(
    color = guide_legend(
      override.aes = list(fill = c('transparent', 'grey90'))
    )
  ) +
  coord_sf(
    xlim = ext(predict_risk_reclass)[1:2], ylim = ext(predict_risk_reclass)[3:4], expand = TRUE
  ) +
  theme_minimal() +
  theme(
    legend.position = 'right',
    legend.spacing.y = unit(-0.8, 'cm'),
    legend.box.background = element_rect(fill = 'grey90', color = 'black'),
    text = element_text(family = 'LM Roman 10')
  ); main_p

ggsave(
  file = file.path('figures', 'Figure2.png'),
  plot = main_p,
  height = 8,
  width = 8.5,
  dpi = 500,
  device = png
)

# ----------------------------------------- END OF CODE ----------------------------------------- #
