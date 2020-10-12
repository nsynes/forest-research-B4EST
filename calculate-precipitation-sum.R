library(raster)
library(rgdal)


wd <- 'C:/dev/ForestResearch/forest-research-B4EST/data'

dirInputRasters <- file.path(wd, 'Norway-Sweden-Finland', '1961-2007')
dirOutput <- file.path(wd, 'Norway-Sweden-Finland')


##################
# SINGLE BAND RASTER INPUT - Precipitation Sum (Apr-Oct)
# Note - this is setup to calculate for a single year, or an average of years (whatever is in the 'dirInputRasters' directory)
##################

rstPath <- file.path(dirInputRasters, '1km_pre%02d.tif')

precSum <- raster(sprintf(rstPath, 4)) +
            raster(sprintf(rstPath, 5)) +
            raster(sprintf(rstPath, 6)) +
            raster(sprintf(rstPath, 7)) +
            raster(sprintf(rstPath, 8)) +
            raster(sprintf(rstPath, 9)) +
            raster(sprintf(rstPath, 10))

writeRaster(precSum, file.path(dirInputRasters, '1km_pre-sum_apr-oct.tif'))

##################
##################



##################
# MULTI BAND RASTER INPUT - Precipitation Sum (Apr-Oct)
##################
for (year in c(1901:2098)) {
  print(sprintf('precipitation sum. Year: %s', year))

  climateStack <- stack(file.path(dirInputRasters, sprintf('y%s_dwnTS.tif', year)))
  precSum <- climateStack[[28]] + climateStack[[29]] + climateStack[[30]] + climateStack[[31]] +
             climateStack[[32]] + climateStack[[33]] + climateStack[[34]]

  writeRaster(precSum, file.path(dirOutput, sprintf('prec-apr-oct_y%s.tif', year)))
}
##################
##################

