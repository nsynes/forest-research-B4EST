library(raster)
library(rgdal)


inputDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m'
petDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m-PET'
outputDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m-CMD'

rasterOptions(maxmemory = 8e9) # 8GB maximum memory for the raster package


##################
# Climate moisture deficit
##################
for (year in 1901:2080) {

  climateStack <- stack(file.path(inputDir, sprintf('y%s_dwnTS.tif', year)))

  prec <- subset(climateStack, 25:36)/10 # This data is stored as 10 * mm
  climateStack <- NULL

  PET <- stack(file.path(petDir, sprintf('PET-y%s.tif', year)))

  CMD <- PET - prec
  for (m in 1:12) {
    CMD[[m]][CMD[[m]] < 0] <- 0
  }

  writeRaster(CMD, file.path(outputDir, sprintf('CMD-y%s.tif', year)))

}
