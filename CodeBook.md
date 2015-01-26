#The Project Codebook

#The raw data for the analysis

This project will work with the **Human Activity Recognition Using Smartphones Data Set**, see Reference 1. This data set contains smartphone accelerometer and gyroscope measurements of 30 volunteers who each performed six common activities. The data is publicly available from the UCI Machine learning repository (see Reference 1). Its license information is given in its README file that comes with the original data set. For this course project, there was also an alternative download link:

[https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

The input data for the present analysis was downloaded at Sun Jan 25 19:10:16 EET 2015 from this latter cloudfront.new location. The downloaded file had the following checksums:

~~~
 sha1 checksum:
     566456a9e02a23c2c0144674d9fa42a8b5390e71
 md5 checksum: 
     d29710c9530a31f303801b6bc34bd895
 file size:
     62556944 bytes
~~~

The analysis was done using R version 3.1.2 (2014-10-31).

#Task description

The data set is motion data, and has been collected with the help of 30 volunteers. Each volunteer performed six common activities (see below) while a smartphone measured accelerometer and gyroscope readings. In total, the data thus contains information about *6x30=180* activities. The measurements were performed using a waist-mounted Galaxy SII at a sampling rate of *50* Hz. Using a lowpass filter, the acceleration *X*, *Y*, *Z* readings were split into *3* low-frequency *gravity* signals, and *3* other signals representing *body accelerations*. Further details on the measurement setup and the filtering process can be found in Reference 2 and in the 'README' file provided in the original dataset.  

Thus, each of the 30 subjects perform all 6 activities, and during each of the 180 activities nine signals were sampled at *50* Hz:

-  *3* angular velocity measurements (with units: radians/s),
-  *3* low frequency signals representing the *X*, *Y*, *Z* components of gravity (units: standard g-units),
-  *3* signals representing body-acceleration (units: standard g-units).

This raw data (with the above choise of units) is included in the dataset. However, in this analysis, it is not needed. The focus is on a more processed, or courser, representation of the data that is also included in the original data set. In this representation, all signals are described in *2.56* s time intervals with *50*% overlap; the duration of each of the 180 activities are divided into such *2.56*s time intervals and for each interval, *561* features, or feature variables, are computed from the above *9* signals.

Already in the original data set, the *561* features have been normalized to the range [-1, 1], and are thus unit-free, see equation (13) in Ref. 3. 

The task in this project is to summarize those of the 561 feature variables that represent means and standard deviations, and collect the result as a tidy data set. This transformation from the original dataset into a summary is performed by the **run_analysis.R** script. The Coursera project page gave a rather precise outline on how to perform this analysis in terms of five steps. Both the subsections below, and the comments in the R-script follow these steps. 

###   Step 1: Merge the training and the test sets to create one data set

The original data was given as a collection of text files, with their structure explained in the accompanying **README** file. The measured data is divided into two parts: a training dataset and a testing dataset. The first step is to read in all the relevant files and combine this into one data frame in R. After this is done, one obtains a data frame with the following structure:


| Columns V1, .., V561 for the *561* features     | activity | subject |
| ------- | -------- | ----------------------------------------------------- |
| *561* features for the first *2.56s* time interval of subject 1 doing activity 1   | *1* | *1* |
| (features for next time interval, 50% overlap)    | *1* | *1* |
| .... | *1* | *1*|
| *561* features for the first *2.56s* time interval of subject 2 doing activity 1    |   *1*  |      *2* | 
| (features for next time interval, 50% overlap)  |     *1*  | *2*                                                   |
| .... | .. | ..|

***Table 1:*** Structure of the **df.featuredata** data frame.

Each row in this table describes the features of one volunteer doing one activity during a *2.56s* time interval. The *30* volunteers are labeled by numbers *1*, ..., *30* (the subject column). As in the original dataset, the activities are encoded numerically (the activity column): 

| Nr. | Activity |                                        
|------ | -------------------- |                                        
| *1* | Walking|
| *2* | Walking.upstairs |
| *3* | Walking.downstairs |
| *4* | Sitting |
| *5* | Standing |
| *6* | Laying|
***Table 2:*** Structure of the **df.activities** data frame.

It can be useful to observe that the number of rows in the **df.featuredata** data frame for a fixed activity and fixed subject depends on the duration of that specific activity.

###    Step 2: Selection of mean and standard deviation variables

The project description asks to extract the measurements on the mean and standard deviation for each measurement. Which part of the data is required is here somewhat unclear. During each activity, only 6 (unfiltered) signals were recorded (linear acceleration along the *x*,*y*,*z*-axes, and angular velocity around the *x*, *y*, *z*-axes). However, in the dataset, this data has been transformed into *561* signals, or features. All of these 561 features are, in other words, derived from the initial 6 measurements. 

One interpretation could be that we are asked to only extract the mean and standard deviation of the **measured acceleration** and **measured angular velocity** signals. This would yield *12=2x(3+3)* signals. Another possibility would be to extract all of the *561* features that represent a mean or standard deviation of some quantity. The latter would yield around *80* features. In this analysis, a compromise is made and the following *30* features are selected:

| Nr.| Feature name in original data set | New name | Description |
|----|-------------------|---------------|----|
| 1 | tBodyAcc-mean()-X | BodyAcc.Xmean | Mean of the body-acceleration along the X-axis  |
| 2 | tBodyAcc-mean()-Y | BodyAcc.Ymean | (same for the Y-axis)     |
| 3 | tBodyAcc-mean()-Z | BodyAcc.Zmean | (same for the Z-axis) |
| 4 | tBodyAcc-std()-X | BodyAcc.Xstd | Standard deviation of the body-acceleration along the X-axis |
| 5 | tBodyAcc-std()-Y | BodyAcc.Ystd | (same for the Y-axis) |
| 6 | tBodyAcc-std()-Z | BodyAcc.Zstd | (same for the Z-axis) |
| 7 | tBodyAccJerk-mean()-X | BodyAccJerk.Xmean | Mean of the time derivative of the body-acceleration along the X-component   |
| 8 | tBodyAccJerk-mean()-Y | BodyAccJerk.Ymean | (same for the Y-axis) |
| 9 | tBodyAccJerk-mean()-Z | BodyAccJerk.Zmean | (same for the Z-axis) |
| 10 | tBodyAccJerk-std()-X | BodyAccJerk.Xstd | Standard deviation of the time derivative of the body-acceleration along the X-component   |
| 11 | tBodyAccJerk-std()-Y | BodyAccJerk.Ystd | (same for the Y-axis) |
| 12 | tBodyAccJerk-std()-Z | BodyAccJerk.Zstd | (same for the Z-axis) |
| 13 | tBodyGyro-mean()-X | BodyGyro.Xmean | Mean of the angular velocity around X-axis |
| 14 | tBodyGyro-mean()-Y | BodyGyro.Ymean | (same for the Y-axis) |
| 15 | tBodyGyro-mean()-Z | BodyGyro.Zmean | (same for the Z-axis) |
| 16 | tBodyGyro-std()-X | BodyGyro.Xstd | Standard deviation of angular velocity around the X-axis |
| 17 | tBodyGyro-std()-Y | BodyGyro.Ystd | (same for the Y-axis) |
| 18 | tBodyGyro-std()-Z | BodyGyro.Zstd | (same for the Z-axis) |
| 19 | tBodyGyroJerk-mean()-X | BodyGyroJerk.Xmean | Mean of the time derivative of the angular velocity around the X-axis |
| 20 | tBodyGyroJerk-mean()-Y | BodyGyroJerk.Ymean | (same for the Y-axis) |
| 21 | tBodyGyroJerk-mean()-Z | BodyGyroJerk.Zmean | (same for the Z-axis) |
| 22 | tBodyGyroJerk-std()-X | BodyGyroJerk.Xstd | Standard deviation of the time derivative  of angular velocity around the X-axis |
| 23 | tBodyGyroJerk-std()-Y | BodyGyroJerk.Ystd | (same for the Y-axis) |
| 24 | tBodyGyroJerk-std()-Z | BodyGyroJerk.Zstd | (same for the Z-axis) |
| 25 | tGravityAcc-mean()-X | GravityAcc.Xmean | Mean of gravity's X-component |
| 26 | tGravityAcc-mean()-Y | GravityAcc.Ymean | (same for the Y-axis) |
| 27 | tGravityAcc-mean()-Z | GravityAcc.Zmean | (same for the Z-axis) |
| 28 | tGravityAcc-std()-X | GravityAcc.Xstd | Standard deviation of gravity's X-component  |
| 29 | tGravityAcc-std()-Y | GravityAcc.Ystd | (same for the Y-axis) |
| 30 | tGravityAcc-std()-Z | GravityAcc.Zstd | (same for the Z-axis) |
***Table 3:*** The selected feature variables with their description. The column **New name** is described in Step 4 below. 

The above table lists the names of these 30 variables with the naming convention used in the original data set. The last column also gives their description. For these descriptions, the separation of the linear accelerometer signal into a gravity and a body-acceleration signal was described above. All means and standard deviations represent means/standard deviations computed over  2.56s time intervals. Also, as explained in the above, all signals are normalized to the range [-1, 1] and have no unit. 

It should be noted that the original data set also include features computed from frequency domain information. These are excluded  with the motivation we are asked for features that represent **measurements**. For the case of frequency variables, these have been **computed** (using the fast Fourier transform) and are therefore not (or, at least not directly) measured. For the same reason, features involving angles between different vectors are excluded. Lastly, features like *fBodyAccMag-meanFreq()* are excluded as they represent **weighted means** in the frequency domain. Without further information (say, about the next step in the analysis), it can be a matter of interpretation which features to include and which to exclude. However, the script is rather modular, and it should be easy to change which features to include. 

###Step 3: Use descriptive names for activity

In the original data, the activity is encoded with a numerical value in the range *1*, ..., *6*. See Table 3 above. To make these descriptive, it is enough to treat them as representing a factor variable in R with the descriptions given by Table 3. 

###Step 4: Label the data set with descriptive variable names

Unfortunately, the names used in the original data set for the *561* features  are not valid column names in R. For example, from Table 3, it can be seen that these names included hyphens, which are forbidden in column names for R. Therefore, the selected features have been renamed as in Table 3, such that the new names are both descriptive and valid R column names.

In Step 4, the script creates a new data frame **df.new**, which contains the same information as the data frame **df.featuredata**, but where the *561-30=531* features that do not appear in Table 3 have been dropped. The column names are also renamed, so that features are labeled according to the *New name* column in Table 3. 

### Step 5: Summarize the data

In the last step we are asked to compute the mean of all the features selected in Step 2 for the 180 observed activities (of all 30 subjects performing the 6 activities). As a result we obtain a table of the following structure:

| subject | activity | BodyAcc.Xmean | ... | GravityAcc.Zstd |
| ---------| ---------| ---------| ---------| ---------|
|    1 | Walking | .. | ..|..|..|
|    1 | Walking.upstairs | .. | ..|..|..|
|    1 | Walking.downstairs | .. | ..|..|..|
|   .. | ..  | .. | ..|..|..|
|   .. | ..  | .. | ..|..|..|
|   .. | ..  | .. | ..|..|..|
|   30 | Sitting  | .. | ..|..|..|
|   30 | Standing  | .. | ..|..|..|
|   30 | Laying  | .. | ..|..|..|
***Table 4:*** Structure of the output data frame **df.tidy**.

This data frame contains *30x6=180* rows and *2+30=32* columns; two columns for subject and activity and *30* columns for the selected features in Table 3. 

After the script has run, the above data frame is contained in the **df.tidy** variable; the numerical values of the computed means are here omitted. 

In the output, the structure of **df.tidy** is such that each column represent a variable, and each row is associated with one observation. For example, the first row summarizes acceleration and gyroscope measurements obtained while subject 1 is walking.  In this form the data is presented in the so called *wide form*. 

##References

1. UCI Machine learning repository, [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#), 2012. **Note:** this webpage makes the following citation request for the data: D. Anguita, A. Ghio, L. Oneto, X. Parra and J.L. Reyes-Ortiz, *Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine*, International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain, Dec 2012. 

2. D. Anguita, A. Ghio, L. Oneto, X. Parra2 and J.L. Reyes-Ortiz,
*A Public Domain Dataset for Human Activity Recognition Using Smartphones*,
ESANN 2013 proceedings, European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning. Bruges (Belgium), 24-26 April 2013. [Online](https://www.elen.ucl.ac.be/Proceedings/esann/esannpdf/es2013-84.pdf). Downloaded 25.1.2015.

3. J.R. Cerqueira da Silva, *Smartphone Based Human Activity
Prediction*, 2013. [Online](http://repositorio-aberto.up.pt/bitstream/10216/67649/2/43638.pdf), Master's thesis, Faculdade de Engenharia da Universidade do Porto, 2013. Downloaded 25.1.2015.