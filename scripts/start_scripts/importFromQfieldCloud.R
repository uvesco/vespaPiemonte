# script to download latest Vespa velutina data from the qfield cloud
#source("scripts/libraries.R")
library(qfieldcloudR)

if(file.exists("scripts/loadParam.R")){
  source("scripts/loadParam.R")
}

# qfieldapi credentials and login
source("scripts/start_scripts/get_qfieldCloudApi_token.R")

# get the files list
projFiles <- get_qfieldcloud_files(token$token, endpoint, project_id)

# get the files
tempFiles <- data.frame(filename = NULL, tmp_file = NULL)

for (i in 1:nrow(projFiles)) {
  tempFiles <- rbind(tempFiles, get_qfieldcloud_file(token$token, endpoint, project_id, projFiles[i, "name"]))
}

# move files to /tmp/qfieldcloudproject
dir.create("/tmp/qfieldcloudproject", showWarnings = FALSE)
for (i in 1:nrow(tempFiles)) {
  file.rename(tempFiles[i, "tmp_file"], paste0("/tmp/qfieldcloudproject/", tempFiles[i, "filename"]))
}

# download comuni from https://www.datigeo-piem-download.it/direct/Geoportale/RegionePiemonte/Limiti_amministrativi/AMBITI_AMMINISTRATIVI_COMUNI1.zip
if(!dir.exists(parametri$pubdata_cache_dir)) {
  dir.create(parametri$pubdata_cache_dir)
}
if(!file.exists(parametri$comuni_cache_file)) {
  cat("Downloading comuni from R script, not available from github action\n")
  utils::download.file("https://www.datigeo-piem-download.it/direct/Geoportale/RegionePiemonte/Limiti_amministrativi/Ambiti_amministrativi_comuni_serie_storica/AMBITI_AMMINISTRATIVI_COMUNI_2024.zip",
                       destfile = parametri$comuni_cache_file)
}

utils::unzip(parametri$comuni_cache_file,
             exdir = parametri$pubdata_cache_dir)

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
