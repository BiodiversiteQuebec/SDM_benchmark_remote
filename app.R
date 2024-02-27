# ================================================================================
# Chargement packages & data
# ================================================================================

#### Packages ####
# -------------- #
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(leaflet)
library(sf)
library(htmltools)
library(gdalcubes)
library(rstac)
library(terra)
library(stringr)
library(ENMeval)
library(rgbif)
library(geodata)
library(rmapshaper)
library(rnaturalearth)

#### Local data ####
# ---------------- #

# Species data
# ------------
species <- c(
    "bonasa_umbellus",
    "catharus_bicknelli",
    "catharus_fuscescens",
    "catharus_guttatus",
    "catharus_ustulatus",
    "falcipennis_canadensis",
    "junco_hyemalis",
    "melospiza_georgiana",
    "melospiza_lincolnii",
    "melospiza_melodia",
    "poecile_atricapillus",
    "poecile_hudsonicus",
    "setophaga_americana",
    "setophaga_caerulescens",
    "setophaga_castanea",
    "setophaga_cerulea",
    "setophaga_coronata",
    "setophaga_fusca",
    "setophaga_magnolia",
    "setophaga_palmarum",
    "setophaga_pensylvanica",
    "setophaga_petechia",
    "setophaga_pinus",
    "setophaga_ruticilla",
    "setophaga_striata",
    "setophaga_tigrina",
    "setophaga_virens"
)

# Several Polygons for Qc
# -----------------------
qc <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_CR_NIV_01.gpkg")
qc_fus <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_Unique_poly.gpkg")

region <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/REGION_interet_sdm.gpkg")
lakes_qc <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/REGION_LAKES_QC_sdm.gpkg")

# rs_n01 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N01_wkt_raw_obs.txt", sep = "\t", h = T) # impossible to load
rs_n02 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N02_wkt_raw_obs.txt", sep = "\t", h = T)
rs_n03 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N03_wkt_raw_obs.txt", sep = "\t", h = T)
rs_n04 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N04_wkt_raw_obs.txt", sep = "\t", h = T)
rs_pix_10x10 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_10x10_wkt_raw_obs.txt", sep = "\t", h = T)

# ================================================================================
# server
# ================================================================================
server <- function(input, output, session) {
    #### Map selection
    observeEvent(input$predictors, {
        if (input$predictors == "noPredictors") {
            updateRadioGroupButtons(session, "spatial", choices = "Spatial")
        } else {
            updateRadioGroupButtons(session, "spatial", choices = c("Spatial", "noSpatial"))
        }
    })
    # eBird
    path_map_ebird <- reactive({
        paste0(input$species_select, "_range.tif")
    })

    # Vincent - INLA
    id_feat_Vince <- reactive({
        paste0(input$species_select, "_", input$model_output, "_2017")
    })

    # Maxent

    path_map_Maxent <- reactive({
        if (input$model_output == "pocc") {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_Maxent_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_Maxent_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    # MapSpecies
    path_map_mapSpecies <- reactive({
        if (input$model_output == "pocc") {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_ewlgcpSDM_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_ewlgcpSDM_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    # BRT
    path_map_brt <- reactive({
        if (input$model_output == "pocc") {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_brt_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_brt_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    # Random Forest
    path_map_randomForest <- reactive({
        if (input$model_output == "pocc") {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_randomForest_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_randomForest_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    #### Map visualization
    # eBird
    output$map_eBird <- renderPlot({
        mp <- terra::rast(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/eBird_maps/", path_map_ebird()))

        terra::plot(mp,
            axes = F,
            main = "Abondance",
            mar = NA
        )
        plot(st_geometry(qc), add = T, border = "grey")
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
        # }
    })

    # Vincent
    output$map_Vince <- renderPlot({
        go_cat <- rast(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/", id_feat_Vince(), ".tif"))

        if (input$model_output == "range") {
            terra::plot(go_cat,
                axes = F,
                main = "Aire de distribution",
                mar = NA,
                col = c("#f6f8e0", "#009999"),
                key.pos = NULL
            )

            legend("topright",
                fill = c("#f6f8e0", "#009999"),
                border = "black",
                legend = c("absente", "présente"),
                bty = "n"
            )

            plot(st_geometry(qc),
                add = T,
                border = "grey"
            )
            plot(st_geometry(lakes_qc),
                add = T,
                col = "white",
                border = "grey"
            )
        } else {
            rr_crop <- raster::crop(go_cat, qc_fus)
            rr_mask <- mask(rr_crop, qc_fus)

            plot(rr_mask,
                axes = F,
                mar = NA,
                main = "Probabilité de présence"
            )
            plot(st_geometry(qc),
                add = T,
                border = "grey"
            )
            plot(st_geometry(lakes_qc),
                add = T,
                col = "white",
                border = "grey"
            )
        }
        if (input$occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))

            plot(occs, add = T, pch = 16, col = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 1), cex = 0.5)
        }
    })

    # MapSPecies
    output$map_mapSpecies <- renderPlot({
        pred_crop <- rast(path_map_mapSpecies())

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = ifelse(input$model_output == "pocc", "Intensité", "Aire de distribution")
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )

        if (input$occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))
            plot(occs, add = T, pch = 16, col = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 1), cex = 0.5)
        }
    })

    # Maxent
    output$map_Maxent <- renderPlot({
        pred_crop <- rast(path_map_Maxent())

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = ifelse(input$model_output == "pocc", "Probabilité de présence", "Aire de distribution"),
            range = c(0, 1)
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
        if (input$occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))
            plot(occs, add = T, pch = 16, col = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 1), cex = 0.5)
        }
        if (input$pseudo_abs == TRUE) {
            if (input$bias == "noBias") {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_region_Maxent_noBias.gpkg"))
                plot(pabs, add = T, pch = 16, col = rgb(139, 69, 19, maxColorValue = 255, alpha = 125), cex = 0.5)
            } else if (input$predictors == "noPredictors") {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_", input$species_select, "_Maxent_noPredictors_Bias_Spatial.gpkg"))
                plot(pabs, add = T, pch = 16, col = rgb(139, 69, 19, maxColorValue = 255, alpha = 125), cex = 0.5)
            } else if (input$spatial == "Spatial") {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_", input$species_select, "_Maxent_Predictors_Bias_Spatial.gpkg"))
                plot(pabs, add = T, pch = 16, col = rgb(139, 69, 19, maxColorValue = 255, alpha = 125), cex = 0.5)
            } else {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_", input$species_select, "_Maxent_Predictors_Bias_noSpatial.gpkg"))
                plot(pabs, add = T, pch = 16, col = rgb(139, 69, 19, maxColorValue = 255, alpha = 125), cex = 0.5)
            }
        }
    })

    # BRT
    output$map_BRT <- renderPlot({
        pred_crop <- rast(path_map_brt())

        plot(pred_crop,
            axes = F,
            mar = NA,
            # main = ifelse(input$model_output, "Probabilité de présence", "Aire de distribution"),
            range = c(0, 1)
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
        if (input$occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))
            plot(occs, add = T, pch = 16, col = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 1), cex = 0.5)
        }
    })

    # Random Forest
    output$map_randomForest <- renderPlot({
        pred_crop <- rast(path_map_randomForest())

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = ifelse(input$model_output == "pocc", "Probabilité de présence", "Aire de distribution"),
            range = c(0, 1)
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
        if (input$occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))
            plot(occs, add = T, pch = 16, col = rgb(0, 0, 0, alpha = 0.5, maxColorValue = 1), cex = 0.5)
        }
    })

    # -------------------------------- #
    # Richesse specifique - SDM
    # -------------------------------- #

    #### Map selection
    observeEvent(input$predictors, {
        if (input$rs_predictors == "noPredictors") {
            updateRadioGroupButtons(session, "rs_spatial", choices = "Spatial")
        } else {
            updateRadioGroupButtons(session, "rs_spatial", choices = c("Spatial", "noSpatial"))
        }
    })
    # eBird
    # path_RS_ebird <- reactive({
    #     paste0(input$species_select, "_range.tif")
    # })

    # Vincent - INLA
    output$rs_INLA <- renderPlot({
        map <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/RICH_SPE_INLA_RS_2017.tif")

        plot(map,
            axes = F,
            mar = NA,
            # range = c(0, 1),
            main = paste0("cumul = ", sum(values(map), na.rm = T))
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
    })

    # Maxent
    path_RS_Maxent <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/RICH_SPE_Maxent_", input$rs_predictors, "_", input$rs_bias, "_", input$rs_spatial, "_2017.tif")
    })
    output$rs_maxent <- renderPlot({
        map <- rast(path_RS_Maxent())

        plot(map,
            axes = F,
            mar = NA,
            # range = c(0, 1),
            main = paste0("cumul = ", sum(values(map), na.rm = T))
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
    })

    # MapSpecies
    path_RS_mapSpecies <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/RICH_SPE_ewlgcpSDM_", input$rs_predictors, "_", input$rs_bias, "_", input$rs_spatial, "_2017.tif")
    })
    output$rs_mapSPecies <- renderPlot({
        map <- rast(path_RS_mapSpecies())

        plot(map,
            axes = F,
            mar = NA,
            # range = c(0, 1),
            main = paste0("cumul = ", sum(values(map), na.rm = T))
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
    })
    # BRT
    path_RS_brt <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/RICH_SPE_brt_", input$rs_predictors, "_", input$rs_bias, "_", input$rs_spatial, "_2017.tif")
    })
    output$rs_brt <- renderPlot({
        map <- rast(path_RS_brt())

        plot(map,
            axes = F,
            mar = NA,
            # range = c(0, 1),
            main = paste0("cumul = ", sum(values(map), na.rm = T))
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
    })

    # Random Forest
    path_RS_randomForest <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/RICH_SPE_randomForest_", input$rs_predictors, "_", input$rs_bias, "_", input$rs_spatial, "_2017.tif")
    })
    output$rs_rf <- renderPlot({
        map <- rast(path_RS_randomForest())

        plot(map,
            axes = F,
            mar = NA,
            # range = c(0, 1),
            main = paste0("cumul = ", sum(values(map), na.rm = T))
        )
        plot(st_geometry(qc),
            add = T,
            border = "grey"
        )
        plot(st_geometry(lakes_qc),
            add = T,
            col = "white",
            border = "grey"
        )
    })

    # -------------------------------- #
    # Richesse specifique - obs brutes
    # -------------------------------- #
    year_rawObs <- reactive({
        input$yearInput_rawObs
    })

    # N01 level map
    output$n01Plot <- renderLeaflet({

    })
    # N02 level map
    # N03 level map
    # N04 level map
    # pix 10x10 km level map
}












# ================================================================================
# UI
# ================================================================================
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
                radioGroupButtons("model_output",
                    label = "Sortie des modèles",
                    choices = c("pocc", "range")
                ),
                radioGroupButtons("predictors",
                    label = "Prédicteurs environnementaux",
                    choices = c("Predictors", "noPredictors")
                ),
                radioGroupButtons("bias",
                    label = "Biais d'échantillonnage",
                    choices = c("Bias", "noBias")
                ),
                radioGroupButtons("spatial",
                    label = "Auto-corrélation spatiale",
                    choices = c("Spatial", "noSpatial")
                ),
                h4("Données"),
                checkboxInput("occs",
                    "Occurrences",
                    value = FALSE
                ),
                checkboxInput("pseudo_abs",
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
                        plotOutput("map_eBird")
                    ),
                    box(
                        title = "mapSpecies",
                        width = 4,
                        plotOutput("map_mapSpecies")
                    ),
                    box(
                        title = "Maxent",
                        width = 4,
                        plotOutput("map_Maxent")
                    )
                ),
                # Third row
                fluidRow(
                    box(
                        title = "INLA",
                        width = 4,
                        plotOutput("map_Vince")
                    ),
                    box(
                        title = "boosted regression tree",
                        width = 4,
                        plotOutput("map_BRT")
                    ),
                    box(
                        title = "random forest",
                        width = 4,
                        plotOutput("map_randomForest")
                    )
                )
            )
        )
    ),
    tabPanel(
        "Richesse spécifique - SDM",
        sidebarLayout(
            sidebarPanel(
                width = 2,
                radioGroupButtons("rs_predictors",
                    label = "Prédicteurs environnementaux",
                    choices = c("Predictors", "noPredictors")
                ),
                radioGroupButtons("rs_bias",
                    label = "Biais d'échantillonnage",
                    choices = c("Bias", "noBias")
                ),
                radioGroupButtons("rs_spatial",
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
                        plotOutput("rs_mapSPecies")
                    ),
                    box(
                        title = "Maxent",
                        width = 4,
                        status = "warning",
                        plotOutput("rs_maxent")
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
                        plotOutput("rs_brt")
                    ),
                    box(
                        title = "random forest",
                        width = 4,
                        status = "warning",
                        plotOutput("rs_rf")
                    )
                )
            )
        )
    ),
    tabPanel(
        "Richesse spécifique - Obs brutes",
        sidebarLayout(
            sidebarPanel(
                width = 2,
                selectInput(
                    inputId = "yearInput_rawObs",
                    label = "Année",
                    choices = 1990:2019
                )
            ),
            mainPanel(
                # First row
                fluidRow(
                    box(
                        title = "Provinces naturelles",
                        width = 4,
                        leafletOutput("n01Plot")
                    ),
                    box(
                        title = "Régions naturelles",
                        width = 4,
                        leafletOutput("n02Plot")
                    ),
                    box(
                        title = "Echelle physiographiques",
                        width = 4,
                        leafletOutput("n03Plot")
                    )
                ),
                # Third row
                fluidRow(
                    box(
                        title = "Districts écologiques",
                        width = 4,
                        leafletOutput("n04Plot")
                    ),
                    box(
                        title = "10 x 10 km",
                        width = 4,
                        leafletOutput("pix10_10Plot")
                    )
                )
            )
        )
    )
)

# ================================================================================
# Lancer l'application
# ================================================================================

shinyApp(ui = ui, server = server)
