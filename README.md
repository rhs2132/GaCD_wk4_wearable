
# Wearables project using the UCI HAR data set for the Coursera course 'Getting and Cleaning data'

As requested in the assignment, this repo contains the:
1) tidy generated data set (wearable_means.txt),
2) script for downloading, manipulating, and otherwise tidying the above data set (run_analysis.R),
3) code book describing the tidy data set (CodeBook.md)
4) readme (aka this file)

The raw data is stored in the UCI HAR Dataset directory. The code book was generated as an .Rmd file at the end of the run_analysis.R script and then manually edited in order to knit the included CodeBook.md. Descriptions of data manipulations are present in the code book (replicated below) as well as documentation in the run_analysis.R script. 

# Data manipulation summary
The data set was originally sourced from UCI HAR and tidied into the presented format. The training and test data sets were processed in parallel by associating activity names to levels as described in activity_labels.txt and cleaning up variable names (extended descriptions added to labels after merging) before identifying and extracting only variables for which the mean and standard deviations are present. The combined data set was then used to calculate the average of each variable (mean and standard deviation) for each activity and subject.