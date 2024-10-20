# scripts to download data from the qfield cloud and elaborate the data
source("scripts/loadParam.R")
cat("loadParam.R done\n")
source("scripts/start_scripts/importFromQfieldCloud.R")
cat("importFromQfieldCloud.R done\n")
source("scripts/start_scripts/importGeoPackages.R")
cat("importGeoPackages.R done\n")
source("scripts/start_scripts/importOtherGeodata.R")
cat("importOtherGeodata.R done\n")
#source("scripts/start_scripts/elevation_cache.R")
source("scripts/start_scripts/elevation.R")
cat("elevation.R done\n")
source("scripts/start_scripts/calcoli_buffer.R")
cat("calcoli_buffer.R done\n")
source("scripts/start_scripts/calcoliTrappole.R")
cat("calcoliTrappole.R done\n")
# source("scripts/start_scripts/bufferNidi.R")
# source("scripts/start_scripts/calcoliTrappole.R")
# 
# # save all data in the environment to rdata file
# save.image(file = "/tmp/qfieldcloudproject/vespaVelutina.RData")
save.image(file = "/tmp/qfieldcloudproject/vespaVelutina.RData")
cat("complete_script_v2.R done\n")

