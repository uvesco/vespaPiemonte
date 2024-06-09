# credentials
qfieldUsername <- Sys.getenv("QFIELD_CLOUD_USERNAME")
qfieldPassword <- Sys.getenv("QFIELD_CLOUD_PASSWORD")
qfieldProject  <- Sys.getenv("QFIELD_CLOUD_PROJECTNAME")
endpoint <- "app.qfield.cloud"

# get the token
token <- qfieldcloud_login(qfieldUsername, qfieldPassword, endpoint)
# get the projects
project <- get_qfieldcloud_projects(token$token, endpoint)
# get the project id
project_id <- project[project$name == qfieldProject, "id"]
