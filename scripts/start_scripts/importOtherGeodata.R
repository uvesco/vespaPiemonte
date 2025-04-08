library(sf)

comuni <- st_read(file.path(parametri$pubdata_cache_dir, "Ambiti_Amministrativi-Comuni_2024.shp"),
                  quiet = TRUE)
