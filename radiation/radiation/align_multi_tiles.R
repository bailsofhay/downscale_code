### new grass location must be made for this to work with the desired projection. 
### create new location and import the dem for this to work
files = list.files(path = "/projects/oa/tree_vel/radiation/aligned/", pattern = ".tif", include.dirs = T, full.names = T)
months = c("april", "aug", "dec", "feb", "jan", "july", "june", "mar", "may", "nov", "oct", "sept")

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
  if (i == rpt){
    ncoor <- ncoor+(3344)*nsres
  } else {
    ncoor = ncoor + ntr*nsres}
  
  s <- scoor #+ 0.5*mdr
  n <- ncoor #- 0.5*mdr
  
  for(j in 1:cpt){  
    wcoor <- wcoor+ntc*ewres
    
    if (j ==cpt) {
      ecoor <- ecoor+(7513)*ewres
    } else {
      ecoor <- ecoor+ntc*ewres}
  
    w <- wcoor #+ 0.5*mdr
    e <- ecoor #- 0.5*mdr
    
    for (x in 1:12){
      names = paste("rad_", i, "_", j, sep = "")
      file = paste(names, ".tif", sep = "")
      lib = print("library(raster)")
      r = print(paste("r = raster('", files[x], "')", sep = ""))
      c = print(paste("c = crop(r, extent(", w, ",",e, ",", s, ",", n, "))" , sep = ""))
      write = print(paste("writeRaster(c, file = '/projects/oa/tree_vel/radiation/aligned/tiles/", months[x], "/", file, "', format = 'GTiff')",sep = ""))
      combine = rbind(lib, r, c, write)
      outfile = paste("/projects/oa/tree_vel/radiation/aligned/tiles/", months[x], "/qsub_files/",names, ".R", sep = "")
      write(combine, file = outfile)
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
  
}
    
    