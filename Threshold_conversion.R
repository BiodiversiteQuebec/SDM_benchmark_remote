library(terra)
library(raster)
library(sf)
library(stringr)

pocc <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/setophaga_magnolia_pocc_2017.tif")
occ <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/setophaga_magnolia_occ_2017.tif")
range <- rast("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/setophaga_magnolia_range_2017.tif")

qc <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_Unique_poly.gpkg")
qc2 <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_CR_NIV_01.gpkg")

qc3 <- vect("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/QUEBEC_Vectors_details.gpkg")

pts <- st_read("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/setophaga_magnolia.gpkg")

# Croppage de tout à l'échelle du QC - **** ici juste pour l'exercice
# pocc2 <- raster::crop(pocc, qc)
# pocc3 <- mask(pocc2, qc)

# pts2 <- st_intersection(pts, qc)

# plot(pocc3)
# plot(st_geometry(pts2), add = T)

# pts_seuil <- round(nrow(pts2) * 0.99)

# pts_number <- 0
# for (i in rev(seq(0, 1, by = 0.01))) {
#     print(i)
#     newR <- pocc3
#     newR[values(newR) < i] <- NA

#     pts_ext <- extract(newR, vect(pts2))
#     pts_ext <- pts_ext[!is.na(pts_ext[, 2]), ]
#     pts_number <- dim(pts_ext)[1]

#     if (pts_number > pts_seuil) {
#         plot(newR)
#         newR[!is.na(values(newR))] <- 1
#         plot(newR)
#         print(paste0("proba seuil de ", i, " pour une nombre d'obs de ", pts_number))
#         break
#     }
# }

#### Vincent maps ####
# ----------------- #

# or similar & really faster method
spe <- stringr::str_remove(list.files("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/Bellavance_occurrences/sf_converted_occ_pres_only"), pattern = ".gpkg")

for (i in spe) {
    pts <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/", i, ".gpkg"))
    pts_crop <- st_intersection(pts, st_as_sf(qc3))

    # for (j in 1992:2017) {
    for (j in 2017:2017) {
        print(paste0("step - ", i, " - ", j))
        path <- paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/oiseaux-nicheurs-qc/", i, "_pocc_", j, ".tif")
        url <- str_remove(path, "/vsicurl/")

        if (RCurl::url.exists(url)) {
            pocc <- rast(path)
            pocc2 <- raster::crop(pocc, qc3)
            pocc3 <- mask(pocc2, qc3)

            pts_year <- pts_crop[pts_crop$year_obs >= j - 2 & pts_crop$year_obs <= j + 2, ]

            val_extr <- extract(pocc3, vect(pts_year))
            val <- val_extr[, 2]
            val <- val[!is.na(val)]

            sort_val <- sort(val_extr[, 2], decreasing = T)
            thresh <- sort_val[round(length(val) * 0.99)]
            newPocc <- pocc3
            newPocc[values(newPocc) >= thresh] <- 1
            newPocc[values(newPocc) < thresh] <- 0


            writeRaster(newPocc, paste0("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/SDM_threshold_test/THRESH_99_INLA_", i, "-", j, ".tif"),
                overwrite = T
            )
        } else {
            print(paste0("----------> ", i, "_pocc_", j, ".tif doesn't exist."))
        }
    }
}


# maps of Fran & I #
# --------------- #

# !/bin/bash
# s5cmd ls 's3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED*' >> /home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/SDM_benchmark_remote/list_SDM_bench.txt

sdm <- readLines("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/SDM_benchmark_remote/list_SDM_bench.txt")

treat <- lapply(sdm, function(x) {
    mod <- paste0("CROPPED_QC_", sub(".*CROPPED_QC_", "", x))
    spl <- unlist(str_split(mod, "_"))
    spe <- paste(spl[3], spl[4], sep = "_")

    final <- data.frame(spe = spe, mod = mod)
})
sdm2 <- do.call("rbind", treat)
head(sdm2)

# ----- #
sdm_ls <- split(sdm2, sdm2$spe)

lapply(sdm_ls, function(x) {
    spe <- unique(x$spe)
    print(paste0("----------> ", spe))
    pts <- st_read(paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/occurrences/", spe, ".gpkg"),
        query = paste0("SELECT * FROM ", spe, " WHERE year_obs >= 2015")
    )

    pts_crop <- st_intersection(pts, st_as_sf(qc3))

    # ----- #
    for (i in 1:length(x$mod)) {
        modele <- x$mod[i]
        print(modele)

        path <- paste0("/vsicurl/https://object-arbutus.cloud.computecanada.ca/bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/", modele)

        pocc <- rast(path)

        val_extr <- extract(pocc, vect(pts_crop))
        val <- val_extr[, 2]
        val <- val[!is.na(val)]

        sort_val <- sort(val, decreasing = T)
        thresh <- sort_val[round(length(val) * 0.99)]
        newPocc <- pocc
        newPocc[values(newPocc) >= thresh] <- 1
        newPocc[values(newPocc) < thresh] <- 0

        writeRaster(newPocc, paste0("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/SDM_threshold_test/THRESH_99_", modele),
            overwrite = T
        )
    }
})
