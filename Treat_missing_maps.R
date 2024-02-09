library(sf)
library(terra)

qc_fus <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_Unique_poly.gpkg")
map_ref <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/zonotrichia_leucophrys_range_1992.tif")

# Liste des cartes manquantes BRT

new_map <- list.files("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/sdm_maps_Fran",
    pattern = ".tif",
    full.names = TRUE
)
new_map_short <- list.files("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/sdm_maps_Fran",
    pattern = ".tif",
    full.names = FALSE
)

for (i in 1:length(new_map)) {
    print(new_map_short[i])
    miss <- rast(new_map[i])
    if (st_crs(miss) != st_crs(map_ref)) {
        n_map <- project(miss, map_ref)

        map_crop <- terra::crop(n_map, qc_fus)
        map_mask <- mask(map_crop, qc_fus)
        writeRaster(map_mask,
            paste0("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/ACER_missing_maps/maps_conv_crop/CROPPED_QC_", new_map_short[i]),
            overwrite = T
        )
    }
}
