library(ProgGUIinR)


year = 2017

months = 1:12


total_days = vector()

for (i in 1:length(months))
{
  days = days.in.month(year, months[i])
  total_days = c(total_days, days)
}


numbers = vector()

for (i in 1:length(months))
{
  if (i == 1)
  {
    num = days.in.month(year, months[i])
    half = round(num/2, 0)
    numbers  = c(numbers, half)
    
  } else {
      num = days.in.month(year, months[i])
      half = round(num/2, 0)
      prev = sum(total_days[1:i-1])
      
      
      half = half+prev
      numbers = c(numbers, half)
      
    }
}


