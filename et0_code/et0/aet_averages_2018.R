require("raster")
require("spatial.tools")

slurm_id = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

months = add_leading_zeroes(1:24, 2)

is = sort(rep(1:4, 3))
js = rep(1:3, 4)
indexs = paste("_", is, "_", js, sep = "")

# Inputs:
et0_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/et0/average/future/et0/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)

input_files = list.files(path = "/data/gpfs/assoc/gears/tree_vel/et0/average/future/rain_files/input/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)

whc_files=list.files("/data/gpfs/assoc/gears/tree_vel/et0/average/future/inputs/water/", pattern = indexs[slurm_id], include.dirs = T, full.names = T)


et0_raw = stack(et0_files)
input_raw = stack(input_files)
whc_raw = raster(whc_files[1])*10


aetmod <- function(et0,input,awc,soil_prev){
  
  awc[awc < 0] <- 0
  et0[et0 < 0] <- 0
  
  
  zeroes = et0
  zeroes[is.finite(et0[])] = 0
  
  na = zeroes
  na[na[] == 0] = NA
  
  runoff <- def <-  aet <- soil <- na # 
  if(is.null(soil_prev)) soil_prev <- zeroes
  
  deltasoil <- input-et0 # positive=excess H2O, negative=H2O deficit
  
  surplus_index = which(deltasoil[] >= 0)
  deficit_index = which(deltasoil[] < 0)
  
  if (length(surplus_index) > 0)
  {
    aet[surplus_index] <- et0[surplus_index]
    def[surplus_index] <- 0
    
    soil[surplus_index] = pmin(soil_prev[surplus_index]+deltasoil[surplus_index], awc[surplus_index])
    runoff[surplus_index] = pmax(soil_prev[surplus_index]+deltasoil[surplus_index]-awc[surplus_index], 0)
    
  }
  
  if (length(deficit_index) > 0)
  {
    soildrawdown <- soil_prev[deficit_index]*(1-exp(-(et0-input)[deficit_index]/awc[deficit_index]))	# this is the net change in soil moisture (neg)
    aet[deficit_index] <- pmin(input[deficit_index] + soildrawdown, et0[deficit_index])
    def[deficit_index] <- et0[deficit_index] - aet[deficit_index]
    
    soil[deficit_index] <- soil_prev[deficit_index]-soildrawdown
    runoff[deficit_index] <- 0
    
  }
  
  aetout=stack(aet,def,soil,runoff)
  names(aetout) = c("aet", "def", "soil", "runoff")
  
  return(aetout)
}


for (i in 1:24)
{
  if (i > 12) 
  {
    j = i -12
  } else {
    j = i
  }
  et0 = subset(et0_raw, j)
  input = subset(input_raw, i)
  awc = whc_raw
  
  
  if (i == 1)
  {
    soil_prev = NULL
  } else {
    soil_prev = aet_rasters$soil
  }
  
  print(paste("working on: ", months[i], indexs[slurm_id], sep = ""))
  
  aet_rasters = aetmod(et0 = et0, input = input, awc = awc, soil_prev = soil_prev)
  
  writeRaster(aet_rasters$aet, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/aet/aet/aet_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(aet_rasters$def, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/aet/def/def_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(aet_rasters$soil, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/aet/soil/soil_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  writeRaster(aet_rasters$runoff, file = paste('/data/gpfs/assoc/gears/tree_vel/et0/average/future/aet/runoff/runoff_', months[i], indexs[slurm_id], "_future.tif", sep =''), overwrite = TRUE)
  
  print(paste("finished: ", months[i], indexs[slurm_id], sep = ""))
}

 