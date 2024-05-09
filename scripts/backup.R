# gets all project files from qfieldcloud, zip them and save them to google drive
## Load packages ----
library(googledrive)
library(purrr)
library(googlesheets4)
library(openxlsx)
options(googledrive_quiet = TRUE)

# foglio dei contatti ----
# Authenticate with Google Drive

json_key_path <- "/tmp/google_service_account.json"
if (!file.exists(json_key_path)) {
  stop("Service account key file does not exist. Check the path and ensure it's correctly stored.")
}

drive_auth(path = json_key_path)

# Read the file from Google Drive
googlesheets4::gs4_auth(token = drive_token())
contattiG <- googlesheets4::read_sheet(Sys.getenv("GOOGLE_SHEET_CONTATTI"))
openxlsx::write.xlsx(contattiG, "/tmp/qfieldcloudproject/contattiG.xlsx", rowNames = FALSE)

# zip the project ----

zipfileProject <- file.path("/tmp", paste0("projdir.zip"))

utils::zip(zipfile = zipfileProject, 
           files = dir("/tmp/qfieldcloudproject", full.names = T))

