# scripts to download data from the qfield cloud and elaborate the data
source("scripts/loadParam.R")
source("scripts/start_scripts/importFromQfieldCloud.R")
source("scripts/start_scripts/importGeoPackages.R")
source("scripts/start_scripts/importOtherGeodata.R")
#source("scripts/start_scripts/elevation_cache.R")
source("scripts/start_scripts/elevation.R")
source("scripts/start_scripts/calcoli_buffer.R")
source("scripts/start_scripts/calcoliTrappole.R")
# source("scripts/start_scripts/bufferNidi.R")
# source("scripts/start_scripts/calcoliTrappole.R")
# 
# # save all data in the environment to rdata file
# save.image(file = "/tmp/qfieldcloudproject/vespaVelutina.RData")
save.image(file = "/tmp/qfieldcloudproject/vespaVelutina.RData")

