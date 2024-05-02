# # load libraries
# library(rgdal)
# library(maptools)
# library(leaflet)
# library(htmlwidgets)
# library(RCurl)
# library(readr)
# library(htmltools)
# library(sf)
# 
# dati     <- readRDS(paste0(getwd(), "/2019/datiCompl_23.rds"))
# # for(i in which(sapply(dati, is.character))){ #errore non utf
# #   dati[, i] <- iconv(dati[, i], to="UTF-8")
# # }
# rampadef <- readRDS(paste0(getwd(), "/2019/dati/rampadef.RDS"  ))
# 
# # filtro per data
# # dati <- dati[!is.na(dati$data_rilevazione),]
# # dati <- dati[dati$data_rilevazione < as.Date("2020-11-01"),]
# # dati <- dati[dati$data_rilevazione > as.Date("2020-05-01") |
# #                dati$data_rilevazione < as.Date("2019-11-01"),]
# 
# # regioni -----------------------------------------------------------------
# 
# # importazione tabella regioni
# #importazione dati regione (le province sono ulteriormente incasinate 
# # perché hanno di nuovo cambiato codice: si usa solo la regione che ha codice più stabile)
# regioniCodici <- unique(
#   read_delim(paste0(getwd(), "/2019/dati/geo/Limiti01012019/Codici statistici e denominazioni delle ripartizioni sovracomunali .csv"),
#              ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-1"), trim_ws = TRUE, skip = 1)[, c(2L, 4L, 6L, 8L, 9L)])
# #merge nomi regione
# regioniCodici$COD_REG <- as.integer(regioniCodici$COD_REG)
# regioniCodici$DEN_RIP <- as.factor(regioniCodici$DEN_RIP) #riordino livelli per avere i boxplot in ordine
# regioniCodici$DEN_RIP <- ordered(regioniCodici$DEN_RIP, levels=c("Nord-ovest", "Nord-est", "Centro", "Sud", "Isole"))
# # str(regioniCodici)
# dati <- merge(dati, regioniCodici)
# rm(regioniCodici)
# 
# 
# # alveari -----------------------------------------------------------------
# 
# 
# # dataset alveari separati
# datialv <- NULL
# for(i in 1:10){
#   datitemp <- dati[, c("COM_ISTAT_NUM", "nome_apiario", "numero_totale_alveari_apiario", 
#                        "apiario_stanziale_nomade", "tipologia_trattamento_invernale", 
#                        "metodo_rilevamento", paste0("varroe_alveare_", i), 
#                        "data_rilevazione", "operatore", "tipologia_trattamento_tampone", 
#                        "data_tampone", "sintomi", "COD_REG", "COMUNE", "X", "Y", "perc_inf", 
#                        "color", "pointch", "mese", "anno", "progtemp", "COD_RIP",
#                        "DEN_RIP", "DEN_REG", "TIPO_REG")]
#   colnames(datitemp)[which(colnames(datitemp) == paste0("varroe_alveare_", i))] <- "varroe_alveare"
#   datialv <- rbind(datialv, datitemp)
#   rm(datitemp)
# }
# rm(i)
# datialv <- datialv[!is.na(datialv$varroe_alveare), ]
# datialv$soprasoglia <- (datialv$varroe_alveare/3) > 5
# 
# 
# #### dato geografico ----
# #2do: come Aspromiele mettere coppie apiario-comune
# geores <- dati[, c("X", "Y", "perc_inf", "color", "pointch", "data_rilevazione", "COMUNE", "DEN_REG", "numero_totale_alveari_apiario", "tratInv", "tratEst", "data_tampone")]
# # filtro dati senza data
# geores <- geores[!is.na(geores$data_rilevazione), ]
# 
# #post agosto
# #geores <- dati[dati$data_rilevazione > as.Date("2019-07-31"), c("X", "Y", "perc_inf", "color", "pointch")]
# 
# geores_coord<-as.matrix(geores[,1:2])
# #add random error
# errore <- 2000
# for(i in 1:dim(geores_coord)[1]){
#   set.seed(19791120+i); geores_coord[i, 1] <- geores_coord[i, 1] + runif(1, -errore, errore)
#   set.seed(i);          geores_coord[i, 2] <- geores_coord[i, 2] + runif(1, -errore, errore)
# }
# 
# row.names(geores_coord)<-1:nrow(geores_coord)
# EPSG <- make_EPSG()
# llCRS<-CRS(EPSG[grep("32632", EPSG$code), 3])
# #rm(EPSG)
# geores <- SpatialPointsDataFrame(coords=geores_coord, data=geores, proj4string = llCRS)
# rm(geores_coord,llCRS)
# 
# #geo_proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" # necessario trasformare in L/L WGS84
# geo_proj <- CRS(EPSG[grep("4326", EPSG$code), 3])
# comment(geores@proj4string) <- paste0(slot(slot(geores, "proj4string"), "projargs"), " +type=crs")
# geores <- spTransform(geores,geo_proj)
# 
# # creare gruppi per combinazione mese e anno
# #lista dei gruppi
# date <- format(geores$data_rilevazione, "%b-%y") 
# dateb <- format(geores$data_rilevazione, "%y-%m") 
# mesiOrd <- unique(date)[order(unique(dateb))] # mesi ordinati
# listaRecMesi <- list()
# for(i in 1:length(mesiOrd)){
#   listaRecMesi[[i]] <- which(date ==mesiOrd[i])
# }
# 
# ########### Oggetto Mappa ----------------
# 
# # titolo/avviso della mappa https://stackoverflow.com/questions/49072510/r-add-title-to-leaflet-map
# tag.map.title <- tags$style(HTML("
#   .leaflet-control.map-title { 
#     transform: translate(-50%,20%);
#     position: fixed !important;
#     left: 50%;
#     bottom: 0%;
#     text-align: center;
#     padding-left: 10px; 
#     padding-right: 10px; 
#     background: rgba(255,255,255,0.75);
#     # font-weight: bold;
#     font-style: italic;
#     font-size: 14px;
#   }
# "))
# 
# title <- tags$div(
#   tag.map.title, HTML("Le coordinate si riferiscono al territorio comunale e <b>NON agli apiari</b>")
# )  
# 
# 
# mappa <- leaflet()
# 
# mappa <- addControl(mappa, title, position = "bottomleft", className="map-title")
# 
# for(i in 1:length(mesiOrd)){
#   mappa <- addCircleMarkers(mappa,
#                             data = geores[listaRecMesi[[i]],], 
#                             lat = geores[listaRecMesi[[i]],]$Y,
#                             lng = geores[listaRecMesi[[i]],]$X,
#                             color = geores[listaRecMesi[[i]],]$color,
#                             fillOpacity = 0,
#                             opacity = 1,
#                             radius = 1,
#                             label = lapply(paste0(
#                               "infestazione: ", round(geores[listaRecMesi[[i]],]$perc_inf, 2), "% <br/>",
#                               "data del rilevamento: ", format(geores[listaRecMesi[[i]],]$data_rilevazione, "%d/%m/%y"), " <br/> ",
#                               "comune: ", geores[listaRecMesi[[i]],]$COMUNE, " <br/> ",
#                               "regione: ", geores[listaRecMesi[[i]],]$DEN_REG, " <br/> ",
#                               "alveari dell'apiario: ", geores[listaRecMesi[[i]],]$numero_totale_alveari_apiario, " <br/> ",
#                               "trattamento invernale: ", geores[listaRecMesi[[i]],]$tratInv, " <br/> ",
#                               "trattamento tampone: ", geores[listaRecMesi[[i]],]$tratEst, " <br/> ",
#                               "data del tampone: ", geores[listaRecMesi[[i]],]$data_tampone
#                               ), 
#                               htmltools::HTML
#                               ), 
#                             group = mesiOrd[i])
#    
# }
#     
# 
# #addPolygons(data = buff_xy, color = "green", fill = "green") %>%
# mappa <- addTiles(mappa, group = "OSM (default)")
# mappa <- addProviderTiles(mappa, providers$Esri.WorldStreetMap, group = "Street")
# mappa <- addProviderTiles(mappa, providers$Esri.WorldTerrain, group = "Terrain") 
# mappa <- addProviderTiles(mappa, providers$Stamen.Toner, group = "Toner")
# 
# mappa <- addLayersControl(mappa,
#                           baseGroups = c("OSM (default)", "Street", "Terrain", "Toner"),
#                           overlayGroups = mesiOrd,
#                           options = layersControlOptions(collapsed = FALSE)
#                           )
# #titoli per selettori
# mappa <- htmlwidgets::onRender(mappa,"
#         function() {
#             $('.leaflet-control-layers-overlays').prepend('<label style=\"text-align:center\"><b>Monitoraggi<b/></label>');
#         }
#     ")
# 
# mappa <- htmlwidgets::onRender(mappa,"
#         function() {
#             $('.leaflet-control-layers-base').prepend('<label style=\"text-align:center\"><b>Carta di base<b/></label>');
#         }
#     ")
# 
# 
# mappa <- addLegend(mappa, "bottomleft", pal = colorNumeric(rampadef, c(0,30)), values = geores$perc_inf,
#           title = "Varroa foretica",
#           labFormat = labelFormat(suffix = "%"),
#           opacity = 1)
# #attivo solo l'ultimo
# for(i in 1:length(mesiOrd)){
#   if(i == length(mesiOrd)){
#     mappa <- showGroup(mappa, mesiOrd[i])
#   }else{
#     mappa <-hideGroup(mappa, mesiOrd[i])
#   }
# }
# 
# mappa
# saveWidget(mappa, 'monitoraggioZAV.html', selfcontained = T)
# ftpUpload("monitoraggioZAV.html", 
#           to = "ftp://uvesco.altervista.org/unaapi/monitoraggioZAV.html",
#           userpwd = "uvesco:8^84xc16TUU4")
# 
