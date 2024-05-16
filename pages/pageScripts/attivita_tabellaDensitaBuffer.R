# tabella con la densità di trappole per km2 nelle aree buffer
#numero di trappole per buffer

tabDensity <- data.frame(
  distanza = buffer3$distance,
  n = buffer3$nTrappoleControllate,
  area = round(buffer3$area, 2),
  densita = round(buffer3$densita, 2)
)

# unisco per distanza

tabDensity <- tabDensity %>%
  group_by(distanza) %>%
  summarise(
    n = sum(n),
    area = sum(area),
    densita = sum(n) / sum(area)
  )

