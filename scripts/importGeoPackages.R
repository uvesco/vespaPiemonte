library(sf)

nidi <- st_read(tempFiles[tempFiles$filename == "Vespa_velutina.gpkg", "tmp_file"],
                layer = "nidi")
trap <- st_read(tempFiles[tempFiles$filename == "Vespa_velutina.gpkg", "tmp_file"],
                layer = "trappole")
controlli <- st_read(tempFiles[tempFiles$filename == "Vespa_velutina.gpkg", "tmp_file"],
                     layer = "trappole_controlli")
contatti <- st_read(tempFiles[tempFiles$filename == "Vespa_velutina.gpkg", "tmp_file"],
                    layer = "contatti")
zoneTrappolaggio <- st_read(tempFiles[tempFiles$filename == "elaborazioniGrid.gpkg", "tmp_file"],
                            layer = "zoneTrappolaggio")

buffer <- st_read(tempFiles[tempFiles$filename == "elaborazioniGrid.gpkg", "tmp_file"],
                  layer = "buffer")

parchi <- st_read(tempFiles[tempFiles$filename == "pubData.gpkg", "tmp_file"],
                  layer = "parchi")

zsc_sic <- st_read(tempFiles[tempFiles$filename == "pubData.gpkg", "tmp_file"],
                   layer = "zsc_sic")

comuni <- st_read(tempFiles[tempFiles$filename == "pubData.gpkg", "tmp_file"],
                  layer = "comuni")

