USGS DEMs are downloaded in LatLong. Since all downscale outputs are based on the DEM used, the DEM needs to be re-projected to a suitable
equal area projection, in meters. The LatLong dem will be used for r.sun in GRASS GIS to produce radiation. THis is the ONLY time the LL surface
will be used for a downscale product. All others must use the AEA reprojected surface.

Code is not provided because it is a one line GDALWARP command that depends on the projection you chose. This step is critical, as the AEA DEM
is used to align the raw wind and climate files in the following steps. 
