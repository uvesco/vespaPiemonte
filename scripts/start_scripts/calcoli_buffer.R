# script per creare un buffer multidistanza attorno ai nidi e caricare il geopackage su qfieldcloud
# necessario caricare loadParam.R
library(devtools)
library(qfieldcloudR)
library(sf)
source_gist("9282b0818446503625f15b930afa6c20")

# nidi <- st_read("/tmp/qfieldcloudproject/Vespa_velutina.gpkg",
#                 layer = "nidi")

# selezioni i nidi non primari

nidiS <- nidi[nidi$primario == FALSE,]

# calcolo il buffer attorno ai nidi

buffer <- multiDistanceBuffer(nidiS, parametri$distanze)

# buffer con solo i nidi non primari attivi negli ultimi parametri$scadenzaNidi anni

nidiS$anno <- as.numeric(format(nidiS$data_ritro, "%Y"))
annoCorrente <- as.numeric(format(Sys.Date(), "%Y"))
nidiS <- nidiS[(nidiS$anno_attivita >= (annoCorrente - parametri$scadenzaNidi)),]
buffer3 <- multiDistanceBuffer(nidiS, parametri$distanze)

# esporto il buffer in un file chiamato buffer.gpkg

st_write(buffer, "/tmp/qfieldcloudproject/buffer.gpkg", driver = "GPKG", layer="buffer", append = FALSE)
st_write(buffer3, "/tmp/qfieldcloudproject/buffer.gpkg", driver = "GPKG",  layer="buffer3", append = FALSE)

# post the buffer to qfieldcloud
# qfieldapi credentials and login
source("scripts/start_scripts/get_qfieldCloudApi_token.R")

# post the buffer to qfieldcloud
post_qfieldcloud_file(token$token, endpoint, project_id, "buffer.gpkg" , "/tmp/qfieldcloudproject/buffer.gpkg")

# remove temporary objects

rm(list = c(
  "endpoint",
  "nidiS",
  "project",
  "token",
  "qfieldPassword",
  "qfieldUsername",
  "annoCorrente",
  "multiDistanceBuffer"
  )
)  
