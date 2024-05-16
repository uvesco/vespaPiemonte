# script che crea una lista dei parametri da utilizzare in tutti gli script

parametri <- list()

# trappole ------------------------------------------------

parametri$giorniXcontrollata <-30 # giorni di tempo massimo dall'ultimo controllo per considerare controllata una trappola
parametri$tempoMinimo <- 14 # giorni di tempo minimo tra un controllo e l'altro
parametri$tempoMassimo <- 21 # giorni di tempo massimo tra un controllo e l'altro

# buffer ------------------------------------------------

parametri$distanze <- c(600, 1500, 3000, 6500, 15000) # distanze dei buffer
parametri$scadenzaNidi <- 3 # anni per calcolo del buffer con solo i nidi non primari attivi negli ultimi parametri$scadenzaNidi anni (buffer3)

