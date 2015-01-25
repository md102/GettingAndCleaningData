#README

This repository contains a project submitted for the January 2015 Coursera class [Getting and Cleaning Data](https://www.coursera.org/course/getdata). The project works with a dataset of acceleration and gyroscope measurements for 30 subjects during six common activities. The purpose of the project is to create a summary of this data set. For more information, see the CodeBook. 

Files in this repository:

###CodeBook.md
The codebook describing how the original data is transformed and the meaning of all the variables in the output data set. 

###run_analysis.R
This R script automatically transforms the data into the sought tidy form. Before running this script, it is necessary to

1. Download the original dataset (see CodeBook).
2. In R, set the current working directory to the location of unzipped dataset:

~~~
   setwd('/Users/<<user name>>/MOOC/2015-1-Getting Cleaning Data/project/UCI HAR Dataset/')
~~~

After the script has run, the summary of the dataset is contained in the data frame *df.tidy*.

###README.md
This file.

## Notes
* The script has not been optimized for speed/memory usage. However, on a modern laptop, the run_analysis script runs less than a minute.

26.1.2015