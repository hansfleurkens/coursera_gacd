### Introduction

This is the result of the course project of the "Getting and Cleaning Data" course.

## Content

This repository contains:
* README.md - this file
* run_analysis.R - the R script that processes the raw dataset into a tidy dataset
* codebook.pdf - a description of the variables of the output table

It needs to be complemented with the actual dataset. The dataset for this analysis can be downloaded here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip



## Creating a tidy dataset from the raw dataset

run_analysis.R is a self-contained script that reads all tables, processes the data and generates a tidy
dataset called 'uci_har_dataset.txt' in the working directory. In order to run this R script,
the working directory needs to be set to the directory that contains all data files of this 
dataset: <path>/UCI HAR Dataset This directory is created after unpacking the ZIP file.

Note The files in both 'Inertial Signals' directories are not being used by this script.
In the script, we follow the steps as listed in the course assignment. We start with an initial step
that reads all the input tables.

## Step 1: Reading all the input tables and create one table

* features.txt: this file contains the names of the 561 variables of the dataset as observations.
  They match with the 561 column variables of the train and test dataset (X_*.txt).
* activity_labels.txt: this file contains the names of the 6 activities as observations
* In the train and test subdirectories:
  - subject_train.txt / subject_test.txt: the identifier of the subject (person). This table has matching
    rows in the 'Y' and 'X' files.
  - X_train.txt / X_test.txt: all observations across 561 measurements/variables.
  - Y_train.txt / Y_test.txt: the identifier of the activity of the observation. 
 
The train and test datasets will be merged into one big table that is then the basis for further processing
and analysis:
1) Bind the columns of the subject, Y, and X dataframes for each subset (train and test). For convenience, 
the column names of the subject and Y dataframes are set to "Subject" and "ActivityNumber".
2) Create one table by binding the rows of the two resulting datasets.
This is stored in the variable: all_data
See also the comments in the R script.

## Step 2: Restrict to mean and standard deviation measurements

I have chosen to focus on those measurements with mean() and std() in their name.
This will select 66 measurements and together with the subject and activity columns this will result in
a dataframe with 10299 observations across 68 variables.
1) Use grepl to create a logical vector that lists which measurements fulfill the rule above
2) Extend the vector for the subject and activity variables
3) Subset the dataframe using the logical vector to select only those columns that match the rule.
   The result is stored in selected_data, 10299 observations across 68 variables.

## Step 3: Replace activity identifier with a descriptive name

Activity names are already described in the file activity_labels.txt and read into the variable activity_labels.
These names are cleaned up to have capitalized words with spaces.
Merge is used to add the resulting descriptive names to the selected_data dataframe. The original ActivityNumber
column can be removed.

## Step 4: Use descriptive variable names
One could define each variable manually for ultimate descriptive names. For the purpose of this assignment
I have chosen to process the variable names with a number of steps to make them more descriptive. 
The codebook describes each variable in much detail. 

## Step 5: Create tidy dataset and write into file
The library 'reshape2' is used to create an average for each variable for each subject and activity.
There are multiple representations for such a tidy dataset. The script creates a "wide" format and a 
"narrow" format. I have chosen the use the narrow format to write to a file called "uci_har_dataset.txt"
that will be created in the working directory.

The narrow format is tidy as it has an observation across 
each combination of subject, activity and measurment variable and lists its average value;
the table has four columns: "Activity", "Subject", "Measurement", "AverageValue".
The variable tidy_data_narrow has 11880 observations across 4 variables which is correct as we have 66
type of measurements across 30 persons/subjects and 6 activities.

By changing the comments one could also opt to write the wide format. This is also a tidy dataset as it lists 
the averages of each measurment in its own column. The resulting table has 68 columns: "Activity", "Subject"
followed by the 66 measurement types. This table has 180 observations across 68 variables: that is 66 averages
per subject and activity.

