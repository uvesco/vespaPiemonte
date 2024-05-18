# scripts to download data from the qfield cloud and elaborate the data
source("scripts/loadParam.R")
# source("scripts/start_scripts/importFromQfieldCloud.R")
source("scripts/start_scripts/importGeoPackages.R")
# source("scripts/start_scripts/cache.R")
# source("scripts/start_scripts/bufferNidi.R")
# Load the cached data if it exists

  new_data <- readRDS(parametri$cacheFile)

  trap <- new_data$trap
  nidi <- new_data$nidi
source("scripts/start_scripts/calcoliTrappole.R")

# save all data in the environment to rdata file
save.image(file = "/tmp/qfieldcloudproject/vespaVelutina.RData")
