# tabella delle trappole totali, attive, controllate nel mese nelle fasce del buffer

# tabella con il numero di trappole per classi di distanza dal nido più vicino
tabTrapBuffer <- data.frame(
  distanza = attributes(table(
    cut(
      trap$distanzaNido,
      breaks = c(0, sort(unique(buffer$distance)), Inf),
      dig.lab = 7
    )
  ))$dimnames[[1]],
  totali = as.integer(table(cut(
    trap$distanzaNido,
    breaks = c(0, sort(unique(buffer$distance)), Inf),
  ))),
  attive = as.integer(table(cut(
    trap$distanzaNido[trap$attiva],
    breaks = c(0, sort(unique(buffer$distance)), Inf),
  ))),
  controllate = as.integer(table(cut(
    trap$distanzaNido[trap$controllata],
    breaks = c(0, sort(unique(buffer$distance)), Inf),
  )))
)

tabTrapBuffer <- rbind(
  tabTrapBuffer,
  data.frame(
    distanza = "Totale",
    totali = sum(tabTrapBuffer$totali),
    attive = sum(tabTrapBuffer$attive),
    controllate = sum(tabTrapBuffer$controllate)
  )
  
)

