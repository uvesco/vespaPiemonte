
# grafico a barre orizzontali per la finestra di sostituzione della birra delle trappole

tempoMinimo <- 14 # giorni di tempo minimo tra un controllo e l'altro
tempoMassimo <- 21 # giorni di tempo massimo tra un controllo e l'altro

# calcolo la finestra di sostituzione della birra
# la finestra di sostituzione della birra è il periodo di tempo in cui la birra deve essere sostituita
# la birra deve essere sostituita se è presente da più di tempoMassimo giorni
# la birra non deve essere sostituita se è presente da meno di tempoMinimo giorni

# calcolo la finestra di sostituzione della birra

# trap$maxSostituzione <- tempoMassimo - trap$etaBirra
# trap$minSostituzione <- tempoMinimo - trap$etaBirra


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
