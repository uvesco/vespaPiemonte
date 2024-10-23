# grafico a barre dinamico con possibilità di selezionare le colonne (taxon) da visualizzare
# ogni barra è costituita dal numero di trappole che hanno catturato almeno un individuo di quel taxon e dalle trappole che non hanno catturato nulla

controlliGeoTemp <- controlliGeo[, c( taxa$colonne, "Manomissione", "fori", "AnnoMeseMedioCattura")]

# unique(controlliGeoTemp$AnnoMeseMedioCattura)

# periodo

# periodo <- min(trap$Data.posizionamento):max(trap$Data.posizionamento)
# periodo <- as.Date(periodo, origin = "1970-01-01")
periodo <- as.Date("2023-11-01"):Sys.Date() # bug fix emergenza non risolutivo
periodo <- format(periodo, "%Y-%m")
periodo <- levels(as.factor(periodo))


# elimino i controlli con manomissione
controlliGeoTemp$Manomissione <- as.logical(controlliGeoTemp$Manomissione)
controlliGeoTemp <- controlliGeoTemp[controlliGeoTemp$Manomissione == FALSE | is.na(controlliGeoTemp$Manomissione),]

# creo dataframe con il numero di catture positive per ogni taxon per mese
cattureTF <- controlliGeoTemp[!is.na(controlliGeoTemp$AnnoMeseMedioCattura),] %>%
  group_by(AnnoMeseMedioCattura) %>%
  summarise(
    across(
      .cols = taxa$colonne,
      .fns = ~ sum(.x > 0, na.rm = T)
    )
  ) %>%
  st_drop_geometry() %>%
  
  # complete the dataframe with the months with no cattures
  complete(AnnoMeseMedioCattura = periodo, fill = mapply(function(x,y) { y }, taxa$colonne, rep(0, length(taxa$colonne)), SIMPLIFY = FALSE,USE.NAMES = TRUE)) # soluzione per creare la lista di zeri nominata: https://stackoverflow.com/posts/17842875/revisions


# creo dataframe con il controlli negativi per ogni taxon per mese
controlliTF <- controlliGeoTemp[!is.na(controlliGeoTemp$AnnoMeseMedioCattura),] %>%
  group_by(AnnoMeseMedioCattura) %>%
  summarise(
    across(
      .cols = taxa$colonne,
      .fns = ~ sum(.x == 0, na.rm = T)
    )
  ) %>%
  st_drop_geometry() %>%
  # complete the dataframe with the months with no captures
  complete(AnnoMeseMedioCattura = periodo, fill = mapply(function(x,y) { y }, taxa$colonne, rep(0, length(taxa$colonne)), SIMPLIFY = FALSE,USE.NAMES = TRUE)) # soluzione per creare la lista di zeri nominata: https://stackoverflow.com/posts/17842875/revisions

# unisco i due dataframe
# aggiunta colonna tipo per distinguere tra catture e non catture
controlliTF$tipo <- "assenza"
cattureTF$tipo <- "presenza"

cattureTF <- rbind(cattureTF, controlliTF)

rm(catture, controlliTF)

# plotly


# grafico a barre con plotly con il numero di controlli che hanno catturato almeno un individuo di quel taxon e dei controlli che non ne hanno catturati, con possibilità di selezionare le colonne (taxon) da visualizzare
# 
# ogni barra è costituita dal numero di controlli che hanno catturato almeno un individuo di quel taxon e dai controlli che non hanno catturato nulla

# Create a basic plotly object with the first set of y-variables
p <- plot_ly(data = cattureTF, x = ~AnnoMeseMedioCattura, y = ~get(taxa$colonne[1]), color =  ~tipo, colors = c("lightblue", "red"), type ="bar")

# # Add traces for the remaining y-variables

p <- p %>% add_trace(y = ~Vespa_crabro_tot, visible = FALSE)
p <- p %>% add_trace(y = ~altri_Vespidae, visible = FALSE)
p <- p %>% add_trace(y = ~Apis.mellifera, visible = FALSE)
p <- p %>% add_trace(y = ~Bombus.sp., visible = FALSE)
p <- p %>% add_trace(y = ~Altri_Anthophila, visible = FALSE)
p <- p %>% add_trace(y = ~Lepidoptera, visible = FALSE)
p <- p %>% add_trace(y = ~Sirphidae, visible = FALSE)
p <- p %>% add_trace(y = ~Diptera, visible = FALSE)
p <- p %>% add_trace(y = ~Altro, visible = FALSE)


# q: can you create add_trace without a loop?
# a: yes, you can create add_trace without a loop
# q: can you code it for me?
# 




# p <- layout(p, barmode = "stack")
# p
dropDown <- list()
for(i in 1:nrow(taxa)){
  visibilities <- rep(FALSE, nrow(taxa))
  visibilities[i] <- TRUE
  visibilities <- as.vector(matrix(rep(visibilities, 2), 2, nrow(taxa), byrow = T ))
  dropDown[[i]] <- list(
    method = "update",
    args = list(
      list(visible = visibilities),
      list(title = taxa$etichette[i])
    ),
    label = taxa$etichette[i]
  )
}

# Add layout to include the dropdown menu

p <- p %>%
  layout(
    xaxis = list(title = "mesi"),  # Custom x-axis label
    yaxis = list(title = "controlli"),   # Custom y-axis label
    updatemenus = list(
      list(
        type = "dropdown",
        x = 0.2,
        y = 1.1,
        showactive = TRUE,
        buttons = dropDown
      )
    ),
    barmode = "stack"
  )
