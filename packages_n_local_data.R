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
