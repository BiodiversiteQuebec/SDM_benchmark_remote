library(terra)
library(raster)
library(sf)

pocc <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/setophaga_magnolia_pocc_2017.tif")
occ <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/setophaga_magnolia_occ_2017.tif")
range <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/setophaga_magnolia_range_2017.tif")


qc <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_Unique_poly.gpkg")
pts <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/setophaga_magnolia.gpkg")

# Croppage de tout à l'échelle du QC - **** ici juste pour l'exercice
pocc2 <- raster::crop(pocc, qc)
pocc3 <- mask(pocc2, qc)

pts2 <- st_intersection(pts, qc)

plot(pocc3)
plot(st_geometry(pts2), add = T)

pts_seuil <- round(nrow(pts2) * 0.99)

pts_number <- 0
for (i in rev(seq(0, 1, by = 0.01))) {
    print(i)
    newR <- pocc3
    newR[values(newR) < i] <- NA

    pts_ext <- extract(newR, vect(pts2))
    pts_ext <- pts_ext[!is.na(pts_ext[, 2]), ]
    pts_number <- dim(pts_ext)[1]

    if (pts_number > pts_seuil) {
        plot(newR)
        newR[!is.na(values(newR))] <- 1
        plot(newR)
        print(paste0("proba seuil de ", i, " pour une nombre d'obs de ", pts_number))
        break
    }
}
