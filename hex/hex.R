# ------------------------------------------------------------------------------ #
# Hex Sticker for the GitHub Repository idblr/Plague_Coyote_Climate
# ------------------------------------------------------------------------------ #
#
# Created by: Ian Buller, Ph.D., M.A. (GitHub: @idblr)
# Created on: May 19, 2022
#
# Recently modified by: @idblr
# Recently modified on: November 22, 2022
#
# Notes:
# A) Uses the "hexSticker" package
# B) Modified image from a companion manuscript figure
# D) Hex sticker for the GitHub Repository https://github.com/idblr/Plague_Coyote_Climate
# ------------------------------------------------------------------------------ #

############
# PACKAGES #
############

loadedPackages <- c("hexSticker", "sf", "tigris")
suppressMessages(invisible(lapply(loadedPackages, require, character.only = TRUE)))
options(tigris_use_cache = T)

############################################
# GENERATE GEOGRAPHIC COMPONENT OF SUBPLOT #
############################################ 

shp_state <- suppressMessages(tigris::states(year = 2018, class = "sf", cb = TRUE))
ca_state <- shp_state[shp_state$NAME == "California", ]
ca <- ggplot2::ggplot() + 
  ggplot2::geom_sf(data = sf::st_geometry(ca_state), fill = "grey80") +
  ggplot2::theme_void()
ggplot2::ggsave("hex/subplot/CA.png", ca, bg = "transparent")

# Image file
path_image <- "hex/subplot/subplot.png"

########################
# GENERATE HEX STICKER #
########################

s <- hexSticker::sticker(subplot = path_image,
                         package = "Climatic Niche\nof Plague\nin California\nCoyotes",
                         p_size = 2.85, p_x = 1.4, p_y = 1, p_color = "#FEF733", # title
                         s_x = 0.6, s_y = 0.85, s_width = 0.6, s_height = 0.6, # symbol
                         h_fill = "#4472C4", # inside
                         h_color = "#C00200", # outline
                         dpi = 1000, # resolution
                         filename = "hex/hex.png",
                         white_around_sticker = F)

# -------------------------------- END OF CODE --------------------------------- #
