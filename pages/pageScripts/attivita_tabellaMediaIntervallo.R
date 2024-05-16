tabMediaIntervallo <- controlliGeo %>%
  group_by(AnnoMese) %>%
  summarise(
    media = mean(intervallo, na.rm = T),
    mediana = median(intervallo, na.rm = T),
    moda = as.numeric(names(sort(-table(intervallo))[1]))
  )

# drop geographic data

tabMediaIntervallo <- tabMediaIntervallo %>% st_drop_geometry()
