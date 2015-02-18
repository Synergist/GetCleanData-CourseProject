## Course Project Code Book

### Data Source
The data used for this project was downloaded on Feb 11, 2015 from the following source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

### Data Set Information
A full description of the data is available at the [UCI Machine Learning Repository - Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) website. Here is an excerpt of the data set information:

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.
    
The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

For each record in the dataset it is provided:
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope.
- A 561-feature vector with time and frequency domain variables.
- Its activity label.
- An identifier of the subject who carried out the experiment. 


### Data Processing Details
The `run_analysis.R` script performs the following actions:

1. Merges the training and the test sets to create one data set.
    - The `readDataFiles()` function in the script is responsible for reading all the data into R:
        - The training and testing data files are located in the 'UCI HAR Dataset/train' and 'UCI HAR Dataset/test' directories, respectively. The files X_train.txt, X_test.txt, y_train.txt, y_test.txt, subject_train.txt,  and subject_test.txt are read using the data.table package's `fread` command.
        - The auxillary activity.txt and features.txt data files located in the 'UCI HAR Dataset' directory are also read using `fread` and saved for later use. These tables contain the information needed to map the activitiy IDs and features IDs to the corresponding descriptive names, respectively.  
    - The `mergeData()` function in the script merges the 6 training/testing tables created by `readDataFiles()` into a single table: 
        - The training/testing sets of subject IDs (subject_tran/test.txt) and activity labels (y_train/test.txt) are merged, respectively, using the `rbind` command to create two 10299x1 tables. Similarly, the training and testing sets of feature data (X_train/test.txt) are merged using `rbind` into a 10299x561 table. 
        - These 3 merged tables are then merged using `cbind` to create a table saved as `mdat` consisting of 10299 observations of 563 variables, where the first column is the Subject ID, the second column is the activity label, and the last 561 columns are the corresponding feature variables.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
    - The `extractFeatures()` function in the script trims the merged data to only include necessary measurements:
        - It first uses `grepl` to select only the measurements with 'mean()' or 'std()' in their name.
        - It then sets all other columns of `mdat` to NULL, effectively trimming the 10299x563 table into a 10299x63 table.
        - Finally, it converts the column names of these measurements into camelcase and removes any dashes in their names.
3. Uses descriptive activity names to name the activities in the data set.
    - The `useActivityDesc()` function in the script accomplishes this by:
        - Simplifying the activity names from the auxillary activity data table by converting them to camelcase and removing any dashes in their names.
        - And then replacing the activity IDs in `mdat` with the corresponding simplified activity names.
4. Appropriately labels the data set with descriptive variable names.
    - This has already been accomplished by the `extractFeatures()` function in Step 2.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    - A `tidydat` data.table is created by grouping `mdat` by subject and activity using dplyr's `group_by` command, and subsequently taking the mean of the remaining variables using dplyr's `summarise_each` command.
    - Finally, this tidy data set is saved using `write.table` to a file tidyData.txt in the repository's base directory.