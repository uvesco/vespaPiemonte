# script to download latest Vespa velutina data from the qfield cloud
#source("scripts/libraries.R")
library(qfieldcloudR)

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

# get the files
tempFiles <- data.frame(filename = NULL, tmp_file = NULL)

for (i in 1:nrow(projFiles)) {
  tempFiles <- rbind(tempFiles, get_qfieldcloud_file(token$token, endpoint, project[project$name == "vespaTO", "id"], projFiles[i, "name"]))
}

# move files to /tmp/qfieldcloudproject
dir.create("/tmp/qfieldcloudproject", showWarnings = FALSE)
for (i in 1:nrow(tempFiles)) {
  file.rename(tempFiles[i, "tmp_file"], paste0("/tmp/qfieldcloudproject/", tempFiles[i, "filename"]))
}

# download comuni from https://www.datigeo-piem-download.it/direct/Geoportale/RegionePiemonte/Limiti_amministrativi/AMBITI_AMMINISTRATIVI_COMUNI1.zip

utils::download.file("https://www.datigeo-piem-download.it/direct/Geoportale/RegionePiemonte/Limiti_amministrativi/AMBITI_AMMINISTRATIVI_COMUNI1.zip",
                     destfile = "/tmp/qfieldcloudproject/AMBITI_AMMINISTRATIVI_COMUNI1.zip")
utils::unzip("/tmp/qfieldcloudproject/AMBITI_AMMINISTRATIVI_COMUNI1.zip",
             exdir = "/tmp/qfieldcloudproject")
file.remove("/tmp/qfieldcloudproject/AMBITI_AMMINISTRATIVI_COMUNI1.zip")

# remove temporary objects

rm(list = c(
  "endpoint",
  "projFiles",
  "project",
  "qfieldPassword",
  "qfieldUsername",
  "token",
  "i",
  "tempFiles")
  )

gc()
