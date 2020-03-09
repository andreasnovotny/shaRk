#' Estimation of daily mean abundances from long term monitoring data
#'
#' Uses linear interpretation to calculate hypothetical abundances for all days during montoring perod.
#'
#' @param data (Required) A dataframe (of type Zooplankton or Phytoplankton?)
#' @param taxa (Optional, default=Genus") A character string refering to the taxa-specific column in the dataframe
#' @return Dataframe, with year summarized and daily abundances interpreted.
#' @examples
#' data <- getSHARK("Phytoplankton") %>%
#'    addDyntaxa() %>%
#'    annotateSHARK() %>%
#'
#'  filter(Station == "BY31 LANDSORTSDJ",
#'         Year > 2006,
#'         unit == 	"mm3/l",
#'         Phylum %in% c(
#'                       "Miozoa",
#'                       "Bacillariophyta",
#'                       "Ciliophora",
#'                       "Haptophyta",
#'                       "Chlorophyta",
#'                       "Cyanobacteria"
#'   )) %>%
#'
#'  group_by(SDATE, Phylum, Depth) %>%
#'  summarize(Value=sum(Value)) %>%
#'
#'  group_by(SDATE, Phylum) %>%
#'  summarize(Value=mean(Value)) %>%
#'
#'  dailyInterpretation(taxa="Phylum")
#'
#' @export


dailyInterpretation <- function(data, taxa="Genus") {

  require(tidyverse, xts, zoo)

  allDates <- seq.Date(                                           #Creating a sequence of days for dataset
    min(as.Date(data$SDATE)),
    max(as.Date(data$SDATE)),
    "day")


  daydata <- data %>%

    spread(key={{taxa}}, value=Value) %>%                         # Turn into "matrix" format
    replace(is.na(.), 0) %>%                                      # Replaceing Nas with 0 for actual samples

    full_join(x=data.frame(SDATE=allDates), y=.) %>%              # Adding the sequence of days to existing dataset
    arrange(SDATE) %>%                                            # Order acc to date
    mutate_if(is.numeric, funs(na.approx(.))) %>%                 # Linnear na approximation of all numeric variables in dataset

    gather(key = "Taxa", colnames(.)[-1], value = "Value") %>%    # Back to long format

    mutate(Abundance = as.numeric(as.character(Value)),           # Summarize days of each year
           DOY = as.numeric(strftime(SDATE, format = "%j")),
           Year = as.numeric(strftime(SDATE, format = "%Y"))) %>%
    group_by(DOY, Taxa) %>%
    summarize(Abundance = mean(Abundance))

  return(daydata)
}
