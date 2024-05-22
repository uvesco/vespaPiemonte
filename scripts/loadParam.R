# script che crea una lista dei parametri da utilizzare in tutti gli script

parametri <- list()

# trappole ------------------------------------------------

parametri$giorniXcontrollata <-30 # giorni di tempo massimo dall'ultimo controllo per considerare controllata una trappola
parametri$tempoMinimo <- 14 # giorni di tempo minimo tra un controllo e l'altro
parametri$tempoMassimo <- 21 # giorni di tempo massimo tra un controllo e l'altro

# buffer ------------------------------------------------

parametri$distanze <- c(600, 1500, 3000, 6500, 15000) # distanze dei buffer
parametri$scadenzaNidi <- 3 # anni per calcolo del buffer con solo i nidi non primari attivi negli ultimi parametri$scadenzaNidi anni (buffer3)

# cache files ------------------------------------------------

parametri$cache_dir <- "cache"

parametri$nidi_cache_file <- file.path(parametri$cache_dir, "nidi.rds")
parametri$trap_cache_file <- file.path(parametri$cache_dir, "trap.rds")

parametri$nidi_checksum_file <- file.path(parametri$cache_dir, "nidi_checksum.txt")
parametri$trap_checksum_file <- file.path(parametri$cache_dir, "trap_checksum.txt")

parametri$pubdata_cache_dir <- file.path(parametri$cache_dir, "pubdata")
parametri$comuni_cache_file <- file.path(parametri$pubdata_cache_dir, "AMBITI_AMMINISTRATIVI_COMUNI1.zip")
parametri$comuni_checksum_file <- file.path(parametri$pubdata_cache_dir, "comuni_checksum.txt")

# cartelle download ------------------------------------------------

parametri$download_dir <- "download"
parametri$download_project_dir <- file.path(parametri$download_dir, "project")

# todo: collegare negli scripts
