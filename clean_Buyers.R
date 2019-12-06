################################################################################
#Prepare Buyers Json Data
#Flatten JSON to data frame
#merge names and send to UPPER, Latin-ASCII
################################################################################

############################
######## libraries #########
############################

library(tidyverse)
library(stringi)
library(jsonlite)

############################
######## functions #########
############################


MergeName <- function(my_data, my_new_column, ... ){
  my_vars = enquos( ... )
  
  my_data %>% 
    unite(col = !!my_new_column, sep = " ", remove = FALSE, !!!my_vars)
  #takes a data frame 
  
}


#### S3 Data ####

#### Read

my_buyers <- fromJSON(txt = "data_local/buyers.json", flatten = TRUE)

# Clean: ALL CAPS, no accents

my_buyers <- mutate(.data = my_buyers, 
                  name = str_to_upper(stringi::stri_trans_general(name, "Latin-ASCII")
                                      )
                  )

# writeout

write_delim(x = my_buyers, path = "results/my_buyers.txt", delim = "\t", col_names = TRUE)
