# filtro per provincia
# filtrare con una riga prima di source:
# codProv <- 1 (1 = TO, 4 = CN)
buffer <- buffer[buffer$COD_PROV == codProv, ]
buffer3 <- buffer3[buffer3$COD_PROV == codProv, ]
controlliGeo <- controlliGeo[controlliGeo$provincia == codProv, ]
nidi <- nidi[nidi$provincia == codProv, ]
trap <- trap[trap$provincia == codProv, ]
zoneTrappolaggio <- zoneTrappolaggio[zoneTrappolaggio$COD_PROV == codProv, ]
