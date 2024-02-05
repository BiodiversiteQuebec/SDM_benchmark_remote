#!/bin/bash

species="melospiza_melodia poecile_atricapillus poecile_hudsonicus setophaga_americana setophaga_caerulescens setophaga_castanea setophaga_cerulea setophaga_coronata setophaga_fusca setophaga_magnolia setophaga_palmarum setophaga_pensylvanica setophaga_petechia setophaga_pinus setophaga_ruticilla setophaga_striata setophaga_tigrina"
# 17 species

# move brt maps for missing maps from Fran folder to new one
# path_from="/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/sdm_maps_Fran/"

# for spe in $species
# do
#     cp ${path_from}${spe}_brt* /home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/ACER_missing_maps
# done

# recapitulatif
for spe in $species
do
    echo ${spe}_brt
    echo ${spe}_brt >> output2.txt
    ls -1 | wc -l /home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/data/ACER_missing_maps/${spe}_brt* >> output2.txt

done