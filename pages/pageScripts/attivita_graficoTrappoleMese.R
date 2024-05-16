# grafico a barre del numero di trappole aggiunte nel periodo, cut per mese

periodo <- min(trap$Data.posizionamento):max(trap$Data.posizionamento)
periodo <- as.Date(periodo, origin = "1970-01-01")
periodo <- format(periodo, "%Y-%m")
periodo <- levels(as.factor(periodo))



tab <- as.data.frame(table(trap$AnnoMese))
colnames(tab) <- c("AnnoMese", "freq")
tab$AnnoMese <- as.character(tab$AnnoMese)

tab <- complete(tab, AnnoMese = periodo, fill=list(freq = 0))
