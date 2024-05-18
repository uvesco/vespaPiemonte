library(dplyr)
library(sf)
library(elevatr)

# Function to retry elevatr::get_elev_point
retry_get_elev_point <- function(data, src = "aws", z = 13, max_retries = 5) {
  for (retry in 1:max_retries) {
    try_result <- try(elevatr::get_elev_point(data, src = src, z = z), silent = TRUE)
    if (!inherits(try_result, "try-error")) {
      return(try_result)
    } else {
      cat("Attempt", retry, "failed. Retrying in 10 seconds...\n")
      Sys.sleep(2^(i))  # Wait for 10 seconds before retrying
    }
  }
  stop("Maximum number of retries reached.")
}



# Load the cached data if it exists
cache_file <- "data/combined_data.rds"
if (file.exists(cache_file)) {
  old_data <- readRDS(cache_file)
  # Check if geometry has changed
  trap_changed <- !identical(st_geometry(trap), st_geometry(old_data$trap))
  nidi_changed <- !identical(st_geometry(nidi), st_geometry(old_data$nidi))
  
} else {
  trap_changed <- TRUE
  nidi_changed <- TRUE
} 


if(trap_changed) {
  cat("Trap data has changed, calculating elevations...\n")

  # Calculate elevations
    
  trap <- retry_get_elev_point(trap)
  
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
  
  nidi <- retry_get_elev_point(nidi)
  
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
