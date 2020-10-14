library(raster)
library(rgdal)


inputDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m'
cmdDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m-CMD'
outputDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m-CMD-adjusted'




##################
# Climate moisture deficit adjustment for ESC
##################
for (year in 2043:2098) {
  print(sprintf('CMD adjusted: %s', year))

  cmdStack <- stack(file.path(cmdDir, sprintf('CMD-y%s.tif', year)))

  cmdStack <- (0.001122538031826*(cmdStack**2)) - (0.076065599431247*cmdStack) + 0.84649766994116

  writeRaster(cmdStack, file.path(outputDir, sprintf('CMD-y%s.tif', year)))

}
