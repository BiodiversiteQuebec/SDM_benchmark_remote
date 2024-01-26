# Load packages
if (!exists("species")) {
    source("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/SDM_benchmark_remote/packages_n_local_data.R")
}
# App launch

source("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/SDM_benchmark_remote/app/app_ui.R")
source("/home/local/USHERBROOKE/juhc3201/BDQC-GEOBON/GITHUB/SDM_benchmark_remote/app/app_server.R")

shinyApp(ui, server)
