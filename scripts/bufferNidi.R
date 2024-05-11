# script per creare un buffer multidistanza attorno ai nidi
library(devtools)
library(qfieldcloudR)

source_gist("9282b0818446503625f15b930afa6c20")
source("scripts/importGeoPackages.R")

# selezioni i nidi non primari

nidi <- nidi[nidi$primario == FALSE,]

# calcolo il buffer attorno ai nidi

buffer <- multiDistanceBuffer(nidi, c(600, 1500, 3000, 6500, 15000))

# esporto il buffer in un file chiamato buffer.gpkg

st_write(buffer, "/tmp/qfieldcloudproject/buffer.gpkg", driver = "GPKG", append = FALSE)

# post the buffer to qfieldcloud
# credentials
qfieldUsername <- Sys.getenv("QFIELD_CLOUD_USERNAME")
qfieldPassword <- Sys.getenv("QFIELD_CLOUD_PASSWORD")
endpoint <- "app.qfield.cloud"

# get the token
token <- qfieldcloud_login(qfieldUsername, qfieldPassword, endpoint)
# get the projects
project <- get_qfieldcloud_projects(token$token, endpoint)
# get the files list
projFiles <- get_qfieldcloud_files(token$token, endpoint, project[project$name == "vespaTO", "id"])

# post the buffer to qfieldcloud
post_qfieldcloud_file(token$token, endpoint, project[project$name == "vespaTO", "id"],"buffer.gpkg" , "/tmp/qfieldcloudproject/buffer.gpkg")
