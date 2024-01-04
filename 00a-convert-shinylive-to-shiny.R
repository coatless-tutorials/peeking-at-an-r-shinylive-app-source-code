# Conversion from shinylive to shiny ----

#' Convert Shinylive Apps to a Shiny R App
#' 
#' The function converts a serverless R Shinylive App into a traditional 
#' R Shiny app by downloading the `app.json` and retrieving source files found
#' in the content key that match with either a single app configuration (`app.R`)
#' or a two-file app configuration (`ui.R` and `server.R`).
#' 
#' @param shinylive_app_url                  A URL to the Shinylive App to convert
#' @param shinylive_app_download_dir         Directory where the shinylive's `app.json`
#'                                           should be placed.
#' @param shinylive_converted_app_output_dir Directory where the converted
#'                                           single or two-file Shiny App should
#'                                           be placed. 
#' @param shiny_to_shinylive_app_output_dir  Directory where the re-converted
#'                                           Shinylive App from the Shiny App 
#'                                           should be placed.
#' @param convert_back_to_shinylive          Re-convert the converted Shiny app
#'                                           back to an R Shinylive app
#'                                           
#' @return
#' This function does not return a value, instead it causes side effects in
#' the specified directory related to obtaining a Shinylive app and 
#' converting it to an R Shiny app.
#' 
#' @examples
#' # Obtain the repo overview Shinylive app showing webR data
#' convert_shinylive_to_shiny("https://repo.r-wasm.org/")
convert_shinylive_to_shiny = function(
    shinylive_app_url,
    shinylive_app_download_dir = "01-downloaded-r-shinylive-app",
    shinylive_converted_app_output_dir = "02-converted-r-shinylive-app-to-r-shiny",
    shiny_to_shinylive_app_output_dir = "03-r-shiny-to-r-shinylive-app",
    convert_back_to_shinylive = FALSE) {
  
  # Install jsonlite to parse the app.json file
  # Install shinylive to export an app.R or ui.R and server.R files
  if (!requireNamespace("jsonlite", quietly = TRUE)) { install.packages("jsonlite") }
  if (!requireNamespace("shinylive", quietly = TRUE)) { install.packages("shinylive") }
  
  # File System Setup
  dirs = c(shinylive_app_download_dir, 
           shinylive_converted_app_output_dir, 
           shiny_to_shinylive_app_output_dir)
  dirs_created = sapply(dirs, function(dir) dir.create(dir, showWarnings = FALSE, recursive = TRUE))
  
  # Obtain a copy of 'app.json'
  download.file(paste0(shinylive_app_url, "app.json"), file.path(dirs[1], "app.json"))
  
  # Parse app.json
  shinylive_app_data = jsonlite::fromJSON(file.path(dirs[1], "app.json"))
  
  # Convert Shinylive app to Shiny
  if ("app.R" %in% shinylive_app_data$name) {
    app_contents = shinylive_app_data$content[shinylive_app_data$name == "app.R"]
    writeLines(app_contents, file.path(dirs[2], "app.R"))
  } else if (all(c("ui.R", "server.R") %in% shinylive_app_data$name)) {
    ui_contents = shinylive_app_data$content[shinylive_app_data$name == "ui.R"]
    server_contents = shinylive_app_data$content[shinylive_app_data$name == "server.R"]
    writeLines(ui_contents, file.path(dirs[2], "ui.R"))
    writeLines(server_contents, file.path(dirs[2], "server.R"))
  } else stop("Unable to detect either a single-file shiny app or a two-file shiny app.")
  
  if (convert_back_to_shinylive) {
    # Convert Shiny app to Shinylive
    convert_shiny_to_shinylive_and_preview(dirs[2], dirs[3])
  }
    
}

# Conversion from shiny to shinylive with preview ----

#' Convert an R Shiny to an R Shinylive App and Preview it
#' 
#' This function is a wrapper around the `shinylive` package's `export()`
#' function alongside of the proposed preview command.
#' 
#' @param shiny_app_dir             Directory where a single or two-file
#'                                  Shiny App exists.
#' @param shinylive_app_output_dir  Directory where the converted
#'                                  Shinylive App from the Shiny App 
#'                                  should be placed.
#' @param preview_app               Launch a preview of the Shinylive app?                                      
#' @return
#' This function does not return a value, instead it causes side effects in
#' the specified directories related to converting an R Shiny App into
#' an R Shinylive app.
#' 
#' @examples
#' # Re-convert the previously converted Shinylive app showing webR data
#' convert_shiny_to_shinylive_and_preview(
#'   "zz-patched-converted-r-shinylive-app-to-r-shiny",
#'   "zz-patched-r-shiny-to-r-shinylive-app"
#' )
convert_shiny_to_shinylive = function(
    shiny_app_dir, 
    shinylive_app_output_dir,
    preview_app = TRUE) {
  
  # Convert Shiny app to Shinylive
  shinylive::export(shiny_app_dir, shinylive_app_output_dir)
  
  # View the converted Shinylive app
  if (preview_app) httpuv::runStaticServer(shinylive_app_output_dir)
}


