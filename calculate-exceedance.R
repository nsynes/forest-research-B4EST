library(raster)
library(rgdal)


wd <- 'C:/dev/ForestResearch/forest-research-B4EST/data'

dirInputRasters <- file.path(wd, 'Norway-Sweden-Finland')
dirOutput <- file.path(wd, 'Norway-Sweden-Finland', 'exceedance')
dir.create(dirOutput)


##################
# Max Temperature Exceedance
##################
for (exceedanceVal in c(15, 20, 25, 30)) { # Set exceedance values to use here
  for (year in c(c(1981:2090))) {
    print(sprintf('Tmax Exceedance. Temperature: %sC; Year: %s', exceedanceVal, year))

    if (year %% 10 == 1) {
      decadeExceedance12 <- stack()
      startYear <- year
    }
    climateStack <- stack(file.path(dirInputRasters, sprintf('y%s.tif', year)))

    # All 12 months
    tmax12 <- subset(climateStack, 13:24) / 10
    monthlyExceedance12 <- tmax12
    values(monthlyExceedance12)[!is.na(values(monthlyExceedance12))] <- 0
    monthlyExceedance12[tmax12 >= exceedanceVal] <- 1
    annualExceedance12 <- calc(monthlyExceedance12, sum)
    decadeExceedance12 <- addLayer(decadeExceedance12, annualExceedance12)


    # Once we have a decade of exceedance frequency data, sum it and export the raster
    if ( nlayers(decadeExceedance12) == 10 ) {

      # All 12 months
      decadeExceedance12 <- calc(decadeExceedance12, sum)
      writeRaster(decadeExceedance12, file.path(dirOutput, sprintf('Tmax-%sC-ExceedanceFrequency%s-%s.tif', exceedanceVal, startYear, year)))
      writeRaster(decadeExceedance12/(10*12), file.path(dirOutput, sprintf('Tmax-%sC-ExceedancePercentage%s-%s.tif', exceedanceVal, startYear, year)))
      decadeExceedance12 <- NA
    }
  }
}
##################
##################




##################
# Min Temperature Exceedance
##################
for (exceedanceVal in c(0, 5, 10)) { # Set exceedance values to use here
  for (year in c(c(1981:2090))) {
    print(sprintf('Tmin Exceedance. Temperature: %sC; Year: %s', exceedanceVal, year))

    if (year %% 10 == 1) {
      decadeExceedance12 <- stack()
      decadeExceedanceWinter <- stack()
      startYear <- year
    }
    climateStack <- stack(file.path(dirInputRasters, sprintf('y%s.tif', year)))

    # All 12 months
    tmin12 <- subset(climateStack, 1:12) / 10
    monthlyExceedance12 <- tmin12
    values(monthlyExceedance12)[!is.na(values(monthlyExceedance12))] <- 0
    monthlyExceedance12[tmin12 <= exceedanceVal] <- 1
    annualExceedance12 <- calc(monthlyExceedance12, sum)
    decadeExceedance12 <- addLayer(decadeExceedance12, annualExceedance12)

    # Winter months
    tminWinter <- subset(climateStack, c(1,2,12)) / 10
    monthlyExceedanceWinter <- tminWinter
    values(monthlyExceedanceWinter)[!is.na(values(monthlyExceedanceWinter))] <- 0
    monthlyExceedanceWinter[tminWinter <= exceedanceVal] <- 1
    annualExceedanceWinter <- calc(monthlyExceedanceWinter, sum)
    decadeExceedanceWinter <- addLayer(decadeExceedanceWinter, annualExceedanceWinter)


    # Once we have a decade of exceedance frequency data, sum it and export the raster
    if ( nlayers(decadeExceedance12) == 10 ) {

      # All 12 months
      decadeExceedance12 <- calc(decadeExceedance12, sum)
      writeRaster(decadeExceedance12, file.path(dirOutput, sprintf('Tmin-%sC-ExceedanceFrequency%s-%s.tif', exceedanceVal, startYear, year)))
      writeRaster(decadeExceedance12/(10*12), file.path(dirOutput, sprintf('Tmin-%sC-ExceedancePercentage%s-%s.tif', exceedanceVal, startYear, year)))
      decadeExceedance12 <- NA

      # Winter months
      decadeExceedanceWinter <- calc(decadeExceedanceWinter, sum)
      writeRaster(decadeExceedanceWinter, file.path(dirOutput, sprintf('Tmin-%sC-Dec-FebExceedanceFrequency%s-%s.tif', exceedanceVal, startYear, year)))
      writeRaster(decadeExceedanceWinter/(10*3), file.path(dirOutput, sprintf('Tmin-%sC-Dec-FebExceedancePercentage%s-%s.tif', exceedanceVal, startYear, year)))
      decadeExceedanceWinter <- NA
    }
  }
}
##################
##################





##################
# Accumulated Precipitation Exceedance - Summer drought
##################
for (exceedanceVal in c(400)) { # Set exceedance values to use here
  for (year in c(c(1981:2090))) {
    print(sprintf('Accumulated Precipitation Exceedance - Summer drought. threshold: %smm; Year: %s', exceedanceVal, year))

    if (year %% 10 == 1) {
      decadeExceedance <- stack()
      startYear <- year
    }
    climateStack <- stack(file.path(dirInputRasters, sprintf('y%s.tif', year)))

    SummerPrec <- subset(climateStack, 24+4:10) / 10
    SummerPrecAccum <- calc(SummerPrec, sum)
    SummerPrecAccumExceedance <- SummerPrecAccum
    values(SummerPrecAccumExceedance)[!is.na(values(SummerPrecAccumExceedance))] <- 0
    SummerPrecAccumExceedance[SummerPrecAccum <= exceedanceVal] <- 1
    decadeExceedance <- addLayer(decadeExceedance, SummerPrecAccumExceedance)


    # Once we have a decade of exceedance frequency data, sum it and export the raster
    if ( nlayers(decadeExceedance) == 10 ) {

      decadeExceedance <- calc(decadeExceedance, sum)
      writeRaster(decadeExceedance, file.path(dirOutput, sprintf('PrecSum-Drought-Apr-Oct-%smm-ExceedanceFrequency%s-%s.tif', exceedanceVal, startYear, year)))
      writeRaster(decadeExceedance/10, file.path(dirOutput, sprintf('PrecSum-Drought-Apr-Oct-%smm-ExceedancePercentage%s-%s.tif', exceedanceVal, startYear, year)))
      decadeExceedance <- NA
    }
  }
}
##################
##################




##################
# Accumulated Precipitation Exceedance - Summer monthly drought
##################
for (exceedanceVal in c(20, 10, 5)) { # Set exceedance values to use here
  for (year in c(c(1981:2090))) {
    print(sprintf('Accumulated Precipitation Exceedance - Summer monthly drought. threshold: %smm; Year: %s', exceedanceVal, year))

    if (year %% 10 == 1) {
      decadeExceedance <- stack()
      startYear <- year
    }
    climateStack <- stack(file.path(dirInputRasters, sprintf('y%s.tif', year)))

    SummerPrec <- subset(climateStack, 24+4:10) / 10
    SummerPrecMonthlyExceedance <- SummerPrec
    values(SummerPrecMonthlyExceedance)[!is.na(values(SummerPrecMonthlyExceedance))] <- 0
    SummerPrecMonthlyExceedance[SummerPrec <= exceedanceVal] <- 1
    annualExceedance <- calc(SummerPrecMonthlyExceedance, sum)
    decadeExceedance <- addLayer(decadeExceedance, annualExceedance)


    # Once we have a decade of exceedance frequency data, sum it and export the raster
    if ( nlayers(decadeExceedance) == 10 ) {

      decadeExceedance <- calc(decadeExceedance, sum)
      writeRaster(decadeExceedance, file.path(dirOutput, sprintf('Prec-Monthly-Drought-Apr-Oct-%smm-ExceedanceFrequency%s-%s.tif', exceedanceVal, startYear, year)))
      writeRaster(decadeExceedance/(10*7), file.path(dirOutput, sprintf('Prec-Monthly-Drought-Apr-Oct-%smm-ExceedancePercentage%s-%s.tif', exceedanceVal, startYear, year)))
      decadeExceedance <- NA
    }
  }
}
##################
##################





##################
# Accumulated Precipitation Exceedance - Winter water logging
##################
for (exceedanceVal in c(600, 800, 1000)) { # Set exceedance values to use here
  for (year in c(c(1981:2090))) {
    print(sprintf('Accumulated Precipitation Exceedance - Summer drought. threshold: %smm; Year: %s', exceedanceVal, year))

    if (year %% 10 == 1) {
      decadeExceedance <- stack()
      startYear <- year
    }
    climateStack <- stack(file.path(dirInputRasters, sprintf('y%s.tif', year)))

    WinterPrec <- subset(climateStack, 24+c(1,2,9,10,11,12)) / 10
    WinterPrecAccum <- calc(WinterPrec, sum)
    WinterPrecAccumExceedance <- WinterPrecAccum
    values(WinterPrecAccumExceedance)[!is.na(values(WinterPrecAccumExceedance))] <- 0
    WinterPrecAccumExceedance[WinterPrecAccum >= exceedanceVal] <- 1
    decadeExceedance <- addLayer(decadeExceedance, WinterPrecAccumExceedance)


    # Once we have a decade of exceedance frequency data, sum it and export the raster
    if ( nlayers(decadeExceedance) == 10 ) {

      decadeExceedance <- calc(decadeExceedance, sum)
      writeRaster(decadeExceedance, file.path(dirOutput, sprintf('PrecSum-WaterLogging-Sep-Feb-%smm-ExceedanceFrequency%s-%s.tif', exceedanceVal, startYear, year)))
      writeRaster(decadeExceedance/10, file.path(dirOutput, sprintf('PrecSum-WaterLogging-Sep-Feb-%smm-ExceedancePercentage%s-%s.tif', exceedanceVal, startYear, year)))
      decadeExceedance <- NA
    }
  }
}
##################
##################


