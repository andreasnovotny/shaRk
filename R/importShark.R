#' Downloads current monitoring data from SHARKdata
#'
#' This function downloads all current data at sharkdata.se by data type.
#'
#' @param Datatype (Required) A string representing the type of data to be downloaded. (Only "Zooplankton" and "Phytoplankton" tested).
#' @param possibly (Optional, default=TRUE) Logical. If TRUE: datasets that does not fit the format (cannot be read as TSV) will not be downloaded. If FALSE: the function will stop if an errournous dataset is encountered.
#' @return A dataframe.
#' @examples
#' data <- getSHARK("Phytoplankton")
#'
#' @export

getSHARK <- function(Datatype, possibly=TRUE) {

  require('jsonlite')
  require('httr')
  require('tidyverse')

  # Function for downloading each separate dataset from SHARKdata
  download <- function(name) {
    tsv <- paste('http://sharkdata.se/datasets/',name,'/data.txt',sep='') %>%  # Define the dataset name and ULR
      read_tsv(locale = locale(encoding = "windows-1252")) %>% # Download each dataseta, as tab separated tibble
      mutate_all(as.character) # Set datatype to character.
    return(tsv)
  } # End of "download" function

  if (possibly==TRUE) {  #### Get data, ignore malfunctioning datasets

    possibly_download <- possibly(download, "Malfunctioning_dataset")

    data <-fromJSON('http://sharkdata.se/datasets/list.json') %>% # Download metdata file overwiew from SHARK data
      filter(datatype %in% Datatype) %>% # Filter out the datasets of interest
      .$dataset_name %>% # Get list of dataset names
      map(possibly_download) # Download each dataaset from the list (apply function above)

    data_combined <- data[sapply(data, function(d)length(d)!=1)] %>%  #Remove errornous data
      bind_rows() # Combine all th datasets


  } else { #### possibly == FALSE: Stop if error in any dataset

    data_combined <-fromJSON('http://sharkdata.se/datasets/list.json') %>% # Download metdata file overwiew from SHARK data
      filter(datatype %in% Datatype) %>% # Filter out the datasets of interest
      .$dataset_name %>% # Get list of dataset names
      map(download) %>%  # Download each dataaset from the list (apply function above)
      bind_rows() # Combine all th datasets
  }
  return(data_combined)
} # End of getSHARK function



#' Add taxonomic ranks to datasets from dyntaxa.se
#'
#' @param data (Required) A string representing the type of data to be downloaded. (Only "Zooplankton" and "Phytoplankton" tested).
#' @param possibly (Optional, default=TRUE) Logical. If TRUE: datasets that does not fit the format (cannot be read as TSV) will not be downloaded. If FALSE: the function will stop if an errournous dataset is encountered.
#' @return A dataframe.
#' @examples
#'
#' data(dyntaxa)
#' data <- getSHARK("Phytoplankton") %>%
#' addDyntaxa(dyntaxa)
#'
#' @export

addDyntaxa <- function(data) {
  data(dyntaxa)

  require("dplyr")
  merged_data <- left_join(data, dyntaxa, by="dyntaxa_id")
  return(merged_data)
}





#' Annotate the downloaded dataset
#'
#' @param data (Required) The dataset.
#' @param possibly (Optional, default=TRUE) Logical. If TRUE: datasets that does not fit the format (cannot be read as TSV) will not be downloaded. If FALSE: the function will stop if an errournous dataset is encountered.
#' @return Annotated dataframe.
#' @examples
#' data(dyntaxa)
#' data <- getSHARK("Phytoplankton") %>%
#' addDyntaxa() %>%
#' annotateSHARK()
#'
#' @export

annotateSHARK <- function(data) {

  require("tidyverse")

  modified_data <- data %>%
    mutate(SDATE = as.Date(sample_date, format='%Y-%m-%d'),
           Yr_mon = format(as.Date(SDATE), '%Y-%m'),
           Month = as.numeric(format(as.Date(SDATE), "%m")),
           Year = format(as.Date(SDATE), "%Y"),
           Day = format(as.Date(SDATE), "%d"),
           Station = station_name,
           Parameter = parameter,
           Value = as.double(value),
           Depth = sample_max_depth_m) %>%
    as_tibble()

  return(modified_data)
}



