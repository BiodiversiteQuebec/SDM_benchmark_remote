# SDM_benchmark_remote

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

_Predictors_ correspond à l'inclusion de variables environnementales comme prédicteurs. _Bias_ correspond à l'utilisation d'un biais lors de la génération aléatoire des pseudo-absences (tirage uniquement dans les occurrences de l'espèce étudiée). _Spatial_ correspond à l'intégration d'un effet d'auto-corrélation spatiale.

Une première version de ce tableau de bord a été produite pour 27 espèces appartenant à la liste des oiseaux nicheurs du Québec (cf ci-dessous) et se déploie en local (https://github.com/Sckende/BDQC_SDM_benchmark_initial). L'objectif de ce présent repo est de migrer le tableau de bord en remote.

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
