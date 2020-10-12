
wd <- 'C:/dev/ForestResearch/forest-research-B4EST/data'

df <- read.csv(file.path(wd, '0000_NS-SP_locations', '0000_NS-SP_locations.csv'))


##################
# Precipitation Sum
##################
df$PrecipitationSumAprOct <- df$prc04 + df$prc05 + df$prc06 + df$prc07 + df$prc08 + df$prc09 + df$prc10


##################
# Growing Degree Days
##################
base <- 5
df$GDD5 <- apply(data.frame(0.5 * (df$tmx01 + df$tmn01) - base, 0), 1, max) * 31 +
           apply(data.frame(0.5 * (df$tmx02 + df$tmn02) - base, 0), 1, max) * 28 +
           apply(data.frame(0.5 * (df$tmx03 + df$tmn03) - base, 0), 1, max) * 31 +
           apply(data.frame(0.5 * (df$tmx04 + df$tmn04) - base, 0), 1, max) * 30 +
           apply(data.frame(0.5 * (df$tmx05 + df$tmn05) - base, 0), 1, max) * 31 +
           apply(data.frame(0.5 * (df$tmx06 + df$tmn06) - base, 0), 1, max) * 30 +
           apply(data.frame(0.5 * (df$tmx07 + df$tmn07) - base, 0), 1, max) * 31 +
           apply(data.frame(0.5 * (df$tmx08 + df$tmn08) - base, 0), 1, max) * 31 +
           apply(data.frame(0.5 * (df$tmx09 + df$tmn09) - base, 0), 1, max) * 30 +
           apply(data.frame(0.5 * (df$tmx10 + df$tmn10) - base, 0), 1, max) * 31 +
           apply(data.frame(0.5 * (df$tmx11 + df$tmn11) - base, 0), 1, max) * 30 +
           apply(data.frame(0.5 * (df$tmx12 + df$tmn12) - base, 0), 1, max) * 31

write.csv(df, file.path(wd, '0000_NS-SP_locations', '0000_NS-SP_locations-UPDATE.csv'), row.names=FALSE)

