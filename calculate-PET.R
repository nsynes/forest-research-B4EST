library(raster)
library(rgdal)
library(SPEI)
library(zoo)


inputDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m'
radiationDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/ExtSolarRad_UK_250m'
outputDir <- 'C:/dev/ForestResearch/forest-research-B4EST/data/UKCP18-1km_UK_250m-PET'

rasterOptions(maxmemory = 8e9) # 8GB maximum memory for the raster package

##################
# Hargreaves Potential Evapotranspiration
# based on Droogers and Allen (2001) Estimating reference evapotranspiration under inaccurate data conditions.
# Equation 5, the modified Hargreaves equatiuon for monthly data.
# This is the same equation used by SPEI:: hargreaves
# PET = 0.0013 x 0.408RA x (Tavg + 17.0) x (TD - 0.0123P)**0.76
##################

climateStack <- stack(file.path(inputDir, 'y1901_dwnTS.tif')) / 10 # All this data (including prec) is stored as 10* the value
radiation <- stack(file.path(radiationDir, sprintf('esr%02d.tif', 1:12)))
radiation <- projectRaster(radiation, crs=crs(climateStack))
radiation <- crop(radiation, climateStack)
radiation <- resample(radiation, climateStack)


for (year in c(1901:2080)) {
  print(sprintf('PET year: %s', year))

  climateStack <- stack(file.path(inputDir, sprintf('y%s_dwnTS.tif', year))) / 10 # All this data (including prec) is stored as 10* the value

  tmin <- subset(climateStack, 1:12)
  tmax <- subset(climateStack, 13:24)
  prec <- subset(climateStack, 25:36)
  climateStack <- NULL

  PET <- 0.0013 * 0.408 * radiation * (0.5*(tmax + tmin) + 17.0) * ((tmax - tmin) - (0.0123 * prec))**0.76

  # Multiply by days in month
  PET <- PET * c(31,28,31,30,31,30,31,31,30,31,30,31)

  writeRaster(PET, file.path(outputDir, sprintf('PET-y%s.tif', year)))
}

##################
##################



##################
# SPEI: Hargreaves Potential Evapotranspiration
# Note: we have not used this version as it is very slow
##################
if (FALSE) { # Stop the code below from running, unless specifically selected

har <- function(Tmin, Tmax, Lat, Prec) {
  return(as.vector(SPEI::hargreaves(Tmin=Tmin, Tmax=Tmax, lat=Lat, Pre=Prec, na.rm=TRUE)))
}

for (year in c(2010,2050,2080)) {
  print(sprintf('Year: %s;', year))

  climateStack <- stack(file.path(inputDir, sprintf('y%s_dwnTS.tif', year)))

  tmin <- subset(climateStack, 1)/10
  lat <- init(projectRaster(tmin, crs=CRS("+proj=longlat +datum=WGS84")), 'y')
  lat <- projectRaster(lat, crs=crs(tmin))
  lat <- resample(lat, tmin, method='ngb')


  tmin <- subset(climateStack, 1:12)/10
  tmax <- subset(climateStack, 13:24)/10
  prec <- subset(climateStack, 25:36)/10 # This data is stored as 10 * mm

  dates<-seq(as.Date(sprintf("%s-01-01", year)), as.Date(sprintf("%s-12-01", year)), by='month')
  tmin <- setZ(tmin, dates)
  names(tmin) <- as.yearmon(getZ(tmin))
  tmax <- setZ(tmax, dates)
  names(tmax) <- as.yearmon(getZ(tmax))
  prec <- setZ(prec, dates)
  names(prec) <- as.yearmon(getZ(prec))

  output <- raster::overlay(tmin, tmax, lat, prec, fun = Vectorize(har))

  writeRaster(output, file.path(outputDir, sprintf('PET-%s.tif', year)))

}

}