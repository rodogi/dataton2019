library(tidyverse)
library(igraph)
library(tidygraph)

########
adjacent_amount <- function(g, vid){
  #saca los vecinos
  vecinos_inc = neighbors(graph = g, v = V(g)[vid])
  #encuentra los contratos adyacentes y sumalos 
  my_sum <- V(g)[vecinos_inc]$totalAmount %>% sum
  return(my_sum)
}
########


# cargar datos
mis_edges <- vroom::vroom(file = "results/tabla_edges.csv")
mis_nodos <- vroom::vroom(file = "results/tabla_nodos.psv", delim = "|")

#modificar para red
mis_nodos %>% colnames
mis_nodos.chafa <-
mis_nodos %>% 
  rename(.name = name,
         name  = nodo)

#cargar red
gg = graph_from_data_frame(d = as.data.frame(mis_edges), vertices = mis_nodos.chafa)
gg

#sacar la no dirigida
ggud <- as.undirected(gg) 

#sacar mis dependencias
mis_dependencias <-
  mis_nodos %>% 
  filter(labels == ":Buyer") %>% 
  select(nodo, id)

#calcular valor de totalAdjacentAmount para dependencias
mis_total_amounts.dependencias <- sapply(X = mis_dependencias$nodo, FUN = function(i){
  adjacent_amount(g = gg, vid = i)
})


mis_total_amounts.dependencias <- (mis_total_amounts.dependencias %>% as.data.frame)
mis_total_amounts.dependencias <-
  mis_total_amounts.dependencias %>% 
  rownames_to_column(var = "nodos")

#sacar mis dependencias
mis_supplier_tenderers <-
  mis_nodos %>% 
  filter(labels == ":Party") %>% 
  select(nodo, id)

#calcular valor de totalAdjacentAmount para dependencias
mis_total_amounts.party <- sapply(X = mis_supplier_tenderers$nodo, FUN = function(i){
  adjacent_amount(g = gg, vid = i)
})


mis_total_amounts.party <- (mis_total_amounts.party %>% as.data.frame)

mis_total_amounts.dependencias
(mis_total_amounts.dependencias) %>% head

colnames(mis_dependencias)
colnames(mis_total_amounts.dependencias) <- c("nodo", "TotalAdjacentAmount")
mis_total_amounts.dependencias<- left_join(mis_dependencias, y = mis_total_amounts.dependencias)

