# calcoli da applicare alle trappole
# Librerie ---------------------------------------------------------------
library(sf)
# library(elevatr)

# definizione taxa ---------------------------------------------------------------

taxa <- data.frame(
  colonne = c("Vespa_velutina_tot", 
              "Vespa_crabro_tot", 
              "altri_Vespidae", 
              "Apis.mellifera", 
              "Bombus.sp.", 
              "Altri_Anthophila", 
              "Lepidoptera",
              "Sirphidae", 
              "Diptera", 
              "Altro"),
  etichette = c("Vespa velutina", 
                "Vespa crabro", 
                "Altri Vespidae", 
                "Apis mellifera", 
                "Bombus sp.", 
                "Altri clade Anthophila", 
                "Lepidoptera",
                "Sirphidae", 
                "Altri Diptera", 
                "Altro")
  
)

# arrotondamenti quota ---------------------------------------------------------------

## nidi ---------------------------------------------------------------

nidi$elevation <- round(nidi$elevation, 0)

## trappole ---------------------------------------------------------------

trap$elevation <- round(trap$elevation, 0)

# calcolo età della birra ---------------------------------------------------------------
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

# trap[trap$etaBirra < 0, c("ID", "Data.posizionamento", "ultimoControllo", "etaBirra")]

if(any(trap$etaBirra < 0)){
  stop("Ci sono trappole con età negativa")
}

# trap attive e trap controllate ---------------------------------------------------------------

trap$attiva <- is.na(trap$data.rimozione)
trap$controllata <- is.na(trap$data.rimozione) & trap$etaBirra < (parametri$giorniXcontrollata + 1)

# attribuzioni geografiche ---------------------------------------------------------------

## trap - settore ---------------------------------------------------------------

trapZone <- st_intersects(trap, zoneTrappolaggio, sparse = F)
tz <- apply(trapZone, 1, which)

trap$zone <- NA
for(i in 1:length(tz)){
  if(!identical(zoneTrappolaggio$nome[tz[[i]]], character(0))){
    trap$zone[i] <- zoneTrappolaggio$nome[tz[[i]]]
  }
}

## trap - comune ---------------------------------------------------------------

trapComune <- st_intersects(trap, comuni, sparse = F)
tc <- apply(trapComune, 1, which)

trap$comune <- NA
for(i in 1:length(tc)){
  if(!identical(comuni$comune_nom[tc[[i]]], character(0))){
    trap$comune[i] <- comuni$comune_nom[tc[[i]]]
  }
}
trap$comune_ist <- NA
for(i in 1:length(tc)){
  if(!identical(comuni$comune_ist[tc[[i]]], character(0))){
    trap$comune_ist[i] <- comuni$comune_ist[tc[[i]]]
  }
}
trap$provin_sig <- NA
for(i in 1:length(tc)){
  if(!identical(comuni$provin_sig[tc[[i]]], character(0))){
    trap$provin_sig[i] <- comuni$provin_sig[tc[[i]]]
  }
}

## nidi - comune ---------------------------------------------------------------

nidiComune <- st_intersects(nidi, comuni, sparse = F)
nc <- apply(nidiComune, 1, which)

nidi$comune <- NA
for(i in 1:length(nc)){
  if(!identical(comuni$comune_nom[nc[[i]]], character(0))){
    nidi$comune[i] <- comuni$comune_nom[nc[[i]]]
  }
}

nidi$provin_sig <- NA
for(i in 1:length(nc)){
  if(!identical(comuni$provin_sig[nc[[i]]], character(0))){
    nidi$provin_sig[i] <- comuni$provin_sig[nc[[i]]]
  }
}

# ## nidi - provincia ---------------------------------------------------------------
# 
# nidiProvincia <- st_intersects(nidi, province, sparse = F)
# np <- apply(nidiProvincia, 1, which)
# 
# nidi$provincia <- NA
# for(i in 1:length(np)){
#   cat("nido: ", i, "\n")
#   if(!identical(province$COD_PROV[np[[i]]], character(0))){
#     nidi$provincia[i] <- province$COD_PROV[np[[i]]]
#   }
# }

## trap - parco ---------------------------------------------------------------

trapParco <- st_intersects(trap, parchi, sparse = F)
tp <- apply(trapParco, 1, which)

trap$parco <- NA
for(i in 1:length(tp)){
  if(!identical(parchi$nome_area_[tp[[i]]], character(0))){
    trap$parco[i] <- parchi$nome_area_[tp[[i]]]
  }
}


## trap - natura2000 ---------------------------------------------------------------

trapZSC <- st_intersects(trap, zsc_sic, sparse = F)
tzsc <- apply(trapZSC, 1, which)

trap$zsc_sic <- NA
for(i in 1:length(tzsc)){
  if(!identical(zsc_sic$nome[tzsc[[i]]], character(0))){
    trap$zsc_sic[i] <- zsc_sic$nome[tzsc[[i]]]
  }
}


# ## trap - provincia ---------------------------------------------------------------
# 
# trapProvincia <- st_intersects(trap, province, sparse = F)
# tp <- apply(trapProvincia, 1, which)
# 
# trap$provincia <- NA
# for(i in 1:length(tp)){
#   if(!identical(province$COD_PROV[tp[[i]]], character(0))){
#     trap$provincia[i] <- province$COD_PROV[tp[[i]]]
#   }
# }



## settori - province ---------------------------------------------------------------

zoneTrappolaggio$provincia <- NA
for(i in 1:nrow(zoneTrappolaggio)){
  zoneTrappolaggio <- st_intersection(zoneTrappolaggio, province)
}

# calcoli buffer -----------------------------------------------------------------
# passaggio da multipoligono a poligono

buffer <- st_cast(buffer, "POLYGON")
buffer3 <- st_cast(buffer3, "POLYGON")
buffer <- st_intersection(buffer, province)
buffer3 <- st_intersection(buffer3, province)

# aggiunta a ciascun poligono buffer di una colonna con il numero di trappole attive e controllate che ricadono all'interno del poligono
# 
# 
inter <- st_intersects(buffer, trap[trap$controllata,])
buffer$nTrappoleControllate <- lengths(inter)

inter <- st_intersects(buffer3, trap[trap$controllata,])

buffer3$nTrappoleControllate <- lengths(inter)

# calcolo dell'area dei buffer in km2 
buffer$area <- st_area(buffer)
units(buffer$area) <- "km2"

buffer3$area <- st_area(buffer3)
units(buffer3$area) <- "km2"

#calcolo della densità di trappole controllate per km2
buffer$densita <- buffer$nTrappoleControllate/buffer$area
buffer3$densita <- buffer3$nTrappoleControllate/buffer3$area

# calcolo distanza di ciascuna trappola dal nido più vicino ---------------------------------------------------------------

nidiTrap <- st_nearest_feature(trap, nidi)
# calculate the distance in meters
for(i in 1:nrow(trap)){
  trap$distanzaNido[i] <- st_distance(trap[i,], nidi[nidiTrap[i],])
}



# calcoli controlli ---------------------------------------------------------------
# 
# calcolo del controllo precedente o se in assenza la data di posa della trappola
# data del controllo precedente: data del controllo precedente più recente
# se non c'è nessun controllo precedente considera la data di posizionamento della trappola

controlli$Data <- as.Date(controlli$data, origin = "1970-01-01")
controlli$DataPrec <- as.Date(NA)
for(i in 1:nrow(controlli)){
  dateControlliPrecedenti <- controlli$Data[controlli$fk_uuid == controlli$fk_uuid[i] & controlli$Data < controlli$Data[i]]
  if(length(dateControlliPrecedenti) > 0){
    controlli$DataPrec[i] <- as.Date(max(dateControlliPrecedenti), origin = "1970-01-01")
  } else {
    controlli$DataPrec[i] <- as.Date(trap$Data.posizionamento[trap$uuid == controlli$fk_uuid[i]], origin = "1970-01-01")
  }
}
controlli$intervallo <- as.numeric(controlli$Data - controlli$DataPrec)

# data media del periodo di cattura da calcolare come media tra la data di controllo e la data del controllo precedente solo inrevallo minore di 31 e se manomissione FALSE


intervalloBreve <- controlli$intervallo < 31 & (controlli$Manomissione == FALSE | is.na(controlli$Manomissione))
controlli$DataMediaCattura <- as.Date(NA)
controlli$DataMediaCattura[intervalloBreve] <- as.Date(round((as.integer(controlli$Data[intervalloBreve]) + as.integer(controlli$DataPrec[intervalloBreve]))/2), origin = "1970-01-01")
controlli$AnnoMeseMedioCattura <- format(controlli$DataMediaCattura, "%Y-%m")


# controllli geografici ---------------------------------------------------------------
# trasformazione dei controlli in oggetti geografici con la geometria della trappola
#aggiunta delle coordinate X e Y a trap
trap$X <- st_coordinates(trap)[,1]
trap$Y <- st_coordinates(trap)[,2]


trap$Data.posizionamento <- as.Date(trap$Data.posizionamento, origin = "1970-01-01")

trap$AnnoMese <- format(trap$Data.posizionamento, "%Y-%m")
# 
# periodo <- min(trap$Data.posizionamento):max(trap$Data.posizionamento)
# periodo <- as.Date(periodo, origin = "1970-01-01")
# periodo <- format(periodo, "%Y-%m")
# periodo <- levels(as.factor(periodo))

controlliGeo <- merge(controlli, trap, by.x = "fk_uuid", by.y = "uuid", all.x = T, all.y = F)
controlliGeo <- st_as_sf(controlliGeo, coords = c("X", "Y"), crs = 32632)

# calcoli fori ---------------------------------------------------------------
# aggiunta di una colonna per i fori
controlliGeo$fori <- FALSE
# se forati TRUE e se data di controllo successiva a data di foratura <- TRUE
controlliGeo$data_foratura <- as.Date(controlliGeo$data_foratura, origin = "1970-01-01")
controlliGeo$fori[controlliGeo$Foratura == TRUE & controlliGeo$data_foratura < controlliGeo$Data] <- TRUE

# chiusura dello script ---------------------------------------------------------------

# eliminazione di tutti gli oggetti intermedi

rm(list = c("i", "nidiTrap", "trapZone", "tz", "inter", "dateControlliPrecedenti", "zsc_sic", "parchi", "trapParco",  "trapZSC", "tp", "tzsc", "trapProvincia", "trapComune", "tc", "nc", "np", "comuni", "province", "intervalloBreve", "nidiComune", "nidiProvincia"))

# pulizia della memoria

gc()

