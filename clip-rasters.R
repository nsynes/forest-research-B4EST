library(raster)
library(rgdal)


wd <- 'C:/dev/ForestResearch/forest-research-B4EST/data'

dirInputRasters <- file.path(wd, 'Norway-Sweden-Finland')
dirOutput <- file.path(wd, 'Norway-Sweden-Finland', 'clipped')
dir.create(dirOutput)

# Specify countries to clip by
# These should be part of the EU shapefile below
countries <- c('Norway', 'Sweden', 'Finland')



euShp <- readOGR(dsn=file.path(wd,'Prof.Hamann_Reference_Files_1km_EU'), layer='EU_Outline_Albers')
focalShp <- subset(euShp,euShp@data$NAME %in% countries)
exampleRaster <- stack(file.path(dirInputRasters, sprintf('y%s_dwnTS.tif', 1901)))
focalShp <- spTransform(focalShp, crs(exampleRaster))


##################
# Clip the climate data based on country boundaries
##################
for (year in c(1901:2098)) {
  print(sprintf('Year: %s', year))

  climateStack <- stack(file.path(dirInputRasters, sprintf('y%s_dwnTS.tif', year)))
  climateStack <- mask(climateStack, focalShp)
  writeRaster(climateStack, file.path(dirOutput, sprintf('y%s.tif', year)))
}
##################
##################

