### new grass location must be made for this to work with the desired projection. 
### create new location and import the dem for this to work



library(raster)
clim = raster("/projects/oa/tree_vel/dem/raster/ca_dem_aea.tif")


# Determine tile parameters starting with the lower left corner
ntc <- 10000
ntr <- 10000

ex = extent(clim)


scoord = ex[3]
wcoord = ex[1]
#ncoord = ex[4]
ecoord = ex[2]
nsres = yres(clim)
ewres = xres(clim)
ncl <- ncol(clim) #number of columns 
nrw <- nrow(clim) #number of rows

# Determine the raster resolution, lower left corner coordinates and number of rows and columns. This can be used to calculate tile sizes:
cpt <- ceiling(ncl/ntc)  # number of columns per tile
rpt <- ceiling(nrw/ntr)  # number of rows per tile
cptl = ncl-cpt*(ntc-1)
rptl = nrw-rpt*(ntr-1)

scoor = scoord-ntr*nsres
ncoor = scoord
#plot(clim)


for(i in 1:rpt){     
  wcoor <- wcoord-ntc*ewres
  ecoor <- wcoord
  scoor <- scoor+ntr*nsres
  if (i == rpt)
  {
    ncoor <- ncoor+(3344)*nsres
  } else{
    ncoor = ncoor + ntr*nsres
  }
  
  s <- scoor #+ 0.5*mdr
  n <- ncoor #- 0.5*mdr
  
  for(j in 1:cpt){   #* changes everthing to rpt instead of cpt
    
    wcoor <- wcoor+ntc*ewres
    
    if (j ==cpt)
    {
      ecoor <- ecoor+(7513)*ewres
    } else{
      ecoor <- ecoor+ntc*ewres
    }
    
    w <- wcoor #+ 0.5*mdr
    e <- ecoor #- 0.5*mdr
    
    lib = print("library(raster)")
    r = print("r = raster('/projects/oa/tree_vel/shapefiles/water_cap/water_capacity_fix.tif')")
    c = print(paste("c = crop(r, extent(",w, ",",e, ",",s, ",",n, "))", sep = ""))
    writeraster = print(paste("writeRaster(c, file = '/projects/oa/tree_vel/shapefiles/water_cap/tiles/tile_", i, "_", j, ".tif')", sep = ""))
    
    combine = rbind(lib, r, c, writeraster)
    write(combine, file = paste("/projects/oa/tree_vel/shapefiles/water_cap/tiles/qsub_files/tile_", i, "_", j, ".R", sep = ""))
    
    
    #tl = c(w,n)
    #tr = c(e,n)
    #bl = c(w,s)
    #br = c(e,s)
    
    #points = rbind( tl, tr, bl, br)
    #points(points, col = "red")
    
    
  }
}



