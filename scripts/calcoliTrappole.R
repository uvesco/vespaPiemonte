# calcoli da applicare alle trappole
# 
# calcola l'età della birra scegliendo la data più recente tra l'ultimo controllo e la data di posizionamento della trappola
# se non c'è nessun controllo considera la data di posizionamento

# creo un dataframe con solo gli controlli più recenti per ciascuna trappola (la chiave comune è controlli$fk_uuid)

controlliRecenti <- tapply(controlli$data, controlli$fk_uuid, max)
controlliRecenti <- data.frame(fk_uuid = names(controlliRecenti), Data = as.Date(controlliRecenti, origin = "1970-01-01"))

# lettura trappole

trap$ultimoControllo <- controlliRecenti[match(trap$uuid, controlliRecenti$fk_uuid), "Data"]
rm(controlliRecenti)

# calcolo età birra
# scelgo la data più recente tra l'ultimo controllo e la data di posizionamento della trappola
# se non c'è nessun controllo considera la data di posizionamento'

trap$birra <- pmax(trap$ultimoControllo, trap$Data.posizionamento, na.rm = T)
trap$etaBirra <- as.numeric(Sys.Date() - trap$birra)

# controllo se ci sono trappole con età negativa

trap[trap$etaBirra < 0, c("ID", "Data.posizionamento", "ultimoControllo", "etaBirra")]

if(any(trap$etaBirra < 0)){
  stop("Ci sono trappole con età negativa")
}

# attribuzione della zona di trappolaggio

trapZone <- st_intersects(trap, zoneTrappolaggio, sparse = F)
tz <- apply(trapZone, 1, which)

trap$zone <- "Altro"
for(i in 1:length(tz)){
  if(!identical(zoneTrappolaggio$nome[tz[[i]]], character(0))){
    trap$zone[i] <- zoneTrappolaggio$nome[tz[[i]]]
  }
}


# grafico a barre orizzontali per la finestra di sostituzione della birra delle trappole

tempoMinimo <- 14 # giorni di tempo minimo tra un controllo e l'altro
tempoMassimo <- 21 # giorni di tempo massimo tra un controllo e l'altro

# calcolo la finestra di sostituzione della birra
# la finestra di sostituzione della birra è il periodo di tempo in cui la birra deve essere sostituita
# la birra deve essere sostituita se è presente da più di tempoMassimo giorni
# la birra non deve essere sostituita se è presente da meno di tempoMinimo giorni

# calcolo la finestra di sostituzione della birra

trap$maxSostituzione <- trap$etaBirra + tempoMassimo
trap$minSostituzione <- trap$etaBirra + tempoMinimo


# calcolo per ogni zona della moda dell'età della birra e la finestra di sostituzione della birra

# Seleziono solo le trappole con responsabile == team e data.rimozione == NA
trapTeam <- trap[trap$responsabile == "team" & is.na(trap$data.rimozione),]

modaEtaBirra <- tapply(trapTeam$birra, trapTeam$zone, function(x) {as.Date.character(names(which.max(table(x))))})
modaEtaBirra <- as.Date(modaEtaBirra, origin = "1970-01-01")

# trasformo in dataFrame
modaEtaBirra <- data.frame(zone = names(modaEtaBirra), etaBirra = modaEtaBirra, stringsAsFactors = F)

# aggiungo una colonna con il numero di trappole per zona
modaEtaBirra$nTrappole <- tapply(trapTeam$birra, trapTeam$zone, length)

# aggiungo una colonna con il numero di trappole con età birra minore della moda
trapTeam$modaEtaBirra <- modaEtaBirra$etaBirra[match(trapTeam$zone, modaEtaBirra$zone)]
trapTeam$isMinModa <- trapTeam$birra < trapTeam$modaEtaBirra
modaEtaBirra$nTrappoleMin <- tapply(trapTeam$isMinModa, trapTeam$zone, sum)

# aggiungo una colonna con minControllo della trappola più vecchia
modaEtaBirra$minimControllo <- as.Date(tapply((trapTeam$birra+14), trapTeam$zone, min))

# aggiungo colonne con la data minima per cambiare la birra

modaEtaBirra$minControllo <- modaEtaBirra$etaBirra + tempoMinimo
modaEtaBirra$maxControllo <- modaEtaBirra$etaBirra + tempoMassimo

modaEtaBirra$minimControllo[which(modaEtaBirra$minimControllo == modaEtaBirra$minControllo)] <- NA

data_prevista <- NA


gc()
