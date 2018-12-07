### new grass location must be made for this to work with the desired projection. 
### create new location and import the dem for this to work

library(spatial.tools)
files = list.files(path = "/projects/oa/tree_vel/radiation/aligned/", pattern = "aligned", include.dirs = T, full.names = T)
order = c(5,4,8,1,9,7,6,2,12,11,10,3)
files = files[order]
months = add_leading_zeroes(rep(1:12), 2)

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
    
    for (x in 1:length(files))
    {
      lib = print("library(raster)")
      r = print(paste("r = raster('", files[x], "')", sep = ""))
      c = print(paste("c = crop(r, extent(",w, ",",e, ",",s, ",",n, "))", sep = ""))
      writeraster = print(paste("writeRaster(c, file = '/projects/oa/tree_vel/radiation/aligned/tiles/", months[x], "/tile_", i, "_", j, ".tif')", sep = ""))
      
      combine = rbind(lib, r, c, writeraster)
      write(combine, file = paste("/projects/oa/tree_vel/radiation/aligned/tiles/qsub_files/", months[x], "/tile_", i, "_", j, ".R", sep = ""))
      
      bin = print("#!/bin/bash")
      pbs = print("#PBS -N tile_rad")
      module = print("module load parallel ")
      cd = print("cd /projects/oa/tree_vel/")
      export = print("export PARALLEL='--env PATH --env LD_LIBRARY_PATH --env LOADEDMODULES --env _LMFILES_ --env MODULE_VERSION --env MODULEPATH --env MODULEVERSION_STACK --env MODULESHOME'")
      parallel = print(paste("parallel -j $PBS_NP R CMD BATCH {} ::: radiation/aligned/tiles/qsub_files/", months[x], "/tile*.R", sep = ""))
      combine = rbind(bin, pbs,module, cd, export, parallel)
      write(combine, file = paste("/projects/oa/tree_vel/radiation/aligned/tiles/qsub_files/", months[x], "/run_files.sh", sep = ""))
      
    }
    
    
    #tl = c(w,n)
    #tr = c(e,n)
    #bl = c(w,s)
    #br = c(e,s)
    
    #points = rbind( tl, tr, bl, br)
    #points(points, col = "red")
    
    
  }
}



