# caricamento pacchetti
pacchettiStart <- c( #pacchetti da caricare subito
  "sf",
  "stringr"
)

pacchettiDopo <- c( #pacchetti da caricare dopo
  # "openxlsx",
  # "pak",
  # "remotes",
  "knitr",
  # "kableExtra",
  # "utils",
  # "tidyverse",
  "rmarkdown",
  # "rvest",
  # "googledrive",
  # "devtools",
  "rfortherestofus/pagedreport",
  "livelihoods-and-landscapes/qfieldcloudR"
)

# pacchetti di cui controllare l'installazione
pacchettiNecessari <- c(pacchettiStart, pacchettiDopo)
# installa quelli non installati
new.packages <- pacchettiNecessari[!(pacchettiNecessari %in% installed.packages()[,"Package"])]
if(length(new.packages)) renv::install(new.packages)
#carica quelli Start
invisible(lapply(pacchettiStart, library, character.only = TRUE))



rm(new.packages, pacchettiDopo, pacchettiNecessari, pacchettiStart)
gc()
