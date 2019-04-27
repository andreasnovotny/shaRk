# shaRk V 0.1.0
**A Tidyverse Approach to Swedish Marine Monitoring Data**


- Author: Andreas Novotny
- Contact: andreas.novotny@su.se
- source: https://github.com/andreasnovotny/shaRk

*Plankton Food Webs, Stockholm University 2019*

This package contains functions to easilly download and access datasets from SHARKdata.
SHARKdata is a database containing many years of environmental monitoring of the Baltic Sea. The database is hosted by SMHI (Swedish Institute for Metrology and Hydrology).

## Installation

This package can be installed directly from github. Install it with devtools:

```
install.packages("devtools")
devtools::install_github("andreasnovotny/shaRk")
```

## Usage

### Interactive data explorer

The interactive data explorer can after installation be opened by typing:
```
exploreSHARK(download=TRUE)
```
This function will first retrieve all available zooplankton and phytoplankton data from the SHARK database (OBS, this might be time consuming). Then it will open an interactive explorer in a new window, or in the web explorer.

To save time, the datasets are automaticaly saved into your shaRk package directory. Thus, next time you want to open the explorer, simply type:
```
exploreSHARK()
```
Each time you install a new version of the shaRk, or want to access an updated version of the SHARK database, include the "download=TRUE" argument.

### Key functions for retrieving data

1. Download SHARK data:
```
?getSHARK
```

2. Add taxonomic ranks from dyntaxa.se. This dataset comes with the package as a dataframe.
```
?addDyntaxa
```

3. Clean up datasets, and annotate columns:
```
?annotateSHARK
```

### Example

```
data(dyntaxa)

zoodata <- getSHARK("Zooplankton") %>% 
  addDyntaxa() %>%
  annotateSHARK()
```


## Dependencies

shaRk version 0.1 is built under R version 3.5.1.
It builds upon tidyverse, httr, jsonlite, shiny and flexdashboard. Package dependencies will be installed together with shaRk.

