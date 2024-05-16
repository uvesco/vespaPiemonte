# grafico a barre del numero di controlli per mese
controlliGeo$Data <- as.Date(controlliGeo$data, origin = "1970-01-01")

# controlliGeo$Mese <- format(controlliGeo$Data, "%m")
# controlliGeo$Anno <- format(controlliGeo$Data, "%Y")
# controlliGeo$AnnoMese <- paste(controlliGeo$Anno, controlliGeo$Mese, sep = "-")
controlliGeo$AnnoMese <- as.factor(format(controlliGeo$Data, "%Y-%m"))

periodo <- min(controlliGeo$data):max(controlliGeo$data)
periodo <- as.Date(periodo, origin = "1970-01-01")
periodo <- format(periodo, "%Y-%m")
periodo <- levels(as.factor(periodo))

tab <- as.data.frame(table(controlliGeo$AnnoMese))
colnames(tab) <- c("AnnoMese", "nControlli")
tab$AnnoMese <- as.character(tab$AnnoMese)

tab <- complete(tab, AnnoMese = periodo, fill=list(nControlli = 0))
