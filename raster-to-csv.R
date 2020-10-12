library(raster)
library(tools)


rasterPath <- 'C:/dev/ForestResearch/forest-research-B4EST/data/demUKCP18_5km.tif'


#################################


rst <- raster(rasterPath)
df <- as.data.frame(rst, xy=TRUE, na.rm=TRUE)

csvPath <- file.path(dirname(rasterPath), sprintf('%s.csv', file_path_sans_ext(basename(rasterPath))))

write.csv(df, csvPath, row.names=FALSE)
