# SDM_benchmark_remote

## Version 2

---

Une nouvelle série de modèles se basant sur les 17 espèces d'arbres étudiées par [Yan Boulanger](https://link.springer.com/article/10.1007/s10980-021-01241-7) et est comparée avec les cartes produites par Yan Boulanger (répartition de la biomasse par espèce).

| espèces étudiées        | code espèce |
| ----------------------- | ----------- |
| "abies_balsamea"        | ABIE.BAL    |
| "acer_rubrum"           | ACER.RUB    |
| "acer_saccharum"        | ACER.SAH    |
| "betula_alleghaniensis" | BETU.ALL    |
| "betula_papyrifera"     | BETU.PAP    |
| "fagus_grandifolia"     | FAGU.GRA    |
| "larix_laricina"        | LARI.LAR    |
| "picea_glauca"          | PICE.GLA    |
| "picea_mariana"         | PICE.MAR    |
| "picea_rubens"          | PICE.RUB    |
| "pinus_banksiana"       | PINU.BAN    |
| "pinus_resinosa"        | PINU.RES    |
| "pinus_strobus"         | PINU.STR    |
| "populus_tremuloides"   | POPU.TRE    |
| "quercus_rubra"         | QUER.RUB    |
| "tsuga_canadensis"      | TSUG.CAN    |
| "thuja_occidentalis"    | THUJ.OCC    |

## Version 1

---

Production d'un tableau de bord pour la comparaison des sorties de SDMs produits avec 6 algorithmes différents: **INLA** (auto-corrélation spatiale), **MaxEnt**, **BRT**, **RT**, **mapSpecies**.  
Les modèles ont été développés et produits par les personnes suivantes:

- **INLA** : Vincent Bellavance (première version)
- **MaxEnt** : Claire-Cécile Juhasz
- **RT**, **BRT**, **mapSpecies** :François Rousseu

Pur chaque type d'algorithme, les modèles ont été produits avec 6 différentes combinaisons de paramétrages (excepté pour les modèles **INLA**) :

- Predictors - noBias - Spatial
- Predictors - noBias - noSpatial
- noPredictors - noBias - Spatial
- noPredictors - Bias - Spatial
- Predictors - Bias - Spatial
- Predictors - Bias - noSpatial

_Predictors_ correspond à l'inclusion de variables environnementales comme prédicteurs. _Bias_ correspond à l'utilisation d'un biais lors de la génération aléatoire des pseudo-absences (tirage dans toutes les occurrences du groupe taxonomique étudié). _Spatial_ correspond à l'intégration d'un effet d'auto-corrélation spatiale via la création de 3 rasters présentant, pour chaque pixel, la valeur en x (raster 1), y (raster 2) et x\*y (raster 3) du centre du pixel.

Une première version de ce tableau de bord a été produite pour 27 espèces appartenant à la liste des **oiseaux nicheurs du Québec** (cf ci-dessous) et se déploie en local (https://github.com/Sckende/BDQC_SDM_benchmark_initial). L'objectif de ce présent repo est de migrer le tableau de bord en remote.

| espèces étudiées         |
| ------------------------ |
| "bonasa_umbellus"        |
| "catharus_bicknelli"     |
| "catharus_fuscescens"    |
| "catharus_guttatus"      |
| "catharus_ustulatus"     |
| "falcipennis_canadensis" |
| "junco_hyemalis"         |
| "melospiza_georgiana"    |
| "melospiza_lincolnii"    |
| "melospiza_melodia"      |
| "poecile_atricapillus"   |
| "poecile_hudsonicus"     |
| "setophaga_americana"    |
| "setophaga_caerulescens" |
| "setophaga_castanea"     |
| "setophaga_cerulea"      |
| "setophaga_coronata"     |
| "setophaga_fusca"        |
| "setophaga_magnolia"     |
| "setophaga_palmarum"     |
| "setophaga_pensylvanica" |
| "setophaga_petechia"     |
| "setophaga_pinus"        |
| "setophaga_ruticilla"    |
| "setophaga_striata"      |
| "setophaga_tigrina"      |
| "setophaga_virens"       |
