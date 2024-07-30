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
library(RCurl) # for check if url exists - url.exists()

#### Local data ####
# ---------------- #

# Species data
# ------------
species_bird <- c(
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

species_tree <- c(
    "abies_balsamea",
    "acer_rubrum",
    "acer_saccharum",
    "betula_alleghaniensis",
    "betula_papyrifera",
    "fagus_grandifolia",
    "larix_laricina",
    "picea_glauca",
    "picea_mariana",
    "picea_rubens",
    "pinus_banksiana",
    "pinus_resinosa",
    "pinus_strobus",
    "populus_tremuloides",
    "quercus_rubra",
    "tsuga_canadensis",
    "thuja_occidentalis"
)
code_tree <- c(
    "ABIE.BAL",
    "ACER.RUB",
    "ACER.SAH",
    "BETU.ALL",
    "BETU.PAP",
    "FAGU.GRA",
    "LARI.LAR",
    "PICE.GLA",
    "PICE.MAR",
    "PICE.RUB",
    "PINU.BAN",
    "PINU.RES",
    "PINU.STR",
    "POPU.TRE",
    "QUER.RUB",
    "THUJ.SPP.ALL",
    "TSUG.CAN"
)
species_df <- data.frame(
    species = c(species_bird, species_tree),
    taxon = c(rep("oiseau", length(species_bird)), rep("arbre", length(species_tree))),
    code = c(rep("none", length(species_bird)), code_tree)
)

# Several Polygons for Qc
# -----------------------
qc <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_CR_NIV_01.gpkg")
qc_fus <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_Unique_poly.gpkg")


region <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/REGION_interet_sdm.gpkg")
lakes_qc <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/REGION_LAKES_QC_sdm.gpkg")

# Function for null map

blank_map <- function() {
    par(mar = rep(0, 4))
    plot(st_geometry(qc),
        border = "grey"
    )
    plot(st_geometry(lakes_qc),
        add = T,
        col = "white",
        border = "grey"
    )
}

# rs_n01 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N01_wkt_raw_obs.txt", sep = "\t", h = T) # impossible to load
# rs_n02 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N02_wkt_raw_obs.txt", sep = "\t", h = T)
# rs_n03 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N03_wkt_raw_obs.txt", sep = "\t", h = T)
# rs_n04 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_N04_wkt_raw_obs.txt", sep = "\t", h = T)
# rs_pix_10x10 <- read.table("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/raw_obs/QC_CUBE_Richesse_spe_10x10_wkt_raw_obs.txt", sep = "\t", h = T)

# ================================================================================
# server
# ================================================================================
server <- function(input, output, session) {
    #### Species selection
    output$species <- renderUI({
        selectInput("species_select",
            label = "",
            choices = species_df$species[species_df$taxon == input$taxon_select]
        )
    })
    #### Map selection
    observeEvent(input$predictors, {
        if (input$predictors == "noPredictors") {
            updateRadioGroupButtons(session, "spatial", choices = "Spatial")
        } else {
            updateRadioGroupButtons(session, "spatial", choices = c("Spatial", "noSpatial"))
        }
    })
    # Ref map
    path_map_ref <- reactive({
        if (input$taxon_select == "oiseau") {
            paste0(input$species_select, "_range.tif")
        } else {
            code <- species_df$code[species_df$species == input$species_select]
            paste0("baseline_BudwormBaselineFire_", code, "_0_merged.tif")
        }
    })

    # Vincent - INLA
    id_feat_Vince <- reactive({
        paste0(input$species_select, "_", input$model_output, "_2017")
    })

    # Maxent

    path_map_Maxent <- reactive({
        if (input$model_output == "pocc") {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_Maxent_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_Maxent_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    # MapSpecies
    path_map_mapSpecies <- reactive({
        if (input$model_output == "pocc") {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_ewlgcpSDM_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_ewlgcpSDM_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    # BRT
    path_map_brt <- reactive({
        if (input$model_output == "pocc") {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_brt_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_brt_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    # Random Forest
    path_map_randomForest <- reactive({
        if (input$model_output == "pocc") {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_randomForest_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        } else {
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/thresh_test/THRESH_99_CROPPED_QC_", input$species_select, "_randomForest_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
        }
    })

    #### Map visualization
    # Ref map
    output$map_ref <- renderPlot({
        path <- ifelse(input$taxon_select == "oiseau",
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/eBird_maps/", path_map_ref()),
            paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/io/forets-cc-landis/", path_map_ref())
        )

        par(mar = rep(0, 4))
        if (!url.exists(path)) {
            blank_map()
        } else {
            if (input$taxon_select == "oiseau") {
                mp <- terra::rast(paste0("/vsicurl/", path))
            } else {
                mp <- terra::rast(paste0("/vsicurl/", path))
            }

            terra::plot(mp,
                axes = F,
                main = ifelse(input$taxon_select == "oiseau", "Abondance", "Biomasse"),
                mar = NA
            )
            plot(st_geometry(qc), add = T, border = "grey")
            plot(st_geometry(lakes_qc),
                add = T,
                col = "white",
                border = "grey"
            )
        }
    })

    # Vincent
    output$map_Vince <- renderPlot({
        path <- paste0("https://object-arbutus.cloud.computecanada.ca/bq-io/acer/oiseaux-nicheurs-qc/", id_feat_Vince(), ".tif")
        par(mar = rep(0, 4))
        if (!url.exists(path)) {
            blank_map()
        } else {
            go_cat <- rast(paste0("/vsicurl/", path))

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
        }
    })

    # MapSPecies
    output$map_mapSpecies <- renderPlot({
        par(mar = rep(0, 4))
        if (!url.exists(path_map_mapSpecies())) {
            blank_map()
        } else {
            pred_crop <- rast(paste0("/vsicurl/", path_map_mapSpecies()))

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
        }
    })

    # Maxent
    output$map_Maxent <- renderPlot({
        par(mar = rep(0, 4))
        if (!url.exists(path_map_Maxent())) {
            blank_map()
        } else {
            pred_crop <- rast(paste0("/vsicurl/", path_map_Maxent()))

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
        }
    })

    # BRT
    output$map_BRT <- renderPlot({
        par(mar = rep(0, 4))
        if (!url.exists(path_map_brt())) {
            blank_map()
        } else {
            pred_crop <- rast(paste0("/vsicurl/", path_map_brt()))

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
        }
    })

    # Random Forest
    output$map_randomForest <- renderPlot({
        par(mar = rep(0, 4))
        if (!url.exists(path_map_randomForest())) {
            blank_map()
        } else {
            pred_crop <- rast(paste0("/vsicurl/", path_map_randomForest()))

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
        }
    })
}

# ================================================================================
# UI
# ================================================================================
ui <- navbarPage(
    "Exploration SDMs",
    # tabPanel(
    # "SDMs",
    sidebarLayout(
        sidebarPanel(
            width = 2,
            h4("Groupe taxonomique"),
            selectInput("taxon_select",
                label = "",
                choices = unique(species_df$taxon)
            ),
            h4("Espèce"),
            uiOutput("species",
                label = ""
            ), # associated to renderUI in server section
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
                    title = "carte de référence",
                    width = 4,
                    plotOutput("map_ref")
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
)

# ================================================================================
# Lancer l'application
# ================================================================================

shinyApp(ui = ui, server = server)
