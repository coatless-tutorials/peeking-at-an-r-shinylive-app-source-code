# Setup file system
dir.create("experiments/r-shiny", showWarnings = FALSE)
dir.create("experiments/r-shinylive", showWarnings = FALSE)

# Individual app exports ---- 

## Convert app.R to shinylive ----
shinylive::export("experiments/r-shiny/single-file-app-r", 
                  "experiments/r-shinylive/converted-one-file-app")

## Convert ui.R & server.R to shinylive ----
shinylive::export("experiments/r-shiny/two-file-ui-server-app-r", 
                  "experiments/r-shinylive/converted-two-file-app")

## Check if apps work ----

# httpuv::runStaticServer("experiments/r-shinylive/converted-one-file-app")

# httpuv::runStaticServer("experiments/r-shinylive/converted-two-file-app")


# Merged app export ----
shinylive::export("experiments/r-shiny/single-file-app-r", 
                  "experiments/r-shinylive/merged-file-app", 
                  subdir = "converted-one-file-app")
shinylive::export("experiments/r-shiny/two-file-ui-server-app-r", 
                  "experiments/r-shinylive/merged-file-app", 
                  subdir = "converted-two-file-app")

## Check if merged apps work ----
httpuv::runStaticServer("experiments/r-shinylive/merged-file-app")
