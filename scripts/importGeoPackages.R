library(sf)

nidi <- st_read("/tmp/qfieldcloudproject/Vespa_velutina.gpkg",
                layer = "nidi")
trap <- st_read("/tmp/qfieldcloudproject/Vespa_velutina.gpkg",
                layer = "trappole")
controlli <- st_read("/tmp/qfieldcloudproject/Vespa_velutina.gpkg",
                     layer = "trappole_controlli")
contatti <- st_read("/tmp/qfieldcloudproject/Vespa_velutina.gpkg",
                    layer = "contatti")
zoneTrappolaggio <- st_read("/tmp/qfieldcloudproject/elaborazioniGrid.gpkg",
                            layer = "zoneTrappolaggio")
buffer <- st_read("/tmp/qfieldcloudproject/buffer.gpkg",
                  layer = "buffer")
parchi <- st_read("/tmp/qfieldcloudproject/pubData.gpkg",
                  layer = "parchi")
zsc_sic <- st_read("/tmp/qfieldcloudproject/pubData.gpkg",
                   layer = "zsc_sic")
comuni <- st_read("/tmp/qfieldcloudproject/pubData.gpkg",
                  layer = "comuni")
