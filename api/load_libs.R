

## Define function that verifies required 
## packages and install them ==================================
ipak <- function(pkg) {
  
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

## Define required packages =================
required_packages <- c("httr","jsonlite", "tcltk", "caTools", "readxl")

## Call function ============================
ipak(required_packages)