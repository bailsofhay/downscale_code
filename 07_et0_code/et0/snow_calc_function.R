snow_calc_function <- function(tmean, ppt, radiation, snowpack_prev = NULL, verbose = TRUE,...)
{
  albedo = 0.23
  albedo_snow = 0.8
  radiation_multiplier = 0.0864
  radiation=radiation*radiation_multiplier
  dpt_correction=-2
  sr=100 
  ks_min=.01 
  thresh=5
  hw=3.54463
  
  #N <- length(tmean)
  if(is.null(snowpack_prev)) 
    {
    snowpack_prev = tmean
    snowpack_prev[is.finite(snowpack_prev[])] = 0
    }
  
  snowpack <- tmean
  snowpack[is.finite(tmean[])] = NA
  input <- snowpack
  
  
  
  # this is for radiation in MJ/m^2/day
  zeroes = tmean
  zeroes[is.finite(zeroes[])] = 0
  ones = tmean
  ones[is.finite(tmean[])] = 1
  
  
  parvec <- c(-4.604,6.329,-398.4,81.75,25.05)
  # Ranges from 0 to 1:
  
  mf = function(tmean, ones, zeroes, tL, tH) {
    input = (tmean-tL)/(tH-tL)
    mf1 = stackApply(x = stack(input, zeroes), indices = c(1,1), fun = max, na.rm =T)
    mf2 = stackApply(x = stack(mf1, ones), indices = c(1,1), fun = min, na.rm = T)
    return(mf2)
  }
  
  mfsnow = mf(tmean, ones, zeroes, tL = parvec[1], tH = parvec[2])
  
  
  linrmelt = function(tmean, radiation, zeroes, b0, b1, b2)
  {
    input =b0+tmean*b1+radiation*b2
    output = stackApply(x =stack(input, zeroes), indices = c(1,1), fun = max, na.rm = T)
    return(output)
  }
  
  mfmelt <- linrmelt(tmean,radiation, zeroes, parvec[3],parvec[4],parvec[5])
  
  
  # calculate values
  
  snow = stackApply(x = stack(((1-mfsnow)*ppt), zeroes), indices = c(1,1), fun = max, na.rm = T)
  
  rain <- stackApply(x = stack((ppt - snow), zeroes), indices = c(1,1), fun = max, na.rm = T)
  melt <- stackApply(x = stack(mfmelt,(snow+snowpack_prev)), indices = c(1,1), fun = min, na.rm = T)
  snowpack <- snowpack_prev+snow-melt 
  input <-rain+melt
  
  # make vector of albedo values
  albedo <- ones
  albedo[albedo[] == 1] = 0.23
  albedo[snowpack>0 | (snowpack_prev>0)] <- albedo_snow
  
  output = stack(snowpack, snow, rain, melt, input, albedo)
  names(output) = c("snowpack", "snow", "rain", "melt", "input", "albedo")
  
  return(output)
  
}
