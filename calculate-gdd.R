library(raster)
library(rgdal)


wd <- 'C:/dev/ForestResearch/forest-research-B4EST/data'

dirInputRasters <- file.path(wd, 'Norway-Sweden-Finland', '1961-2007')
dirOutput <- file.path(wd, 'Norway-Sweden-Finland')

tbase <- 5 # Growing degree days base temperature in degrees C


##################
# SINGLE BAND RASTER INPUT - Growing Degree Days
# Note - this is setup to calculate for a single year, or an average of years (whatever is in the 'dirInputRasters' directory)
##################

tmin <- stack(paste(sprintf(file.path(dirInputRasters, '1km_tmn%02d.tif'), 1:12)))
tmax <- stack(paste(sprintf(file.path(dirInputRasters, '1km_tmx%02d.tif'), 1:12)))

monthlyGDD <- 0.5 * (tmax + tmin) - tbase
for (m in 1:12) {
  monthlyGDD[[m]][monthlyGDD[[m]] < 0] <- 0
}

annualGDD <- (monthlyGDD[[1]] * 31) +
  (monthlyGDD[[2]] * 28) +
  (monthlyGDD[[3]] * 31) +
  (monthlyGDD[[4]] * 30) +
  (monthlyGDD[[5]] * 31) +
  (monthlyGDD[[6]] * 30) +
  (monthlyGDD[[7]] * 31) +
  (monthlyGDD[[8]] * 31) +
  (monthlyGDD[[9]] * 30) +
  (monthlyGDD[[10]] * 31) +
  (monthlyGDD[[11]] * 30) +
  (monthlyGDD[[12]] * 31)

writeRaster(annualGDD, file.path(dirInputRasters, '1km_gdd5.tif'))

##################
##################


##################
# MULTI BAND RASTER INPUT - Growing Degree Days
##################
for (year in c(1901:2098)) {
  print(sprintf('Growing degree days. Year: %s', year))

  climateStack <- stack(file.path(dirInputRasters, sprintf('y%s_dwnTS.tif', year)))

  tmin <- subset(climateStack, 1:12) / 10
  tmax <- subset(climateStack, 13:24) / 10

  monthlyGDD <- 0.5 * (tmax + tmin) - tbase
  for (m in 1:12) {
    monthlyGDD[[m]][monthlyGDD[[m]] < 0] <- 0
  }

  annualGDD <- (monthlyGDD[[1]] * 31) +
                (monthlyGDD[[2]] * 28) +
                (monthlyGDD[[3]] * 31) +
                (monthlyGDD[[4]] * 30) +
                (monthlyGDD[[5]] * 31) +
                (monthlyGDD[[6]] * 30) +
                (monthlyGDD[[7]] * 31) +
                (monthlyGDD[[8]] * 31) +
                (monthlyGDD[[9]] * 30) +
                (monthlyGDD[[10]] * 31) +
                (monthlyGDD[[11]] * 30) +
                (monthlyGDD[[12]] * 31)

  writeRaster(annualGDD, file.path(dirOutput, sprintf('gdd5_y%s.tif', year)))
}
##################
##################

