# script to download latest Vespa velutina data from the qfield cloud
#source("scripts/libraries.R")
library(renv)
# renv::install("livelihoods-and-landscapes/qfieldcloudR")
#library(qfieldcloudR)
library(sf)
# functions from qfielcloudR
# qfieldcloud_login
qfieldcloud_login <- function(username, password, endpoint) {
  
  credentials <- list(
    email = username,
    password = password
  )
  
  # todo handle empty / faulty endpoint
  login_url <- paste0("https://", endpoint, "/api/v1/auth/login/")
  
  httr::handle_reset(login_url)
  
  login_status <- tryCatch(
    error = function(cnd) {
      login_status <- list(
        status = "fail - no response from server. Check endpoint URL is correct.",
        token = NULL
      )
    },
    {
      token <- httr::POST(
        url = login_url,
        body = credentials,
        encode = "json"
      )
      
      status_code <- token$status_code
      
      if (status_code < 399) {
        login_status <- list(
          status = "success",
          token = httr::content(token, as = "parsed")$token
        )
      } else {
        login_status <- list(
          status = "fail",
          token = NULL
        )
      }
      
      login_status
    }
  )
  
  login_status
}

# get_qfieldcloud_projects
get_qfieldcloud_projects <- function(token, endpoint) {
  
  # todo handle query params to get community projects
  url <- paste0("https://", endpoint, "/api/v1/projects?include-public=false")
  
  projects <- tryCatch(
    error = function(cnd) {
      projects <- "Failed to get user's projects - check endpoint and that login was successful."
    },
    {
      
      projects_response <- httr::GET(
        url = url,
        httr::add_headers(Authorization = paste0("token ", token))
      )
      
      projects_parsed <- httr::content(projects_response, as = "parsed")
      
      names <- c()
      id <- c()
      user_role <- c()
      
      for (i in projects_parsed) {
        names <- c(names, i$name)
        id <- c(id, i$id)
        user_role <- c(user_role, i$user_role)
      }
      
      projects <- data.frame(name = names, id = id, user_role = user_role)
      
      projects
    }
    
  )
  
  projects
}

# get qfieldcloud files
get_qfieldcloud_file <- function(token, endpoint, project_id, filename) {
  
  url <- url <- paste0("https://", endpoint, "/api/v1/files/", project_id, "/", filename, "/")
  
  file_path_df <- tryCatch(
    error = function(cnd) {
      file_path_df <- "Failed to download file"
    },
    {
      # need to use followlocation = FALSE to get redirect url
      file_data <- httr::with_config(httr::config(followlocation = FALSE), httr::GET(
        url = url,
        httr::add_headers(Authorization = paste0("token ", token))
      ))
      
      if ("location" %in% names(file_data$headers)) {
        location <- file_data$headers$location
        
        file_data <- httr::GET(
          url = location
        )
      }
      ext <- xfun::file_ext(filename)
      fname <- xfun::sans_ext(filename)
      
      f_data <- httr::content(file_data, as = "raw")
      
      tmp_dir <- tempdir()
      tmp_file <- paste0(tmp_dir, "/", filename)
      
      writeBin(f_data, tmp_file)
      
      file_path_df <- data.frame(filename = filename, tmp_file = tmp_file)
    }
  )
  
  file_path_df
}

# credentials
qfieldUsername <- "umberto.vesco@yahoo.it"
qfieldPassword <- "NF%&hslGhtY2Pp0M"
endpoint <- "app.qfield.cloud"
# get the token
token <- qfieldcloud_login(qfieldUsername, qfieldPassword, endpoint)
# get the projects
project <- get_qfieldcloud_projects(token$token, endpoint)
# # get the files
# get_qfieldcloud_files(token$token, endpoint, project[project$name == "vespaTO", "id"])
# get the file
fiveVv <- get_qfieldcloud_file(token$token, endpoint, project[project$name == "vespaTO", "id"], "Vespa_velutina.gpkg")
fiveElab <- get_qfieldcloud_file(token$token, endpoint, project[project$name == "vespaTO", "id"], "elaborazioniGrid.gpkg")

geopackPath     <- fiveVv$tmp_file
geopackElabPath <- fiveElab$tmp_file

# save the file
trap <- st_read(geopackPath,
                layer = "trappole")
controlli <- st_read(geopackPath,
                     layer = "trappole_controlli")
contatti <- st_read(geopackPath,
                    layer = "contatti")
zoneTrappolaggio <- st_read(geopackElabPath,
                            layer = "zoneTrappolaggio")

buffer <- st_read(geopackElabPath,
                  layer = "buffer")


# dir.create("latestData", showWarnings = F)
# file.remove(file.path("latestData", (dir("latestData"))))
# file.copy(fiveVv$tmp_file, file.path("latestData", "Vespa_velutina.gpkg"))
rm(list = c(
  "endpoint",
  "fiveVv",
  "project",
  "qfieldPassword",
  "qfieldUsername",
  "token",
  "geopackPath",
  "geopackElabPath",
  "fiveElab"
))
gc()

