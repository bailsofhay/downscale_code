### new grass location must be made for this to work with the desired projection. 
### create new location and import the dem for this to work

days = c(15, 45,75,105,135,165,195,225,255,285,315,345)

library(raster)
clim = raster("/projects/oa/tree_vel/dem/raster/ca_dem_utm.tif")
months = "dec"
day = days[12]


# Determine tile parameters starting with the lower left corner
ntc <- 5000
ntr <- 5000

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
    ncoor <- ncoor+(4612)*nsres
  } else{
    ncoor = ncoor + ntr*nsres
  }
  
  
  s <- scoor #+ 0.5*mdr
  n <- ncoor #- 0.5*mdr
  
  for(j in 1:cpt){   #* changes everthing to rpt instead of cpt
    
    wcoor <- wcoor+ntc*ewres
    
    if (j ==cpt)
    {
      ecoor <- ecoor+(3212)*ewres
    } else{
      ecoor <- ecoor+ntc*ewres
    }
    
    w <- wcoor #+ 0.5*mdr
    e <- ecoor #- 0.5*mdr
    
    region = print(paste("grass71 -c /projects/oa/tree_vel/grass/radiation/", months, "_", i, "_", j, " --exec g.region n=", n, " s=", s, " e=", e, " w=", w, sep = ""))
    r.sun = print(paste("grass71 /projects/oa/tree_vel/grass/radiation/",months, "_", i, "_", j, " --exec r.sun  elevation=ca_dem_utm@PERMANENT aspect=aspect@bdmorri2 slope=slope@bdmorri2 glob_rad=", months, "_", i, "_", j, " day=", day, sep = ""))
    export = print(paste("grass71 /projects/oa/tree_vel/grass/radiation/", months, "_", i, "_", j, " --exec r.out.gdal input=", months, "_", i, "_", j, "@", months, "_", i, "_", j, " output=/projects/oa/tree_vel/radiation/", months, "/", months, "_", i,"_", j, ".tif  format=GTiff", sep = ""))
    combine = rbind(region, r.sun, export)
    
    write(combine, file = paste("/projects/oa/tree_vel/radiation/qsub_files/", months, "/", months,"_", i, "_", j, ".sh", sep = ""))
    
    
    #names = paste("dem_", i, "_", j, sep = "")
    #file = paste(names, ".tif", sep = "")
    #lib = print("library(raster)")
    #r = print("r = raster('/projects/oa/tree_vel/dem/raster/dem_aea.tif')")
    #c = print(paste("c = crop(r, extent(", w, ",",e, ",", s, ",", n, "))" ))
    #write = print(paste("writeRaster(c, file = '/projects/oa/tree_vel/tci/tiles/", file, "', format = 'GTiff',  options='COMPRESS=NONE')",sep = ""))
    #combine = rbind(lib, r, c, write)
    #outfile = paste("/projects/oa/tree_vel/tci/tiles/qsub_files/",names, ".R", sep = "")
    #write(combine, file = outfile)
    #R = print(paste("R CMD BATCH /projects/oa/tree_vel/tci/tiles/qsub_files/", names, ".R", sep = ""))
    #write(R, file = paste('/projects/oa/tree_vel/tci/tiles/qsub_files/R_', names, ".sh", sep = ""))
    #qsub = print(paste("qsub -q secondary -e dem_err -o dem_out -l walltime=4:00:00,nodes=1:ppn=1 /projects/oa/tree_vel/tci/tiles/qsub_files/R_", names, ".sh", sep = ""))
    #write(qsub, file = "/projects/oa/tree_vel/tci/tiles/qsub_files/qsub_commands.sh", append = TRUE)
    
    
    
    #tl = c(w,n)
    #tr = c(e,n)
    #bl = c(w,s)
    #br = c(e,s)
    
    #points = rbind( tl, tr, bl, br)
    #points(points)
    
    
  }
}



