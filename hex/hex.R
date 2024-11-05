# --------------------------------------------------------------------------------- #
# Hex Sticker for the GitHub Repository idblr/Plague_Coyote_Climate
# --------------------------------------------------------------------------------- #
#
# Created by: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Created on: 2022-05-20
#
# Most recently modified by: @idblr
# Most recently modified on: 2024-08-06
#
# Notes:
# A) Uses the 'hexSticker' package
# B) Modified image from a companion manuscript figure
# D) Hex sticker for the GitHub Repository:
#    https://github.com/idblr/Plague_Coyote_Climate
# --------------------------------------------------------------------------------- #

# --------- #
# LIBRARIES #
# --------- #

loadedPackages <- c('ggplot2', 'hexSticker', 'sf', 'tigris')
suppressMessages(invisible(lapply(loadedPackages, require, character.only = TRUE)))
options(tigris_use_cache = T)

# ---------------------------------------- #
# GENERATE GEOGRAPHIC COMPONENT OF SUBPLOT #
# ---------------------------------------- #

shp_state <-
  suppressMessages(states(year = 2018, class = 'sf', cb = TRUE))
ca_state <- shp_state[shp_state$NAME == 'California',]
ca <- ggplot() +
  geom_sf(
    data = st_geometry(ca_state), 
    fill = 'grey80'
  ) +
  theme_void()
ggsave(
  filename = file.path('hex', 'subplot', 'CA.png'),
  flot = ca,
  bg = 'transparent'
)

# Image file
path_image <- file.path('hex', 'subplot', 'subplot.png')

# -------------------- #
# GENERATE HEX STICKER #
# -------------------- #

s <- sticker(
  subplot = path_image,
  package = 'Climatic Niche\nof Plague\nin California\nCoyotes',
  p_size = 25,
  p_x = 1.45,
  p_y = 1,
  p_color = '#FEF733',
  lineheight = 0.1,
  # title
  s_x = 0.67,
  s_y = 0.85,
  s_width = 0.6,
  s_height = 0.6,
  # symbol
  h_fill = '#4472C4',
  # inside
  h_color = '#C00200',
  # outline
  dpi = 1000,
  # resolution
  filename = file.path('hex', 'hex.png'),
  white_around_sticker = FALSE
)

# ---------------------------------- END OF CODE ---------------------------------- #
