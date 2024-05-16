# grafico a torta del numero totale di esemplari catturati per taxon con switch del mese

# creo dataframe con il numero totale di catture per taxon per mese/anno

cattureTot <- controlliGeoTemp[!is.na(controlliGeoTemp$AnnoMeseMedioCattura),] %>%
  group_by(AnnoMeseMedioCattura) %>%
  summarise(
    across(
      .cols = taxa$colonne,
      .fns = ~ sum(.x, na.rm = T)
    )
  ) %>%
  st_drop_geometry() %>%
  complete(AnnoMeseMedioCattura = periodo, fill = mapply(function(x,y) { y }, taxa$colonne, rep(0, length(taxa$colonne)), SIMPLIFY = FALSE,USE.NAMES = TRUE)) # soluzione per creare la lista di zeri nominata: https://stackoverflow.com/posts/17842875/revisions

# transpose dataframe

cattureTot <- cattureTot %>% 
  pivot_longer(cols = -AnnoMeseMedioCattura, names_to = "taxon", values_to = "catture")

cattureTot$etichette <- taxa$etichette[match(cattureTot$taxon, taxa$colonne)]

mesi <- sort(unique(cattureTot$AnnoMeseMedioCattura))

# put the dataframe in wide format

cattureTot <- cattureTot %>% 
  pivot_wider(names_from = AnnoMeseMedioCattura, values_from = catture)




# plotly

meseInizio <- which(mesi == "2024-02")
mesi <- mesi[meseInizio:length(mesi)]

p <- plot_ly(data = cattureTot, labels = taxa$etichette, values = cattureTot[[mesi[1]]], type = "pie", sort = FALSE, automargin = TRUE)
for(i in 1:length(mesi)){
  p <- p %>% add_pie(labels = taxa$etichette, values = cattureTot[[mesi[i]]], visible = FALSE)
}

dropDown <- list()
for(i in 1:length(mesi)){
  visibilities <- rep(FALSE, length(mesi))
  visibilities[i] <- TRUE
  dropDown[[i]] <- list(
    method = "update",
    args = list(
      list(visible = visibilities)
    ),
    label = mesi[i]
  )
}


p <- p %>% layout(
  updatemenus = list(
    list(
      type = "dropdown",
      x = 0.2,
      y = 1.1,
      showactive = TRUE,
      buttons = dropDown
    )
  )
)
