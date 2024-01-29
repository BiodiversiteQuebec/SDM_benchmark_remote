ui <- navbarPage(
    "Exploration SDMs",
    tabPanel(
        "SDMs",
        sidebarLayout(
            sidebarPanel(
                width = 2,
                h4("Espèce"),
                selectInput("species_select",
                    label = "",
                    choices = species
                ),
                h4("Paramétrage"),
                selectInput("predictors",
                    label = "Prédicteurs environnementaux",
                    choices = c("Predictors", "noPredictors")
                ),
                selectInput("bias",
                    label = "Biais d'échantillonnage",
                    choices = c("Bias", "noBias")
                ),
                selectInput("spatial",
                    label = "Auto-corrélation spatiale",
                    choices = c("Spatial", "noSpatial")
                ),
                h4("Modèles INLA"),
                selectInput("inla_sortie",
                    label = "Métrique",
                    choices = c("pocc", "range")
                ),
                checkboxInput("inla_occs",
                    "Occurrences",
                    value = FALSE
                ),
                h4("Modèles Maxent"),
                checkboxInput("Maxent_occs",
                    "Occurrences",
                    value = FALSE
                ),
                checkboxInput("Maxent_pseudo_abs",
                    "Pseudo-absence",
                    value = FALSE
                )
            ),
            mainPanel(
                # First row
                fluidRow(
                    box(
                        title = "e-bird",
                        width = 4,
                        status = "primary",
                        plotOutput("map_eBird")
                    ),
                    box(
                        title = "mapSpecies",
                        width = 4,
                        status = "warning",
                        plotOutput("map_mapSpecies")
                    ),
                    box(
                        title = "Maxent",
                        width = 4,
                        status = "warning",
                        plotOutput("map_Maxent")
                    )
                ),
                # Third row
                fluidRow(
                    box(
                        title = "INLA",
                        width = 4,
                        status = "primary",
                        plotOutput("map_Vince")
                    ),
                    box(
                        title = "boosted regression tree",
                        width = 4,
                        status = "warning",
                        plotOutput("map_BRT")
                    ),
                    box(
                        title = "random forest",
                        width = 4,
                        status = "warning",
                        plotOutput("map_randomForest")
                    )
                )
            )
        )
    ),
    tabPanel(
        "Richesse spécifique",
        sidebarLayout(
            sidebarPanel(
                width = 2,
                h4("Paramétrage"),
                selectInput("predictors",
                    label = "Prédicteurs environnementaux",
                    choices = c("Predictors", "noPredictors")
                ),
                selectInput("bias",
                    label = "Biais d'échantillonnage",
                    choices = c("Bias", "noBias")
                ),
                selectInput("spatial",
                    label = "Auto-corrélation spatiale",
                    choices = c("Spatial", "noSpatial")
                )
            ),
            mainPanel(
                # First row
                fluidRow(
                    box(
                        title = "e-bird",
                        width = 4,
                        status = "primary",
                        plotOutput("")
                    ),
                    box(
                        title = "mapSpecies",
                        width = 4,
                        status = "warning",
                        plotOutput("")
                    ),
                    box(
                        title = "Maxent",
                        width = 4,
                        status = "warning",
                        plotOutput("")
                    )
                ),
                # Third row
                fluidRow(
                    box(
                        title = "INLA",
                        width = 4,
                        status = "primary",
                        plotOutput("rs_INLA")
                    ),
                    box(
                        title = "boosted regression tree",
                        width = 4,
                        status = "warning",
                        plotOutput("")
                    ),
                    box(
                        title = "random forest",
                        width = 4,
                        status = "warning",
                        plotOutput("")
                    )
                )
            )
        )
    )
)
