library(shiny)
library(dplyr)
library(DT)
library(purrr)

ui <- fluidPage(
  theme = bslib::bs_theme(version = 5),
  div(
    class = "container my-3",
    h1("WebR binary R package repository"),
    p(
      class = "lead",
      "This CRAN-like repository contains R packages compiled to WebAssembly for use with webR.",
      "Set this page's URL as the named",
      code("repos"),
      "argument when using the",
      code("webr::install()"),
      "command to use this repository as the source for downloading binary R packages."
    ),
    p(
      "By default, ",
      code("webr::install()"),
      "will use the public repository hosted at",
      a(href = "https://repo.r-wasm.org/", "https://repo.r-wasm.org/"),
      ". See the",
      a(href = "https://docs.r-wasm.org/webr/latest/packages.html", "webR documentation"),
      "for further information about webR."
    ),
    div(
      class = "my-3",
      h2("Repo statistics"),
      div(
        class = "card-group",
        div(
          class = "card",
          div(
            class = "card-body d-flex flex-column",
            h4(class = "card-title", "Built R packages: ",
               textOutput("built", inline = TRUE)),
            p(
              class = "card-text flex-fill",
              "CRAN packages that have been built for WebAssembly and are available for download from this repo."
            )
          )
        ),
        div(
          class = "card",
          div(
            class = "card-body d-flex flex-column",
            h4(class = "card-title", "Available R packages: ",
               textOutput("available", inline = TRUE)),
            p(
              class = "card-text flex-fill",
              "CRAN packages for which all of the package dependencies have also been built for WebAssembly and are available for download from this repo."
            )
          )
        )
      ),
    ),
    div(
      class = "my-3",
      h2("Table of packages:"),
      DTOutput("webr_pkgs")
    )
  )
)

server <- function(input, output) {
  res <- withProgress(
    {
      webr_info <- as.data.frame(available.packages(
        contriburl = "https://repo.r-wasm.org/bin/emscripten/contrib/4.3"
      ))
      avail_pkgs <- c(rownames(webr_info),
                      c("base", "compiler", "datasets", "graphics", "grDevices",
                        "grid", "methods", "splines", "stats", "stats4",
                        "tools", "utils", "parallel", "webr"))
      incProgress(2 / 5)

      deps <- tools::package_dependencies(packages = rownames(webr_info),
                                          db = webr_info, recursive = TRUE)
      incProgress(2 / 5)

      deps <- tibble(
        Package = names(deps),
        Available = deps |> map(\(x) all(x %in% avail_pkgs)),
        Depends = deps,
        Missing = deps |> map(\(x) x[!(x %in% avail_pkgs)])
      )
      
      incProgress(1 / 5)

      package_table <- webr_info |>
        select(c("Package", "Version", "Repository")) |>
        left_join(deps, by = "Package") |>
        arrange(Package)
      
      names(package_table) <- c("Package", "Version", "Repository",
                                "Available", "Depends",
                                "Missing")
      list(
        table = package_table,
        n_built = dim(package_table)[1],
        n_avail = sum(as.numeric(deps$Available))
      )
    },
    message = "Loading package lists and crunching dependencies",
    detail = "This may take a little while...",
    value = 0
  )

  output$built <- renderText({
    res$n_built
  })

  output$available <- renderText({
    res$n_avail
  })

  output$webr_pkgs <- renderDT(
    datatable(
      res$table,
      rownames = FALSE,
      selection = "none",
      options = list(
        ordering = FALSE,
        search = list(regex = TRUE),
        columns = JS("[
          null,
          null,
          { searchable: false, visible: false },
          { title: 'All depends available?' },
          {
            searchable: false,
            title: 'Depends<br><small>Missing dependencies are shown in bold.</small>'
          },
          { searchable: false, visible: false } 
        ]"),
        rowCallback=JS("
          function(row, data) {
            if (data[3][0]) {
              $('td:eq(2)', row).html('Yes');
            } else {
              $('td:eq(2)', row).html('<b>No</b>');
            }
            $('td:eq(0)', row).html(`<a target=\"_blank\" href=\"${data[2]}/${data[0]}_${data[1]}.tgz\">${data[0]}</a>`);
            $('td:eq(3)', row).html(data[4].map((v) => {
              if (data[5].includes(v))
                return '<b>' + v + '</b>';
              return v;
            }).join(', '));
          }
        ")
      )
    )
  )
}

shinyApp(ui = ui, server = server)

