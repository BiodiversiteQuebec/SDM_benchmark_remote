# ================================================================================
# Chargement packages & data
# ================================================================================

#### Packages ####
# -------------- #
library(shiny)
library(shinydashboard)
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

# ================================================================================
# server
# ================================================================================
server <- function(input, output, session) {
    #### Map selection
    observeEvent(input$predictors, {
        if (input$predictors == "noPredictors") {
            updateSelectInput(session, "spatial", choices = "Spatial")
        } else {
            updateSelectInput(session, "spatial", choices = c("Spatial", "noSpatial"))
        }
    })
    # eBird
    path_map_ebird <- reactive({
        paste0(input$species_select, "_range.tif")
    })

    # Vincent - INLA
    id_feat_Vince <- reactive({
        paste0(input$species_select, "_", input$inla_sortie, "_2017")
    })

    # Maxent
    path_map_Maxent <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_Maxent_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
    })

    # MapSpecies
    path_map_mapSpecies <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_ewlgcpSDM_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
    })

    # BRT
    path_map_brt <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_brt_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
    })

    # Random Forest
    path_map_randomForest <- reactive({
        paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_", input$species_select, "_randomForest_", input$predictors, "_", input$bias, "_", input$spatial, ".tif")
    })

    #### Map visualization
    # eBird
    output$map_eBird <- renderPlot({
        # if (input$species_select %in% c("aegolius_funereus", "asio_flammeus")) {
        #     mp <- terra::rast("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/local_data/eBird_maps/acanthis_flammea_range.tif")

        #     terra::plot(mp,
        #         col = "#edf5f5",
        #         axes = F,
        #         main = ""
        #     )
        #     plot(st_geometry(qc), axes = T, add = T)
        # } else {
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
        # feat <- stac("https://acer.biodiversite-quebec.ca/stac/") %>%
        #     collections("oiseaux-nicheurs-qc") %>%
        #     items(feature_id = id_feat_Vince()) %>%
        #     get_request()

        # tif_path <- feat$assets$data$href

        # go_cat <- rast(stars::read_stars(paste0("/vsicurl/", tif_path),
        #     proxy = TRUE
        # )) # stars object

        go_cat <- rast(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/", id_feat_Vince(), ".tif"))

        if (input$inla_sortie == "range") {
            terra::plot(go_cat,
                axes = F,
                main = "Occurrence",
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
        if (input$inla_occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))

            # occs2 <- st_intersection(occs, qc_fus)
            plot(occs, add = T, pch = 16, col = "black", cex = 0.5)
        }
    })

    # MapSPecies
    output$map_mapSpecies <- renderPlot({
        pred_crop <- rast(path_map_mapSpecies())

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = "Intensité"
            # main = strsplit(path_map_Maxent(), "/")[[1]][10]
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
    output$map_Maxent <- renderPlot({
        pred_crop <- rast(path_map_Maxent())

        # pred_crop <- terra::crop(predictions, qc_fus_Max)
        # pred_mask <- mask(pred_crop, qc_fus_Max)

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = "Probabilité de présence",
            range = c(0, 1)
            # main = strsplit(path_map_Maxent(), "/")[[1]][10]
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
        if (input$Maxent_occs == TRUE) {
            occs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/CROPPED_QC_", input$species_select, ".gpkg"))
            plot(occs, add = T, pch = 16, col = "black", cex = 0.5)
        }
        if (input$Maxent_pseudo_abs == TRUE) {
            if (input$bias == "noBias") {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_region_Maxent_noBias.gpkg"))
                plot(pabs, add = T, pch = 16, col = "red", cex = 0.5)
            } else if (input$predictors == "noPredictors") {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_", input$species_select, "_Maxent_noPredictors_Bias_Spatial.gpkg"))
                plot(pabs, add = T, pch = 16, col = "red", cex = 0.5)
            } else if (input$spatial == "Spatial") {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_", input$species_select, "_Maxent_Predictors_Bias_Spatial.gpkg"))
                plot(pabs, add = T, pch = 16, col = "red", cex = 0.5)
            } else {
                pabs <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/pseudo_abs/CROPPED_QC_pseudo-abs_", input$species_select, "_Maxent_Predictors_Bias_noSpatial.gpkg"))
                plot(pabs, add = T, pch = 16, col = "red", cex = 0.5)
            }
        }
    })

    # BRT
    output$map_BRT <- renderPlot({
        pred_crop <- rast(path_map_brt())

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = "Probabilité de présence",
            range = c(0, 1)
            # main = strsplit(path_map_Maxent(), "/")[[1]][10]
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
    output$map_randomForest <- renderPlot({
        pred_crop <- rast(path_map_randomForest())

        plot(pred_crop,
            axes = F,
            mar = NA,
            main = "Probabilité de présence",
            range = c(0, 1)
            # main = strsplit(path_map_Maxent(), "/")[[1]][10]
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

    # Richesse specifique INLA
    output$rs_INLA <- renderPlot({
        map <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/species_richness/INLA_range_2017.tif")

        plot(map,
            axes = F,
            mar = NA,
            # range = c(0, 1),
            main = "Richesse spécifique"
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

# ================================================================================
# Lancer l'application
# ================================================================================

shinyApp(ui = ui, server = server)
