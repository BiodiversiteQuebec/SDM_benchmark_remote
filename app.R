# Load packages
if (!exists("species")) {
    source("packages_n_local_data.R")
}
# App launch

source("app_ui.R")
source("app_server.R")

shinyApp(ui, server)
