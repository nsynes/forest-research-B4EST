##########################################################
wd<-'C:/dev/ForestResearch/forest-research-B4EST/data'

countries <- c('United Kingdom')
countryAbbrev <- 'UK'
##########################################################

outputDir <- file.path(wd,sprintf('UKCP18-1km_%s_250m', countryAbbrev))

###---load the downscaled UKCP18 5km dataset (or modified 12 km) for downscaling
###---and the DEM -> this to calculate the raster of lapse rates
library(raster)
dem<-raster(file.path(wd, 'Prof.Hamann_Reference_Files_1km_EU/Master_DEM.asc'))

ukcp6190 <- stack()
for (varN in 1:36) {
  print(varN)
  ukcpMonth <- stack(file.path(wd, 'UKCP18-60km_dwn_wcBSL_1km_UK', sprintf('y%s_dwnTS.tif', 1961:1990)), bands=varN)
  # Only divide temperature variables by 10. Precipitation is already in correct mm units.
  if (varN > 24) {
    ukcp6190 <- addLayer(ukcp6190, stackApply(ukcpMonth, fun = "mean", indices=1, na.rm = T))
  } else {
    ukcp6190 <- addLayer(ukcp6190, stackApply(ukcpMonth, fun = "mean", indices=1, na.rm = T)/10)
  }
}
ukcpMonth <- NA

ukcp6190 <- projectRaster(ukcp6190,crs=crs(dem))
as.character(crs(dem))==as.character(crs(ukcp6190)) #just a quick comparison

# Need to resample ukcp6190 based on the DEM  as the grids are misaligned
ukcp6190 <- resample(ukcp6190, dem, method='ngb')
writeRaster(ukcp6190, file.path(wd, 'ukcp6190_1km.tif'))

ukcp6190 <- stack(file.path(wd, 'ukcp6190_1km.tif'))

###---spatial extent for downscaling: for Deliverable 4.3 we will use Sweden and Norway only
library(rgdal)
eu<-readOGR(dsn=file.path(wd,'Prof.Hamann_Reference_Files_1km_EU'), layer='EU_Outline_Albers')
#plot(eu,axes=T)
tgt<-subset(eu,eu@data$NAME %in% countries)
#plot(tgt,axes=T)
tgt<-spTransform(tgt,crs(dem))
mk<-extent(tgt)*1.1

###---now we must crop the whole raster to focus countries
dem<-crop(dem,mk)

###---lapse rate rasters calculation
ukcp6190<-crop(ukcp6190,mk)
int<-ukcp6190
values(int)<-NA
int<-slp<-rsqrd<-stack(int)
cls<-I(1:ncell(ukcp6190))[-which(is.na(values(ukcp6190[[1]])))] #this to select only the cells where we have the value
length(cls) #number of pixels to be calculated



if (FALSE) {
for(i in cls) {
    cells9<-c(i-ncol(slp)-1,i-ncol(slp),i-ncol(slp)+1,i-1,i,i+1,i+ncol(slp)-1,i+ncol(slp),i+ncol(slp)+1) #here the 9 surrounding cells
    #-dynamic lapse rate with classic LM and 9 surrounding cells
    x<-as.vector(as.dist(outer(dem[cells9],dem[cells9],FUN='-')))
    y0<-ukcp6190[cells9]
    for(cVar in 1:36) {
      #cVar<-1
      y<-as.vector(as.dist(outer(y0[,cVar],y0[,cVar],FUN='-')))
      #plot(y~x)
      if(is.na(mean(y)) || is.na(mean(x))) {
        values(int[[cVar]])[i]<-0 #intercept
        values(slp[[cVar]])[i]<-0 #slope
        values(rsqrd[[cVar]])[i]<-0 #rsqrd
      } else {
        fn<-lm(y~x)
        #plot(y~x)
        #abline(fn)
        R2<-summary(fn)$r.squared
        if (is.nan(R2)) R2<-0
        values(int[[cVar]])[i]<-as.numeric(coef(fn)[1]) #as.numeric(round(coef(fn)[1],2)) #intercept
        values(slp[[cVar]])[i]<-as.numeric(coef(fn)[2]) #as.numeric(round(coef(fn)[2],4)) #slope
        values(rsqrd[[cVar]])[i]<-R2 #rsqrd

      }
    }
    print(paste('done -',round(which(cls==i)/length(cls)*100,2),'% completed'))
}
#-now we save the rasters
dir.create(outputDir, showWarnings = FALSE)
writeRaster(int,file.path(outputDir,'y6190int'), overwrite=T,progress='text',format='GTiff',bylayer=F)
writeRaster(slp,file.path(outputDir,'y6190slp'), overwrite=T,progress='text',format='GTiff',bylayer=F)
writeRaster(rsqrd,file.path(outputDir,'y6190rsqrd'), overwrite=T,progress='text',format='GTiff',bylayer=F)
}

int<-stack(file.path(outputDir,'y6190int.tif'))
slp<-stack(file.path(outputDir,'y6190slp.tif'))
rsqrd<-stack(file.path(outputDir,'y6190rsqrd.tif'))

#-downscale the 1 km DEM
dem<-disaggregate(dem,fact=4,method='bilinear')

###-high-res DEM
dem250m<-raster(file.path(wd, 'DEM', 'gb_srtm_250m.tif'))
dem250m<-projectRaster(dem250m,dem,method='bilinear')
dem250m<-mask(crop(dem250m,mk),tgt)

dem250m <- resample(dem250m, dem, method='ngb')

#-downscale int and slp layers to 1km
int<-disaggregate(int,fact=4,method='')
slp<-disaggregate(slp,fact=4,method='')
rsqrd<-disaggregate(rsqrd,fact=4,method='')

##---downscaling with bilinear interpolation using the raster package
for (year in c(1901:2080)) {
  print(paste('year: ',year))

  rasterName <- sprintf('y%s_dwnTS.tif', year)
  ukcp<-stack(file.path(wd,'UKCP18-60km_dwn_wcBSL_1km_UK', rasterName))

  # could add checks here if crs is different,
  # so reprojection is done only when necessary
  ukcp <- projectRaster(ukcp,crs=crs(ukcp6190))
  ukcp <- resample(ukcp, ukcp6190, method='ngb')


  ukcp<-mask(crop(ukcp,mk),tgt)/10

  #-simple bilinear interpolation
  ukcp<-disaggregate(ukcp,fact=4,method='bilinear')

  #-dynamic lapse rate adjustment - REMOVED INTERCEPT
  ukcpDYN<-ukcp+(dem-dem250m)*slp

  #-comparison
  #plot(ukcp,1) # bilinear downscaling only
  #plot(ukcpDYN,1) # bilinear + DYN
  #pairs(stack(crop(ukcp,ukcpDYN)[[1]],ukcpDYN[[1]])) #comparison

  writeRaster(round(ukcpDYN,1)*10,
                file.path(outputDir, rasterName),
                overwrite=T,progress='text',datatype='INT2S',format='GTiff',bylayer=F)
}
###---end script