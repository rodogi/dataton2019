################################################################################
#Prepare S2 Data
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


#### S2 Data ####

#### Read

s2_edmx <- fromJSON(txt = "data_local/s2-bulk/s2-edomex.json", flatten = TRUE)
s2_sfp1 <- fromJSON(txt = "data_local/s2-bulk/s2-sfp1.json", flatten = TRUE)
s2_sfp2 <- fromJSON(txt = "data_local/s2-bulk/s2-sfp2.json", flatten = TRUE)
s2_sfp3 <-fromJSON(txt = "data_local/s2-bulk/s2-sfp3.json", flatten = TRUE)

#### Cleaning

#remove list columns 

s2_edmx <- s2_edmx %>% select(which(sapply(s2_edmx, typeof)!="list"))
s2_sfp1 <- s2_sfp1 %>% select(which(sapply(s2_sfp1, typeof)!="list"))
s2_sfp2 <- s2_sfp2 %>% select(which(sapply(s2_sfp2, typeof)!="list"))
s2_sfp3 <- s2_sfp3 %>% select(which(sapply(s2_sfp3, typeof)!="list"))

#Make nombre_completo and nombre_completo_superiorInmediato

##nombre_completo

s2_edmx <- MergeName(s2_edmx, 
                     my_new_column = "nombre_completo", 
                     nombres, 
                     primerApellido, 
                     segundoApellido)


s2_sfp1 <- MergeName(s2_sfp1, 
                     my_new_column = "nombre_completo", 
                     nombres, 
                     primerApellido, 
                     segundoApellido)

s2_sfp2 <- MergeName(s2_sfp2, 
                     my_new_column = "nombre_completo", 
                     nombres, 
                     primerApellido, 
                     segundoApellido)

s2_sfp3 <- MergeName(s2_sfp3, 
                     my_new_column = "nombre_completo", 
                     nombres, 
                     primerApellido, 
                     segundoApellido)

## nombre_completo_superiorInmediato

s2_edmx <- MergeName(s2_edmx, 
                     my_new_column = "nombre_completo_superiorInmediato", 
                     superiorInmediato.nombres, 
                     superiorInmediato.primerApellido, 
                     superiorInmediato.segundoApellido)


s2_sfp1 <- MergeName(s2_sfp1, 
                     my_new_column = "nombre_completo_superiorInmediato", 
                     superiorInmediato.nombres, 
                     superiorInmediato.primerApellido, 
                     superiorInmediato.segundoApellido)

s2_sfp2 <- MergeName(s2_sfp2, 
                     my_new_column = "nombre_completo_superiorInmediato", 
                     superiorInmediato.nombres, 
                     superiorInmediato.primerApellido, 
                     superiorInmediato.segundoApellido)

s2_sfp3 <- MergeName(s2_sfp3, 
                     my_new_column = "nombre_completo_superiorInmediato", 
                     superiorInmediato.nombres, 
                     superiorInmediato.primerApellido, 
                     superiorInmediato.segundoApellido)



# make names all caps, remove accents 

s2_edmx <- mutate(.data = s2_edmx, 
                  nombre_completo = str_to_upper(stringi::stri_trans_general(nombre_completo, "Latin-ASCII")),
                  nombre_completo_superiorInmediato = str_to_upper(stringi::stri_trans_general(nombre_completo_superiorInmediato, "Latin-ASCII")
                                                                   )
                  )

s2_sfp1 <- mutate(.data = s2_sfp1, 
                  nombre_completo = str_to_upper(stringi::stri_trans_general(nombre_completo, "Latin-ASCII")),
                  nombre_completo_superiorInmediato = str_to_upper(stringi::stri_trans_general(nombre_completo_superiorInmediato, "Latin-ASCII")
                  )
)

s2_sfp2 <- mutate(.data = s2_sfp2, 
                  nombre_completo = str_to_upper(stringi::stri_trans_general(nombre_completo, "Latin-ASCII")),
                  nombre_completo_superiorInmediato = str_to_upper(stringi::stri_trans_general(nombre_completo_superiorInmediato, "Latin-ASCII")
                  )
)

s2_sfp3 <- mutate(.data = s2_sfp3, 
                  nombre_completo = str_to_upper(stringi::stri_trans_general(nombre_completo, "Latin-ASCII")),
                  nombre_completo_superiorInmediato = str_to_upper(stringi::stri_trans_general(nombre_completo_superiorInmediato, "Latin-ASCII")
                  )
)

#join into single large data frame 

## column throwing error because cant convert to integer: idRamo in edomex

s2_edmx <- s2_edmx %>% mutate(idRamo = as.numeric(idRamo))

s2_df <- 
  bind_rows(list(sfp1 = s2_sfp1, 
                 sfp2 = s2_sfp2, 
                 sfp3 = s2_sfp3,
                 edmx = s2_edmx),
            .id = "sistema")

#writeout 

write_delim(x = s2_df, path = "results/s2_bound.txt", delim = "\t", col_names = TRUE)

