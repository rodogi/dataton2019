################################################################################
#Prepare S3 Data
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

s3_edmx <- fromJSON(txt = "data_local/s3-servidores-bulk/servidores_publicos_sancionados_edoMex.json", flatten = TRUE)
s3_sfp1 <- fromJSON(txt = "data_local/s3-servidores-bulk/servidores_publicos_sancionados_sfp1.json", flatten = TRUE)
s3_sfp2 <- fromJSON(txt = "data_local/s3-servidores-bulk/servidores_publicos_sancionados_sfp2.json", flatten = TRUE)

# same columns?

setdiff(colnames(s3_edmx), colnames(s3_sfp1)) #nope

# combine names into single name

s3_edmx <- MergeName(s3_edmx, 
                      my_new_column = "nombre_completo,",
                      servidorPublicoSancionado.nombres, 
                      servidorPublicoSancionado.primerApellido, 
                      servidorPublicoSancionado.segundoApellido)
 
s3_sfp1 <- MergeName(s3_sfp1, my_new_column = "nombre_completo", nombres, primerApellido, segundoApellido)
s3_sfp2 <- MergeName(s3_sfp2, my_new_column = "nombre_completo", nombres, primerApellido, segundoApellido)

#join into single large data frame 

## remove large lists from s3_edmx. The info will be lost, but if needed it is still in the JSON file
s3_edmx.sansList <- select(s3_edmx, -c(tipoFalta, tipoSancion, documentos))

#For some reason multa.monto raises "can't convert to integer" error when binding.
#As it is uninformative (montos are all 0 or NA), we convert manually
s3_edmx.sansList <- mutate(s3_edmx.sansList, multa.monto = as.integer(multa.monto))
s3_sfp1 <- mutate(s3_sfp1, multa.monto = as.integer(multa.monto))
s3_sfp2 <- mutate(s3_sfp2, multa.monto = as.integer(multa.monto))

s3_df <- 
bind_rows(list(sfp1 = s3_sfp1, 
          sfp2 = s3_sfp2, 
          edmx = s3_edmx.sansList),
          .id = "sistema") 

#write out
write_delim(x = s3_df, path = "results/s3_bound.txt", delim = "\t", col_names = TRUE)
