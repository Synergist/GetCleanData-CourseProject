#################################################################################
    ##  Getting and Cleaning Data - 011 | Coursera
    ##  Data Science Specialization - Johns Hopkins University

    ##  Assignment: Programming Assignment 2
    ##  Author: Pranav Singh
    ##  Date: May 02, 2015

    ##  This script does the following:
    ##      1. Merges the training and the test sets to create one data set.
    ##      2. Extracts only the measurements on the mean and standard deviation for each measurement.
    ##      3. Uses descriptive activity names to name the activities in the data set.
    ##      4. Appropriately labels the data set with descriptive variable names.
    ##      5. From the data set in step 4, creates a second, independent tidy data set with the
    ##          average of each variable for each activity and each subject.
#################################################################################

readDataFiles <- function(dataDir) {
    oldDir <- getwd()
    trainDir <- file.path(dataDir, "train")
    testDir <- file.path(dataDir, "test")

    # Init lists to store train/test data
    train <- list()
    test <- list()

    # Read the features/activities files
    setwd(dataDir)
    features <- fread("features.txt")
    activities <- fread("activity_labels.txt")
    setnames(features, names(features), c("featureID", "featureName"))
    setnames(activities, names(activities), c("activityID", "activityName"))

    # Read the train subject/activity/data files
    setwd(trainDir)
    train$subject <- fread("subject_train.txt")
    train$activity <- fread("y_train.txt")
    train$data <- data.table(read.table("X_train.txt"))

    # Read the test subject/activity/data files
    setwd(testDir)
    test$subject <- fread("subject_test.txt")
    test$activity <- fread("y_test.txt")
    test$data <- data.table(read.table("X_test.txt"))

    # Finished reading. Reset working directory. Return list of data.table's
    setwd(oldDir)

    list(activities = activities,
         features = features,
         train = train,
         test = test)
}

mergeData <- function(train, test) {
    msubj <- rbind(train$subject, test$subject)
    mact <- rbind(train$activity, test$activity)
    setnames(msubj, "V1", "subjectID")
    setnames(mact, "V1", "activityID")

    mdat <- rbind(train$data, test$data)
    mdat <- cbind(msubj, mact, mdat)
    setkey(mdat, subjectID, activityID)
    mdat
}

simplifyFeatName <- function(name) {
    n <- gsub("-mean\\(\\)", "Mean", name)
    n <- gsub("-std\\(\\)", "Std", n)
    gsub("\\-([XYZ])", "\\1", n)
}

simplifyActivityName <- function(name) {
    n <- tolower(name)
    gsub("_([a-z])", "\\U\\1", n, perl=TRUE)
}

extractFeatures <- function(mdat, features, regex) {
    features <- features[grepl(regex, featureName)]
    features$featureID <- paste0("V", features$featureID)
    selectCols <- c(key(mdat), features$featureID)
    mdat[, setdiff(names(mdat), selectCols) := NULL]
    setnames(mdat, features$featureID, sapply(features$featureName, simplifyFeatName))
}

useActivityDescs <- function(data, acts) {
    acts$activityName <- sapply(acts$activityName, simplifyActivityName)
    data[, activityID := factor(acts[activityID]$activityName)]
    setnames(data, "activityID", "activity")
    setkey(mdat, subjectID, activity)
}

# Require necessary packages
pckgs <- c("data.table", "dplyr")
lapply(pckgs, require, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)

# Download the data if necessary
if (!file.exists("UCI HAR Dataset")) {
    data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url = data_url, destfile = "dataset.zip", method="curl")
    unzip("dataset.zip")
}

# Read the data files
dataDir <- file.path(getwd(), "UCI HAR Dataset")
dat <- readDataFiles(dataDir)

# Merge the training and test sets
mdat <- mergeData(dat$train, dat$test)

# Extract only the mean and standard deviation
extractFeatures(mdat, dat$features, "(mean|std)\\(\\)")

# Use descriptive activity names
useActivityDescs(mdat, dat$activities)

# Create tidy dataset of variable averages grouped by subject and activity
tidydat <- mdat %>% group_by(subjectID, activity) %>% summarise_each(funs(mean))
write.table(x = tidydat, file = "tidyData.txt", row.name = FALSE)