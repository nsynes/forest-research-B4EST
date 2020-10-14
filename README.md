# forest-research-B4EST
Spatial analysis R scripts to support Forest Research's B4EST projects


## raster-to-csv.R
Provide a path to a raster file, and the script will export a .csv file of the raster data with coordinates.


## clip-rasters.R
Clip the provided rasters by country boundary. Specify the countries in the 'countries' array in the script. It uses a shapefile provided by Maurizio, called 'Prof.Hamann_Reference_Files_1km_EU.shp'


## calculate-gdd.R
Calculates growing degree days based on the provided mean monthly max and min temperatures. This script contains two versions of the calculation:
1. For single band rasters
2. For multi-band rasters, i.e. where each input raster contains 36 bands (tmin * 12 months, tmax * 12 months, prec * 12 months)


## calculate-precipitation-sum.R
Calculates precipitation sum (Apr-Oct) based on the provided monthly precipitation data. This script contains two versions of the calculation:
1. For single band rasters
2. For multi-band rasters, i.e. where each input raster contains 36 bands (tmin * 12 months, tmax * 12 months, prec * 12 months)


## calculate-exceedance.R
Calculates a range of decadal 'frequency of exceedance' rasters based on the provided monthly tmin, tmax and prec data. Note: there are a number of different versions of exceedance in this script (e.g. above max temp, below min temp, above precipitation level, below precipitation level). To change the exceedance threshold values, change the 'exceedanceVal' array.


## calculate-indices-from-table.R
Calculates precipitation sum and growing degree days using a table of monthly data.

## calculate-PET.R
Calculates potential evapotranspiration based on the modified Hargreaves equation from [Droogers and Allen (2001) Estimating reference evapotranspiration under inaccurate data conditions.]. The script also contains code using the SPEI::hargreaves function, but this is much slower than the manually coded equation (using a radiation raster).


## calculate-CMD.R
Calculates climate moisture deficit using potential evapotranspiration and precipitation (use calculate-PET.R before using this script).


# calculate-adjusted-CMD.R
Calculates an adjusted climate moisture deficit using quadratic transformation based on ESC data. This script requires 'calculate-CMD.R' to have already been run.


## plot-exceedance.R
Run this script after the exceedance raster data has been created using the 'calculate-indices.R' script. Using that data, this script will generate figures displaying exceedance frequency.


## B4T_rasterDownscaling_Deliverable4.3_UK.R
Script for downscaling based on dynamic lapse rate method. This script is adapted from Maurizio's method, and applied to the UK. Check with Maurizio for an up-to-date version of this downscaling: https://ibbr.cnr.it//ibbr/info/people/maurizio-marchi