# Getting and Cleaning Data
## Course Project
#### Author: Pranav Singh
#### Date: Feb 10, 2015

### Overview:

This purpose of this assignment is to demonstrate the ability "to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis." We consider the data collected from the accelerometers of Samsung Galaxy S smartphones. 

The data used for this project was downloaded on Feb 11, 2015 from the following source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

A full description of the data is available at the site from which it was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

### Steps for reproducible analysis:
1. Download the zipped data from the aforementioned data source into the repo's base directory.
2. Unzip this data. This should create a subdirectory `UCI HAR Dataset` in the repo's base directory.
3. Run `source("run_analysis.R"")` command in RStudio, with the working directory set to the repo's base directory.
4. The script will output a file `tidyData.txt` which contains the tidied data as per the goal of this project. If you would like to inspect this data in R, you can do so with `tidyData <- read.table("tidyData.txt")`.

### Description of data processing:
Please see `CodeBook.md` in this repository for a description of the variables, data, and transformations performed by the `run_analysis.R` script.