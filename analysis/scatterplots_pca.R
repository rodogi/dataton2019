library(tidyverse)
library(igraph)
library(tidygraph)

g9 <- read_graph(file = "rodrigos/9malos.graphml", "graphml")
nodos_san <- readLines(con = "nodos_san.txt")



g9_nodes <- g9 %>% get.data.frame("vertices")

nodos_cp<-
mis_nodos %>% 
  filter(labels == ":CP") %>% 
  pull(nodo)

g9_nodos_cp <- 
g9_nodes[,sapply(g9_nodes, is.numeric)] %>% 
  rownames_to_column(var = "nodo") %>% 
  filter(nodo %in% nodos_cp)


g9_nodos_cp %>% pull(N_sancion) %>% is.na %>% table
g9_nodos_cp %>% str
pca_data <- 
g9_nodos_party %>% select(-c(TotalAdjacentAmount, N_sancion, totalAmount, nsubcontracts))

pca_data %>% str
pca_mx <- as.matrix(pca_data[-1])
rownames(pca_mx) <- pca_data$nodo
is.na(pca_mx) %>% table

my_pca9 <-
prcomp(pca_mx)

my_pca9<- 
my_pca9$x %>% 
  as.data.frame()

mis_malos <-
mis_nodos %>% 
  filter(id %in% nodos_san) %>% 
  pull(nodo)


mi_maldad <- rownames(my_pca9)%in%mis_malos

my_pca9 <-
my_pca9 %>% 
  as.data.frame() %>% 
  rownames_to_column("nodo")
my_pca9 %>% 
  mutate(malo = mi_maldad) %>% 
  ggplot(mapping = aes(x = PC1, y = PC3, color =malo)) +
  geom_point() +
  theme_minimal()
