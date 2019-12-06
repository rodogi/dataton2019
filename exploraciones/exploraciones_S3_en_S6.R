  library(tidyverse)
  library(igraph)
  library(ggraph)
  library(tidygraph)
  
  mis_nodos  <- vroom::vroom(file = "tabla_nodos.csv", delim = ",")
  mis_edges  <- vroom::vroom(file = "tabla_edges.csv", delim = ",")
  mis_s3     <- data.table::fread(input = "results/s3_bound.txt")
  mis_buyers <- vroom::vroom(file = "results/my_buyers.txt")
  
  mis_nodos$labels %>% table
  mis_edges$roles %>% table
  
  #prep mis_nodos "title" and "name to be ALL CAPS SIN ACENTOS
  
  mis_nodos <- 
    mis_nodos %>% 
    mutate(title = str_to_upper(stringi::stri_trans_general(title, "Latin-ASCII"))) %>% 
    mutate(name = str_to_upper(stringi::stri_trans_general(name, "Latin-ASCII"))) 
  
  #get names of redtaggeds ("sancionados")
  
  mis_sancionados.personas <- mis_s3$nombre_completo %>% unique()
  
  mis_sancionados.empresas <- 
    mis_s3 %>% 
    filter(sistema == "part") %>% 
    pull(nombreRazonSocial) %>% 
    unique()
  
  mis_sancionados <- c(mis_sancionados.personas, mis_sancionados.empresas)
  mis_sancionados <- mis_sancionados[which(!is.na(mis_sancionados))]
  
  mis_sancionados %>% is.na %>% table
  #search them in my nodes 
  ## note: these folk will all have :Party  
  
  mis_nodos %>% 
    filter(name%in%mis_sancionados | title%in%mis_sancionados) #wow! I find only 77 redtagged folk in the network 
  
  mis_nodos %>% 
    filter(name%in%mis_sancionados) %>% 
    pull(labels) %>% table #they are all label == :Party
  
  
  #search for these folk in the network 
  mis_sancionados_nodos <- 
    mis_nodos %>% 
    filter(name%in%mis_sancionados) %>% 
    pull(nodo)
  
  #find second neighbor network, data frame style 
  
  me_and_my_first_neighbors <- 
    c(mis_edges %>% 
        filter(source%in%mis_sancionados_nodos | target%in%mis_sancionados_nodos) %>% 
        pull(source),
      mis_edges %>% 
        filter(source%in%mis_sancionados_nodos | target%in%mis_sancionados_nodos) %>% 
        pull(target)
    ) %>% unique #gets my sancionados and their first neighbors
  
  my_second_neighbor_nw <- mis_edges %>% 
    filter(source%in%me_and_my_first_neighbors | target%in%me_and_my_first_neighbors)
  
  mis_nodos %>% 
    filter(labels == ":Party") %>% head
  
  mis_nodos_etiquetadores <- 
    mis_nodos %>% 
    #select(nodo, ocid, title, name, totalAmount) %>% 
    rename(nombre = name) %>% 
    mutate(name = ifelse(!is.na(nombre), 
                         yes = nombre,      #if it has a name, I want that as the label
                         no  = totalAmount) #if it does not, it's a contract; want to see the total amount
    ) %>% 
    select(nodo, name)
  
  mis_nodos_etiquetadores %>% head
  
  my_second_neighbor_nw <- 
    left_join(x = my_second_neighbor_nw, y = mis_nodos_etiquetadores, by = c("source" = "nodo")) %>% 
    rename(name_source = name)
  
  my_second_neighbor_nw <- 
    left_join(x = my_second_neighbor_nw, y = mis_nodos_etiquetadores, by = c("target" = "nodo")) %>% 
    rename(name_target = name)
  
  pre_nw <- 
    my_second_neighbor_nw %>% select(name_source, name_target, source, target) %>% rename(my_source = source, my_target = target)
  
  #graph operations
  
  g <- igraph::graph_from_data_frame(pre_nw)
  
  g <- 
    g %>% 
    as_tbl_graph()
  
  
  
  g <- 
    g %>% 
    activate("nodes") %>% 
    mutate(type = ifelse(name%in%mis_sancionados.empresas, 
                         yes =  "empresa_sancionada", 
                         no = ifelse(test = name%in%mis_sancionados.personas,
                                     yes = "persona_sancionada", 
                                     no = ifelse(test = name%in%mis_buyers$name, 
                                                 yes = "institucion_compradora",
                                                 no = ifelse(is.na(as.numeric(name)), 
                                                             yes =  "otro", 
                                                             no =  "contratos")
                                     )
                                     )
                         )
           )
  
  
  write.graph(graph = g, file = "results/segundos_vecinos_s3.graphml", format = "graphml")
# g %>% 
#   as_tbl_graph() %>% 
#   ggraph(layout = "kk") +
#   #geom_node_point(mapping = aes(colour = type, size = ifelse(type=="contratos", as.numeric(name), 100))) +
#   geom_node_point(mapping = aes(colour = type, size = 25)) +
#   geom_edge_fan() + 
#   geom_node_text(aes(label = str_trunc(name, width = 23, side = "right")), repel = TRUE) +
#   theme_graph()

###############################
mis_sancionados <- s3_edomex$id

mis_nodos %>% filter(ocid%in%mis_sancionados)
mis_nodos %>% head
s3_edomex %>% head
mis_sancionados %>% head  
mis_nodos$ocid %>% head

s3_edomex$servidorPublicoSancionado %>% head

s3_otra <- jsonlite::fromJSON(txt = "data_local/s3-servidores-bulk/servidores_publicos_sancionados_sfp1.json")

s3_otra %>% colnames

nombres_gente <- 
  mis_nodos %>% 
  filter(labels == ":Party") %>% 
  pull(name)

nombres_gente

#modificando
# 
# mis_nodos <- 
# mis_nodos %>% 
# #  filter(labels == ":Party") %>% 
#   mutate(name = str_to_upper(stringi::stri_trans_general(name, "Latin-ASCII")))
#   #filter(name == "José Humberto Lamadrid López") %>% 
#   
#   
# s3_otra <- 
# s3_otra %>% 
#   unite(col = "nombre_completo", nombres, primerApellido, segundoApellido, remove = FALSE, sep = " ") %>% 
#   mutate(nombre_completo = str_to_upper(stringi::stri_trans_general(nombre_completo, "Latin-ASCII")))
# 
# mis_corruptos <- s3_otra$nombre_completo
# 
# mis_nodos %>% 
#   filter(labels == ":Party") %>% 
#   filter(name%in%mis_corruptos)
# 
# mis_edges %>% 
#   filter(source == "n2316" | target == "n2316")
# 
# mis_nodos %>% 
#   filter(nodo%in%c("n2316", "n97480", "n118352", "n122390", "n148531"))
# 
# mis_nodos %>% 
#   filter(nodo=="n97480")
# 
# s3_otra %>% 
#   filter(nombre_completo == "MIGUEL ANGEL TORRES HERNANDEZ")
# 


