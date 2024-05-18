library(dplyr)
library(sf)
library(elevatr)

# Load the cached data if it exists
cache_file <- "data/combined_data.rds"
if (file.exists(cache_file)) {
  old_data <- readRDS(cache_file)
} else {
  old_data <- list(trap = NULL, nidi = NULL)
}

# Check if geometry has changed
trap_changed <- !identical(st_geometry(trap), st_geometry(old_data$trap))
nidi_changed <- !identical(st_geometry(nidi), st_geometry(old_data$nidi))

if(trap_changed) {
  cat("Trap data has changed, calculating elevations...\n")

  # Calculate elevations
    
  trap <- elevatr::get_elev_point(trap, src = "aws", z = 13)
  
  # Save the new data to cache
  saveRDS(new_data, cache_file)
} else {
  cat("Data has not changed, using cached data.\n")
  
  # use elevation form cached data
  trap$elevation <- old_data$trap$elevation
}

if(nidi_changed) {
  cat("Nidi data has changed, calculating elevations and buffers...\n")

  # Calculate elevations
    
  nidi <- elevatr::get_elev_point(nidi, src = "aws", z = 13)
  
  # calculate buffers
  
  source("scripts/start_scripts/bufferNidi.R")
  
  # Save the new data to cache
  saveRDS(new_data, cache_file)
} else {
  cat("Data has not changed, using cached data.\n")
  
  # use elevation form cached data
  nidi$elevation <- old_data$nidi$elevation
}

new_data <- list(nidi = nidi, trap = trap)

# Save the data for further processing if needed
dir.create("data", showWarnings = FALSE)

saveRDS(new_data, "data/combined_data.rds")
