# My Project

# Peeking at an R Shinylive App Source

Interested in learning what code is being used inside a serverless [R
Shinylive application](https://posit-dev.github.io/r-shinylive/)? If so,
this is the repository for you! Here’s a summary of what you can find in
the repository:

- [`00a-convert-shinylive-to-shiny.R`](00a-convert-shinylive-to-shiny.R):
  An R script that obtains and converts an R Shinylive script into an R
  Shiny script.
- [`01-downloaded-r-shinylive-app/app.json`](01-downloaded-r-shinylive-app/app.json):
  The source code and files powering the serverless R Shinylive app.
- [`02-converted-r-shinylive-app-to-r-shiny/app.R`](02-converted-r-shinylive-app-to-r-shiny/app.R):
  The converted code to run the R Shinylive app as a regular R Shiny
  app.
- [`zz-patched-converted-r-shinylive-app-to-r-shiny/app.R`](zz-patched-converted-r-shinylive-app-to-r-shiny/app.R):
  A patched version of the Shiny app that fixes a hiccup with DataTable
  rendering.
- [`zz-patched-r-shiny-to-r-shinylive-app/`](zz-patched-r-shiny-to-r-shinylive-app/):
  The conversion back into an R Shinylive app of patched Shiny app.
- [`experiments/`](experiments/): Exploring various parts of a Shinylive
  app and exporting Shiny apps.

## Background: R Shinylive Apps

R Shinylive is a technology from [Posit](https://posit.co/) that
combines [Shiny](https://shiny.posit.co),
[webR](https://docs.r-wasm.org/webr/latest/), and
[WebAssembly](https://webassembly.org/) to enable Shiny applications to
be run entirely in a web browser without the need for a **compute**
server. In essence, an R Shinylive application does not require a Shiny
server to run. Instead, it can run *anywhere* that can serve static HTML
web page files.

# Overview

For this exercise, we’re going to focus on being able to obtain the R
Shinylive app source that is powering the [webR binary R package
repository dashboard](https://repo.r-wasm.org/).

## `app.json`

R Shinylive app data is stored using \[JavaScript Object Notation
(JSON)\] inside of an `app.json` file. For each file that is converted
from a regular R Shiny app, there is an entry inside of a JSON array
that contains a subfield with three key-value pairs:

1.  `"name"`: The name of the file that was converted.
    - `app.R` or two separate entries with `ui.R` or `server.R`.
2.  `"content"`: The escaped contents of the file that was created.
3.  `"type"`: The kind of data stored inside `"content"`.
    - This will likely contain the value of `"text"`.

### Single-file app: app.R

For instance, if we have a single file Shiny app in `app.R` and we have
an RStudio project called `shinylive-to-shiny`, then we would expect two
entries in the `app.json`:

``` json
[
  {
    "name": "app.R",
    "content": "library(shiny)\nlibrary(dplyr)\n ... \nshinyApp(ui = ui, server = server)\n",
    "type": "text"
  },
  {
    "name": "shinylive-to-shiny.Rproj",
    "content": "Version: 1.0\n\nRestoreWorkspace: Default ...\n\nAutoAppendNewline: Yes\n",
    "type": "text"
  }
]
```

### Multi-file app: ui.R and server.R

For a two-file Shiny app that uses `ui.R` and `server.R` alongside an
RStudio project called `shinylive-to-shiny`, we would expect to have
three different entries array stored in `app.json`:

``` json
[
  {
    "name": "server.R",
    "content": server <- function(input, output) { ... }\n",
    "type": "text"
  },
  {
    "name": "ui.R",
    "content": "ui <- fluidPage(\n  sidebarLayout( ... )\n  )\n)",
    "type": "text"
  },
  {
    "name": "shinylive-to-shiny.Rproj",
    "content": "Version: 1.0\n\nRestoreWorkspace: Default ...\n\nAutoAppendNewline: Yes\n",
    "type": "text"
  }
]
```

## Extracting a Shinylive App

Given the above structure, we can use existing R packages and features
to obtain the `app.json`.
