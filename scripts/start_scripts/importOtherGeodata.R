library(sf)

comuni <- st_read(file.path(parametri$pubdata_cache_dir, "Ambiti_Amministrativi-Comuni.shp"),
                  quiet = TRUE)
