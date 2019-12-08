rod_buyers_nsancion <- vroom::vroom(file = "rodrigos/buyers_nsancion.csv", delim = ",")
rod_buyers_nsancion[1:4,]

rod_buyers_nsancion <-left_join(x = rod_buyers_nsancion, y = mis_total_amounts.dependencias)

rod_buyers_nsancion[1:3,]

rod_buyers_nsancion %>% order_by(nsancion) %>% head

rod_buyers_nsancion %>% 
  ggplot(aes(y = nsancion, x = TotalAdjacentAmount)) +
  geom_point() +
  geom_text(aes(label = id)) +
  scale_x_log10() +
  scale_y_log10() + 
  geom_smooth(method = "glm") +
  theme_minimal() + 
  xlab("Total de dinero ejercido") +
  ylab("Num. Sanciones")
  
ggsave(filename = "results/scatterplot_dinero_sanciones.png")  

data.table::fwrite(rod_buyers_nsancion, file = "results/TotalAmounts_nsancion.txt")

