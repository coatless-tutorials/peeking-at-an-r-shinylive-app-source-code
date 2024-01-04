# Software Requirements ----

# Specify the location of the Shinylive app
shinylive_app_url = "https://repo.r-wasm.org/"

# Software Requirements ----

# Install jsonlite to parse the app.json file
# Install shinylive to export an app.R or ui.R and server.R files
if (!requireNamespace("jsonlite", quietly = TRUE)) { install.packages("jsonlite") }
if (!requireNamespace("shinylive", quietly = TRUE)) { install.packages("shinylive") }

# File System Setup ----

# Setup a directory to download the data into
shinylive_app_download_dir = "01-downloaded-shinylive-app"
shinylive_converted_app_output_dir = "02-converted-shinylive-app-to-r-shiny"
shiny_to_shinylive_app_output_dir = "03-shiny-to-shinylive-app"
dir.create(shinylive_app_download_dir, showWarnings = FALSE)
dir.create(shinylive_converted_app_output_dir, showWarnings = FALSE)
dir.create(shiny_to_shinylive_app_output_dir, showWarnings = FALSE)

# Obtain a copy of the 'app.json' containing the source of the Shinylive app
download.file(
  paste0(shinylive_app_url, "app.json"),
  file.path(shinylive_app_download_dir, "app.json")
)

# Parse app.json ----

# Give the input file name to the function.
shinylive_app_data = jsonlite::fromJSON(
  txt = file.path(shinylive_app_download_dir, "app.json")
)

# View files included in the 'app.json'
shinylive_app_data$name

# Convert Shinylive app back into a Shiny app ----

# Retrieve only the app source file
# Check if 'app.R' is present in the  'name' file vector
if ("app.R" %in% shinylive_app_data$name) {
  app_contents = shinylive_app_data$content[shinylive_app_data$name %in% "app.R"]
  
  writeLines(
    app_contents, 
    file.path(shinylive_converted_app_output_dir, "app.R")
  )
} else if (
   all(c("ui.R", "server.R") %in% shinylive_app_data$name)
  ) {
  # Check if both 'ui.R' and 'server.R' are present in the 'name' file vector
  
  ui_contents = x$content[shinylive_app_data$name %in% "ui.R"]
  server_contents = x$content[shinylive_app_data$name %in% "server.R"]
  
  writeLines(ui_contents, file.path(shinylive_converted_app_output_dir, "ui.R"))
  writeLines(server_contents, file.path(shinylive_converted_app_output_dir, "server.R"))
} else {
  stop("Unable to detect either a single-file shiny app or a two-file shiny app.")
}

# Convert R Shiny app to a Shinylive app ----
shinylive::export(
  shinylive_converted_app_output_dir,
  shiny_to_shinylive_app_output_dir
)

# View newly converted Shinylive app ----
httpuv::runStaticServer(shiny_to_shinylive_app_output_dir)