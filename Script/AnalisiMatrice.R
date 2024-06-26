#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

# args è ora una lista di stringhe contenente i parametri
n <- as.integer(args[1])  # converte il primo parametro in un intero

library(ggplot2)
library(fpc)

source("~/Calinski_Harabasz_Thesis/Script/FunzioniMatrice.R")

# CASO BASE: prima metà delle righe composta di soli 0 e la seconda metà 
# composta di soli 1.

# Abilita/disabilita stampa
verbose <- FALSE

# controlli del parametro n per la matrice
if(missing(n))
  stop("Missing input argument. A parametric value is required")
if(!is.numeric(n))
  stop("Argument 'n' must be numeric")
if(n<=1)
  warning("The minimum value for consideration should be higher than 1",immediate. = TRUE)

if(verbose){
  print(n)
}
# Creazione e visualizzazione matrice 
matrice <-creaMatrice(n)
if(verbose){
  matrice
}


# Clustering con K-means
cl <- kmeans(matrice, 2, , 100)

# Calcolo dell'indice di Calinski-Harabasz con calinhara
# Valore atteso -> inf
CH <- calinhara(matrice, cl$cluster)
cat(sprintf("\nValore indice Calinski-Harabasz: %f\n", CH))


# CASO ITERATIVO: viene presa la matrice del caso precedente ed una riga scelta 
#                 casualmente viene sostituita con valori compresi tra 0 e 1.



# Creazione dataframe iterazioni/valore
risultati <- data.frame(iterazione = integer(), valore = numeric(),
                        stringsAsFactors = FALSE)


# Creazione pool da cui estrarre la riga da modificare
m <- nrow(matrice) # Numero di righe della matrice
pool <- sample(1:m) # Crea un pool di numeri da 1 a n ordinato in modo casuale


# Ciclo iterativo per modifica di una riga alla volta
for (i in 1:nrow(matrice)) {
  if(verbose){
    cat(sprintf("\nIterazione %d:\n", i))
  }
  
  # Pesca un numero casualmente senza reimmissione dal pool creato
  selezione <- pool[i] 
  if(verbose){
    cat(sprintf("\nRiga modificata: %d\n", selezione))
  }
  
  # Modifica riga della matrice
  matrice <- modificaRigaSelezionata(matrice, selezione)
  
  # Visualizzazione della matrice
  if(verbose){
    print(matrice)
  }
  
  
  # Clustering con K-means
  cl <- kmeans(matrice, 2, , 100)
  
  # Calcolo dell'indice di Calinski-Harabasz con calinhara
  CH <- calinhara(matrice, cl$cluster)
  cat(sprintf("\nValore indice Calinski-Harabasz: %f\n", CH))
  
  # Aggiornamento dataframe iterazioni/valore
  risultati <- rbind(risultati, data.frame(iterazione = i, valore = CH))
  
}


# Visualizzazione dei valori di Calinski-Harabasz per ogni matrice
print(risultati)



# Creazione del grafico a linee
grafico <- ggplot(data = risultati, aes(x = risultati[,1] , y = risultati[,2])) +
  geom_line(color = "blue", linewidth = 1) +
  ylim(0, max(risultati$valore)) +
  xlim(0, 2*n) +
  theme(panel.grid.major = element_line(color = "grey"), # Aggiunge la griglia principale
        panel.grid.minor = element_blank(), # Rimuove la griglia secondaria
        panel.background = element_blank()) +
  scale_x_continuous(breaks = round(seq(min(risultati$iterazione), max(risultati$iterazione), by = 1), 1)) +
  labs(title = "Grafico valore CH", x = "# righe manipolate", y = "Calinski-Harabasz index")


# Visualizzazione del grafico
visualizzaGrafico(grafico, n)



