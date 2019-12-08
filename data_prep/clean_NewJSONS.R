library(tidyverse)
library(jsonlite)

#my_cps    <- jsonlite::fromJSON(txt = "data_local/cp.json", flatten = TRUE)
my_tendr    <- jsonlite::fromJSON(txt = "data_local/tenderers_suppliers.json", flatten = TRUE)
my_buyers <- jsonlite::fromJSON(txt = "data_local/buyers.json", flatten = TRUE)

my_tendr[1,]$roles

my_tendr$roles <-
sapply(my_tendr$roles, FUN = function(i){paste(i, collapse = ";")})



write_delim(x = my_tendr, "results/my_tenderers_suppliers.txt", delim = "\t")
write_delim(x = my_buyers, "results/buyers.txt", delim = "\t")

