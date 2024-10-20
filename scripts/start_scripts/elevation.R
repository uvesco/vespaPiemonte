library(dplyr)
library(sf)
library(elevatr)

# Function to retry elevatr::get_elev_point
retry_get_elev_point <- function(data, src = "aws", z = 12, max_retries = 7) {
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

# Function to always update elevation data
update_elevation_data <- function(sf_points, z = 13, src = "aws") {
  cat(paste0("Updating elevation data for ", deparse(substitute(sf_points)), "...\n"))
  return(retry_get_elev_point(sf_points, src = src, z = z))
}

# Update elevation data for nidi and trap using parameters
cat("DEBUG: updating nidi elevation data...\n")
nidi <- update_elevation_data(nidi)
cat("DEBUG: updating trap elevation data...\n")
trap <- update_elevation_data(trap)

# # Update buffers for nidi
# cat("Calculating buffers for nidi...\n")
# source("scripts/start_scripts/calcoli_buffer.R")


