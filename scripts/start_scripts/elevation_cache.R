library(dplyr)
library(sf)
library(elevatr)
library(digest)

# Function to retry elevatr::get_elev_point
retry_get_elev_point <- function(data, src = "aws", z = 13, max_retries = 7) {
  for (retry in 1:max_retries) {
    try_result <- try(elevatr::get_elev_point(data, src = src, z = z), silent = TRUE)
    if (!inherits(try_result, "try-error")) {
      return(try_result)
    } else {
      cat("Attempt", retry, "failed. Retrying in ", 2^(retry)," seconds...\n")
      Sys.sleep(2^(retry))  # Wait for iteratively more (2^i) seconds before retrying
    }
  }
  stop("Maximum number of retries reached.")
}

# function to check if geographical data have changed

is_identical_checksum <- function(sf_points, geom_checksum, cache_file, checksum_file) {
  if (file.exists(checksum_file) & file.exists(cache_file)) {
    old_checksum <- readLines(checksum_file)
    if (old_checksum != geom_checksum) {
      return(FALSE)
          } else { 
      return(TRUE)}
    }else {
      return(FALSE)
    }
}

# Function to check and update elevation and other geographical data if needed
check_and_update_geo <- function(sf_points, geom_checksum, cache_file, checksum_file) {
  cat(paste0("Processing ", deparse(substitute(sf_points)), " data...\n"))
  if (is_identical_checksum(sf_points, geom_checksum, cache_file, checksum_file)){
    cat("Data has not changed, using cached data.\n")
    old_sf_points <- readRDS(cache_file)
    sf_points$elevation <- old_sf_points$elevation
    sf_points$elev_units <- old_sf_points$elev_units
    return(sf_points)
  } else {
    cat("Data has changed, calculating elevations...\n")
    writeLines(geom_checksum, checksum_file)
    return(retry_get_elev_point(sf_points))
  }
}
  
# Create the cache directory if it does not exist
if (!dir.exists(parametri$cache_dir)) {
  dir.create(parametri$cache_dir)
}

# Calculate checksums for the point geometries
nidi_checksum <- digest(st_geometry(nidi))
trap_checksum <- digest(st_geometry(trap))

# Check and update elevation data for both nidi and trap using parametri
nidi <- check_and_update_geo(nidi, nidi_checksum, parametri$nidi_cache_file, parametri$nidi_checksum_file)
trap <- check_and_update_geo(trap, trap_checksum, parametri$trap_cache_file, parametri$trap_checksum_file)

# If nidi data has changed update buffers
if(!is_identical_checksum(nidi, nidi_checksum, parametri$nidi_cache_file, parametri$nidi_checksum_file)) {
  cat("Nidi data has changed, calculating buffers...\n")
  # calculate buffers
  source("scripts/start_scripts/calcoli_buffer.R")
}

saveRDS(nidi, parametri$nidi_cache_file)
saveRDS(trap, parametri$trap_cache_file)

