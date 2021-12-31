
library(dataReporter)
library(janitor)
library(labelled)
library(magrittr)
library(tidyverse)

## Download and extract the data set as necessary
if (!file.exists("getdata_projectfiles_UCI_HAR_DataSet.zip")) {
    ## Download the zipped data if it is not present
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "getdata_projectfiles_UCI_Dataset.zip")
}
if (!file.exists("UCI HAR Dataset/README.txt")) {
    ## unzip the data if that has not been done yet
    unzip("getdata_projectfiles_UCI_HAR_DataSet.zip")
}

## Define relative data file locations
activity_labels_file <- "UCI HAR Dataset/activity_labels.txt"
data_columns_file <- "UCI HAR Dataset/features.txt"
test_data_file <- "UCI HAR Dataset/test/X_test.txt"
test_activity_file <- "UCI HAR Dataset/test/y_test.txt"
test_subject_file <- "UCI HAR Dataset/test/subject_test.txt"
train_data_file <- "UCI HAR Dataset/train/X_train.txt"
train_activity_file <- "UCI HAR Dataset/train/y_train.txt"
train_subject_file <- "UCI HAR Dataset/train/subject_train.txt"

## Read the common descriptors, tidying as necessary
activity_labels <- read_table(activity_labels_file, col_names = c("level", "value"), col_types = c(col_integer(), col_character())) %>% 
    mutate(value = tolower(value))
data_columns <- read_table(data_columns_file, col_names = FALSE, col_types = c(col_integer(), col_character())) %>% 
    pull(X2) %>% make_clean_names()

## Read, tidy, and select columns from the training data set 
train_data <- read_table(train_data_file, col_names = data_columns, col_types = list(.default = col_double()))
## use descriptive activity names
train_activity <- read_table(train_activity_file, col_names = c("activity"), col_types = c(col_integer())) %>% 
    mutate(activity = factor(activity, levels = activity_labels$level, labels = activity_labels$value))
train_subject <- read_table(train_subject_file, col_names = c("subject"), col_types = c(col_integer())) %>% 
    mutate(subject = as.factor(subject))
## extract mean and standard deviation measurements (mean frequencies not included)
train_data %<>% select(matches("(_mean$)|(_mean_[xyz]$)|(_std)"))
train_data %<>% add_column(dataset = "train", train_subject, train_activity, .before = TRUE)

## Read, tidy, and select columns from the training testing data set 
test_data <- read_table(test_data_file, col_names = data_columns, col_types = list(.default = col_double()))
## use descriptive activity names
test_activity <- read_table(test_activity_file, col_names = c("activity"), col_types = c(col_integer())) %>% 
    mutate(activity = factor(activity, levels = activity_labels$level, labels = activity_labels$value))
test_subject <- read_table(test_subject_file, col_names = c("subject"), col_types = c(col_integer())) %>% 
    mutate(subject = as.factor(subject))
## extract mean and standard deviation measurements (mean frequencies not included)
test_data %<>% select(matches("(_mean$)|(_mean_[xyz]$)|(_std)"))
test_data %<>% add_column(dataset = "test", test_subject, test_activity, .before = TRUE)

## Merge the training and test data sets
full_data <- bind_rows(train_data, test_data)

## Create a new tidy data set with the average of each variable by activity and subject
summ_data <- full_data %>% group_by(subject, activity) %>% summarise_if(is.numeric, mean)

## Annotate variable labels
summ_cols <- summ_data %>% colnames()
summ_labels <- summ_cols %>% 
    gsub("body_body", "body", .) %>% 
    gsub("angle_([tf])_", "\\1_angle between the ", .) %>% 
    gsub("^t_", "Time domain ", .) %>% 
    gsub("^f_", "Frequency domain ", .) %>% 
    gsub("^angle_([xyz])_", "Angle \\(\\1\\) for the ", .) %>% 
    gsub("body_", "body-component ", .) %>% 
    gsub("gravity_", "gravity-component ", .) %>% 
    gsub("acc_", "accelerometer ", .) %>% 
    gsub("gyro_", "gyroscopic ", .) %>% 
    gsub("jerk_", "jerk ", .) %>% 
    gsub("mag_", "magnitude ", .) %>% 
    gsub("_([xyz])$", " \\(\\1\\)", .) %>% 
    gsub("mean_gravity", "mean and the gravity", .)
names(summ_labels) <- summ_cols
summ_data %<>% labelled::set_variable_labels(.labels = summ_labels)

## Write the tidied data set (albeit without labels) to file
summ_data %>% write.table("wearable_means.txt", row.name = FALSE)

## Generate the code book
makeCodebook(summ_data, reportTitle = "Codeboook for summary data calculated from the UCI HAR data set for the Coursera Course 'Getting and Cleaning Data'", file = "CodeBook.Rmd")

## Note: the code book Rmd file should be modified to have the following output and include the data manipulation section from the README
# output: 
#     md_document:
#     variant: markdown_github