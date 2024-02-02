#!/bin/bash

names="bonasa_umbellus catharus_bicknelli catharus_fuscescens catharus_guttatus catharus_ustulatus falcipennis_canadensis junco_hyemalis melospiza_georgiana melospiza_lincolnii melospiza_melodia poecile_atricapillus poecile_hudsonicus setophaga_americana setophaga_caerulescens setophaga_castanea setophaga_cerulea setophaga_coronata setophaga_fusca setophaga_magnolia setophaga_palmarum setophaga_pensylvanica setophaga_petechia setophaga_pinus setophaga_ruticilla setophaga_striata setophaga_tigrina setophaga_virens"
models="Maxent brt ewlgcpSDM randomForest"
hom_dir='s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_'
for name in $names
do
    for model in $models
    do
        echo "$name"_"$model"
        exi=s5cmd du -H --group ${hom_dir}${name}_${model}*
	echo $exi
    done
done

# Normalement, 24 cartes par espèces
# melospiza_melodia
# 1028950 bytes in 15 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_melospiza_melodia* [STANDARD]
# poecile_atricapillus
# 804967 bytes in 12 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_poecile_atricapillus* [STANDARD]
# poecile_hudsonicus
# 949324 bytes in 13 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_poecile_hudsonicus* [STANDARD]
# setophaga_americana
# 815740 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_americana* [STANDARD]
# setophaga_caerulescens
# 813150 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_caerulescens* [STANDARD]
# setophaga_castanea
# 810181 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_castanea* [STANDARD]
# setophaga_cerulea
# 863472 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_cerulea* [STANDARD]
# setophaga_coronata
# 786635 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_coronata* [STANDARD]
# setophaga_fusca
# 869962 bytes in 12 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_fusca* [STANDARD]
# setophaga_magnolia
# 863189 bytes in 12 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_magnolia* [STANDARD]
# setophaga_palmarum
# 818841 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_palmarum* [STANDARD]
# setophaga_pensylvanica
# 807321 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_pensylvanica* [STANDARD]
# setophaga_petechia
# 789713 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_petechia* [STANDARD]
# setophaga_pinus
# 826540 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_pinus* [STANDARD]
# setophaga_ruticilla
# 797590 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_ruticilla* [STANDARD]
# setophaga_striata
# 801346 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_striata* [STANDARD]
# setophaga_tigrina
# 808231 bytes in 11 objects: s3://bq-io/acer/TdeB_benchmark_SDM/TdB_bench_maps/maps/CROPPED_QC_setophaga_tigrina* [STANDARD]
