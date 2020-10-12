library(raster)
library(rgdal)
library(ggplot2)
library(directlabels)
library(rasterVis)


wd <- 'C:/dev/ForestResearch/forest-research-B4EST/data'
dirInput <- file.path(wd, 'Norway-Sweden-Finland') # Input folder should contain the exceedance rasters, as created by 'calculate-indices.R' script
dirOut <- file.path(wd, 'exceedance-plots')
dir.create(dirInput)
dir.create(dirOut)


createPlots <- function(dirInput, dirOut, rasterName, exceedanceVal, plotTitle) {
  print(plotTitle)

  euShp <- readOGR(dsn=file.path(wd,'Prof.Hamann_Reference_Files_1km_EU'), layer='EU_Outline_Albers')
  exampleRaster <- stack(file.path(dirInput, 'Tmax-20C-ExceedanceFrequency1981-1990.tif'))
  euShp <- spTransform(euShp, crs(exampleRaster))

  df <- data.frame()
  rasterList <- c()
  for (endYear in c(2010,2030,2050,2070,2090))
    print(sprintf('endYear: %s', endYear))

    startYear <- endYear - 9
    rasterFullName <- sprintf('%s%s-%s.tif', sprintf(rasterName, exceedanceVal), startYear, endYear)
    rasterPath <- file.path(dirInput, rasterFullName)
    rasterList <- c(rasterList, rasterPath)
    rst <- raster(rasterPath)


    for (country in c('Norway', 'Sweden', 'Finland')) {
      focalCountry <- subset(euShp,euShp@data$NAME == country)
      countryRst <- mask(rst, focalCountry)

      meanVal <- cellStats(countryRst, 'mean')
      minVal <- cellStats(countryRst, 'min')
      maxVal <- cellStats(countryRst, 'max')
      df <- rbind(df, data.frame(year=endYear-5, country=country, var='mean', value=meanVal, min=minVal, max=maxVal))
      df <- rbind(df, data.frame(year=endYear-5, country=country, var='min', value=minVal, min=NA, max=NA))
      df <- rbind(df, data.frame(year=endYear-5, country=country, var='max', value=maxVal, min=NA, max=NA))

    }
  }


  focalCountries <- subset(euShp,euShp@data$NAME %in% c('Norway', 'Sweden', 'Finland'))

  cols <- colorRampPalette(brewer.pal(10,"Purples"))
  rstStack <- stack(rasterList)
  rasterNames <- gsub(gsub('-', '.', sprintf(rasterName, exceedanceVal)), "", names(rstStack))
  rasterNames <- gsub("\\.","-", rasterNames)
  p1 <- levelplot(rstStack,
            main=sprintf(plotTitle, exceedanceVal),
            col.regions=cols,
            scales=list(draw=FALSE),
            names.attr=rasterNames) + layer(sp.polygons(focalCountries))

  png(file.path(dirOut, sprintf('%s-map.png', sprintf(rasterName, exceedanceVal))), width=2000, height=1400, units='px', res=300)
  print(p1)
  dev.off()


  p2 <- ggplot(data=df, aes(x=year, y=value, group=var)) +
    facet_wrap(~country) +
    geom_ribbon(aes(x=year, ymin=min, ymax=max), fill = "#3f007d", alpha=0.3) +
    geom_line(size=1) +
    geom_dl(aes(label = var), method = list(dl.trans(x = x + .1), "last.points", cex = 0.5)) +
    scale_x_continuous(expand = c(0.05, 0,0.3,0)) +
    labs(y='frequency', title=sprintf(plotTitle, exceedanceVal)) +
    theme_bw() +
    theme(strip.text = element_text(face = "bold"),
          axis.text.x=element_text(angle=90, vjust=0.5))

  ggsave(file.path(dirOut, sprintf('%s-graph.png', sprintf(rasterName, exceedanceVal))), p2, width=12, height=8, dpi=300, units='cm')

}


createPlots(dirInput, dirOut, 'Tmax-%sC-ExceedancePercentage', 20, 'Tmax Exceedance, %s�C\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'Tmax-%sC-ExceedancePercentage', 25, 'Tmax Exceedance, %s�C\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'Tmax-%sC-ExceedancePercentage', 30, 'Tmax Exceedance, %s�C\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'Tmin-%sC-ExceedancePercentage', 0, 'Tmin Exceedance, Dec-Feb, %s�C\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-Drought-Apr-Oct-%smm-ExceedancePercentage', 150, 'Low Precipitation, Apr-Oct, <%smm\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-Drought-Apr-Oct-%smm-ExceedancePercentage', 200, 'Low Precipitation, Apr-Oct, <%smm\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-Drought-Apr-Oct-%smm-ExceedancePercentage', 300, 'Low Precipitation, Apr-Oct, <%smm\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-Drought-Apr-Oct-%smm-ExceedancePercentage', 400, 'Low Precipitation, Apr-Oct, <%smm\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-WaterLogging-Sep-Feb-%smm-ExceedancePercentage', 600, 'High Precipitation, Sep-Feb, >%smm\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-WaterLogging-Sep-Feb-%smm-ExceedancePercentage', 800, 'High Precipitation, Sep-Feb, >%smm\n(frequency of exceedance)')
createPlots(dirInput, dirOut, 'PrecSum-WaterLogging-Sep-Feb-%smm-ExceedancePercentage', 1000, 'High Precipitation, Sep-Feb, >%smm\n(frequency of exceedance)')

