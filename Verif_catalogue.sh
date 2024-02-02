#!/bin/bash

names="bonasa_umbellus catharus_bicknelli catharus_fuscescens catharus_guttatus catharus_ustulatus falcipennis_canadensis junco_hyemalis melospiza_georgiana melospiza_lincolnii melospiza_melodia poecile_atricapillus poecile_hudsonicus setophaga_americana setophaga_caerulescens setophaga_castanea setophaga_cerulea setophaga_coronata setophaga_fusca setophaga_magnolia setophaga_palmarum setophaga_pensylvanica setophaga_petechia setophaga_pinus setophaga_ruticilla setophaga_striata setophaga_tigrina setophaga_virens"
models="Maxent brt ewlgcpSDM randomForest"
hom_dir='s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_'
for name in $names
do
    for model in $models
    do
        echo ${name}_${model}
        echo "$name"_"$model" >> output.txt
        s5cmd du -H --group ${hom_dir}${name}_${model}* | awk '{print substr($0,16,5)}' >> output.txt # print les 5 caracteres qui suivent le 16eme de la sortie de la commande s5cmd
    done
done
