# scripts to download data from the qfield cloud and elaborate the data
source("scripts/loadParam.R")
# source("scripts/start_scripts/importFromQfieldCloud.R")
source("scripts/start_scripts/importGeoPackages.R")
# source("scripts/start_scripts/cache.R")
# source("scripts/start_scripts/bufferNidi.R")
# Load the cached data if it exists
  trap <- parametri$trap_cache_file
  nidi <- parametri$nidi_cache_file
source("scripts/start_scripts/calcoliTrappole.R")

# save all data in the environment to rdata file
save.image(file = "/tmp/qfieldcloudproject/vespaVelutina.RData")
