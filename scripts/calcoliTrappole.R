# calcoli da applicare alle trappole

# parametri
giorniXcontrollata <-30 # giorni di tempo massimo dall'ultimo controllo per considerare controllata una trappola

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

# indici per attività e controllo

attive <- is.na(trap$data.rimozione)
controllate <- is.na(trap$data.rimozione) & trap$etaBirra < (giorniXcontrollata + 1)


# attribuzione della zona di trappolaggio

trapZone <- st_intersects(trap, zoneTrappolaggio, sparse = F)
tz <- apply(trapZone, 1, which)

trap$zone <- NA
for(i in 1:length(tz)){
  if(!identical(zoneTrappolaggio$nome[tz[[i]]], character(0))){
    trap$zone[i] <- zoneTrappolaggio$nome[tz[[i]]]
  }
}

# attribuzione del comune di trappolaggio

trapComune <- st_intersects(trap, comuni, sparse = F)
tc <- apply(trapComune, 1, which)

trap$comune <- NA
for(i in 1:length(tc)){
  if(!identical(comuni$COMUNE[tc[[i]]], character(0))){
    trap$comune[i] <- comuni$COMUNE[tc[[i]]]
  }
}


# attribuzione del parco di trappolaggio

trapParco <- st_intersects(trap, parchi, sparse = F)
tp <- apply(trapParco, 1, which)

trap$parco <- NA
for(i in 1:length(tp)){
  if(!identical(parchi$nome_area_[tp[[i]]], character(0))){
    trap$parco[i] <- parchi$nome_area_[tp[[i]]]
  }
}


#attribuzione del sito di interesse comunitario di trappolaggio

trapZSC <- st_intersects(trap, zsc_sic, sparse = F)
tzsc <- apply(trapZSC, 1, which)

trap$zsc_sic <- NA
for(i in 1:length(tzsc)){
  if(!identical(zsc_sic$nome[tzsc[[i]]], character(0))){
    trap$zsc_sic[i] <- zsc_sic$nome[tzsc[[i]]]
  }
}


# attribuzione della provincia di trappolaggio

trapProvincia <- st_intersects(trap, comuni, sparse = F)
tp <- apply(trapProvincia, 1, which)

trap$provincia <- NA
for(i in 1:length(tp)){
  if(!identical(comuni$COD_PROV[tp[[i]]], character(0))){
    trap$provincia[i] <- comuni$COD_PROV[tp[[i]]]
  }
}


# aggiunta a ciascun poligono buffer di una colonna con il numero di trappole attive e controllate che ricadono all'interno del poligono
# 
# 
inter <- st_intersects(buffer, trap[controllate,])
buffer$nTrappoleControllate <- lengths(inter)
#calcolo dell'area dei buffer in km2
buffer$area <- st_area(buffer)
units(buffer$area) <- "km2"
#calcolo della densità di trappole controllate per km2
buffer$densita <- buffer$nTrappoleControllate/buffer$area

# calcolo distanza di ciascuna trappola dal nido più vicino

nidiTrap <- st_nearest_feature(trap, nidi)
# calculate the distance in meters
for(i in 1:nrow(trap)){
  trap$distanzaNido[i] <- st_distance(trap[i,], nidi[nidiTrap[i],])
}

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

# trasformazione dei controlli in oggetti geografici con la geometria della trappola
#aggiunta delle coordinate X e Y a trap
trap$X <- st_coordinates(trap)[,1]
trap$Y <- st_coordinates(trap)[,2]


trap$Data.posizionamento <- as.Date(trap$Data.posizionamento, origin = "1970-01-01")

trap$AnnoMese <- format(trap$Data.posizionamento, "%Y-%m")

periodo <- min(trap$Data.posizionamento):max(trap$Data.posizionamento)
periodo <- as.Date(periodo, origin = "1970-01-01")
periodo <- format(periodo, "%Y-%m")
periodo <- levels(as.factor(periodo))

controlliGeo <- merge(controlli, trap, by.x = "fk_uuid", by.y = "uuid", all.x = T, all.y = F)
controlliGeo <- st_as_sf(controlliGeo, coords = c("X", "Y"), crs = 32632)

# aggiunta di una colonna per i fori
controlliGeo$fori <- FALSE
# se forati TRUE e se data di controllo successiva a data di foratura <- TRUE
controlliGeo$data_foratura <- as.Date(controlliGeo$data_foratura, origin = "1970-01-01")
controlliGeo$fori[controlliGeo$Foratura == TRUE & controlliGeo$data_foratura < controlliGeo$Data] <- TRUE

# eliminazione di tutti gli oggetti intermedi


rm(list = c("i", "nidiTrap", "trapZone", "tz", "inter", "dateControlliPrecedenti", "comuni", "zsc_sic", "parchi", "trapComune", "trapParco",  "trapZSC", "tp", "tzsc", "trapProvincia", "tc"))


gc()
