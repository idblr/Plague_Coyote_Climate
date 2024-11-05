# --------------------------------------------------------------------------------- #
# Manuscript Figure 3
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
### R) 'reclass_tol' a 'raster' of log RR_[coyote+] significant levels at two-tailed alpha levels in 'geographic space' at UTM10N

source(file.path('code', 'Preparation.R'))

# -------------- #
# POSTPROCESSING #
# -------------- #

# Color Selection
plot.cols <- c(
  'gold', 'blue3', 'cornflowerblue', 'grey80', 'firebrick1', 'firebrick4'
)

# -------- #
# FIGURE 3 #
# -------- #

main_p <- ggplot() +
  geom_sf(
    data = pacs_proj[pacs_proj$NAME_1 != 'California'],
    fill = 'grey90',
    color = 'white',
    linetype = 1,
    linewidth = 2) +
  geom_sf(
    data = mx %>% project(crs(pacs_proj)),
    fill = 'grey90',
    color = 'white',
    linetype = 1,
    linewidth = 2
  ) +
  geom_spatraster(data = reclass_tol, aes(fill = last)) +
  scale_fill_manual(
    values = rev(plot.cols[-1]),
    na.value = 'transparent',
    na.translate = FALSE,
    labels = c(
      expression(''<'0.005'),
      '0.005-0.024',
      '0.025-0.975',
      '0.976-0.995', 
      expression(''>'0.995')
    ),
    guide = guide_legend(order = 1),
  ) +
  labs(fill = 'p-value') +
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
  geom_sf(
    data = CA_proj, 
    fill = 'transparent', 
    aes(color = 'white'), 
    linetype = 1, 
    size = 4
  ) +
  labs(color = '', fill = '', value = '') +
  guides(
    color = guide_legend(override.aes = list(fill = c('transparent', 'grey90')))
  ) +
  coord_sf(
    xlim = ext(predict_risk_reclass)[1:2], 
    ylim = ext(predict_risk_reclass)[3:4], 
    expand = TRUE
  ) +
  theme_minimal() +
  theme(
    legend.position = 'right',
    legend.spacing.y = unit(-0.8, 'cm'),
    legend.box.background = element_rect(fill = 'grey90', color = 'black'),
    text = element_text(family = 'LM Roman 10')
  ); main_p

ggsave(
  file = file.path('figures', 'Figure3.png'),
  plot = main_p,
  height = 8,
  width = 8.5,
  dpi = 500,
  device = png
)

# ---------------------------------- END OF CODE ---------------------------------- #
