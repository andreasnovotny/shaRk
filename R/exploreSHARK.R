#' Launch interactive SHARK data explorer

#' @param download (Optional, default=FALSE) If TRUE, zooplankton and phytoplankton data will be retrieved from SHARKdata, and saved to shaRk R package directory. This only has to be done the first time the function is run for each version installation or update, or to get updated versions from SHARKdata.
#' @examples
#' exploreSHARK()
#'
#' exploreSHARK(TRUE)
#'
#' @export

exploreSHARK <- function(download=FALSE) {

  require(tidyverse)
  require(shaRk)

  appDir <- system.file(package="shaRk")
  if (appDir == "") {
    stop("Could not find application directory. Try re-installing shaRk.")
  }

  if (download==TRUE) {

    getSHARK("Phytoplankton") %>%
      saveRDS(file.path(appDir, "phyto.rds"))

    getSHARK("Zooplankton") %>%
      saveRDS(file.path(appDir, "zoo.rds"))
  }

  rmarkdown::run(file.path(appDir,"exploreSHARK.Rmd"))
}
