# dataton2019
Repositorio para el proyecto contra la corrupción del dataton 2019

## Hipótesis:

La corrupción como fenómeno es menos común que el comportamiento no-corrupto. Por lo tanto, podemos detectarla a partir de *features* que dependen de la forma en la que los actores (compradores, vendedores) en los procesos (ie. contratos de compras) se conectan. Se pueden identificar estas *features* discriminantes.  

### Contenido

Este repositorio contiene el código que utilizamos para preparar los datos de la Plataforma Nacional Digital, Sistemas 2, 3, 6

### data_prep
Jupyter notebook (Python) y  R script para procesar un grafo obtenido de Neo4j con los datos de la plataforma S6. Rscripts para extraer las etiquetas de sancionados del sistema S3, y comparar con el S2.

### Feature_eng

Jupyter notebook (Python) y R script para extraer variables de 1er orden (propias del nodo) y 2do orden (basadas en su vecindario en la red S6) .

### Analisis

Analisis topológico de la red, y análisis de distribución de las variables generadas a partir de los tres sistemas.
