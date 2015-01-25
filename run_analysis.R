#
#  run_analysis.R
#
#  This script is written as a project work and has been submitted for 
#  the 1/2015 Coursera class 'Getting and Cleaning Data'. See the README.md
#  and CodeBook.md files for more information. 
#
#  The script closely follows the steps 1, .., 5 described in the project 
#  description. 
#  

#
#  Helper function to read a file 'fileName' with no header and with data 
#  separated with whitespaces.  
#
readFile <- function(filename) {
    cat('Loading', filename, '...\n')
    read.csv(filename, 
             sep = '', 
             header = FALSE)
}


#  --------------------------------------------------------------------------
#  Step 1: Merge the training and the test data to create one data set.
#
#  The output of Step 1 is stored in the data frame 'df.featuredata'.
#  --------------------------------------------------------------------------
#
#    Step 1a: read the 561 feature names from 'features.txt'.
#    Its format is
#
#      1  tBodyAcc-mean()-X
#      2  tBodyAcc-mean()-Y
#     ..  ...
#     ..  ...
#    560  angle(Y,gravityMean)
#    561  angle(Z,gravityMean)
# 
tmp <- readFile('features.txt')
tmp.features <- as.character(tmp$V2)  # vector of feature names

#   Create data frame 'df.features' of feature names
df.features <- data.frame(feature.nr = tmp$V1, 
                          name = tmp.features,
                          stringsAsFactors = FALSE)

#   It is useful to note that the feature names in 'features.txt' contain duplicates. 
#   This can be checked with the command:
#
#       print(tmp[duplicated(tmp.features), ])
#
#   Such duplicated features will not be used in the below script. 

#
#  Step 1b: Merge the test and training data for all subjects/activities.
#
#  The function 'read.data' below loads and combines the 561 feature, 
#  activity type, and subject data into one data frame. This function 
#  can be used to load both testing and learning data. 
#
#  Parameters:   
#    'featureFile'  
#        filename with file containing the recorded 561 features over 
#        time.
#
#    'activityFile' 
#       filename giving the activity for each line in the above file.
#       See the 'df.activities' data frame. Activities are labeled
#       1, ..., 6, see Step 3.
#
#    'subjectFile'
#       filename giving the activity for each line in 'featureFile'. 
#       Subjects are labeled with numbers 1, ..., 30.
#
#
read.data <- function(featuresFile, activityFile, subjectFile) {
    #   Read the recorded feature variables.
    featuresDF <- readFile(featuresFile)
    
    #
    #   Add an 'activity' column indicating the activity being observed 
    #   for each row.
    #
    activityDF <- readFile(activityFile)
    if(nrow(activityDF) != nrow(featuresDF)) {
        message("Error: Feature data and activity data have different number of rows!")
        stop()
    }
    featuresDF$activity <- activityDF$V1
    
    #
    #   Add a 'subject' column indicating which subject is observed for 
    #   each row. (subjects are labeled 1..30)
    #
    subjectDF <- readFile(subjectFile)
    if(nrow(subjectDF) != nrow(featuresDF)) {
        message("Error: Feature data and subject data have different number of rows!")
        stop()
    }   
    featuresDF$subject <- subjectDF$V1
    
    return(featuresDF)
}

# read test and training datasets
testFeatures <- read.data("test/X_test.txt", 
                          "test/y_test.txt", 
                          "test/subject_test.txt")  
trainFeatures <- read.data("train/X_train.txt", 
                           "train/y_train.txt", 
                           "train/subject_train.txt") 
# merge the two  
df.featuredata <- rbind(testFeatures, trainFeatures)
message(paste0('', nrow(df.featuredata), ' rows, and ', 
               ncol(df.featuredata), ' columns loaded.'))


#  --------------------------------------------------------------------------
#  Step 2: Extract only the measurements on the mean and standard 
#          deviation for each measurement.
#
#  The output is stored in the data frame 'df.selected.features'.
#  --------------------------------------------------------------------------
#
#  The below code finds a subset of 'df.features' that contain the sought
#  features. See CodeBook.md. The result is stored in the data frame 
#  'df.selected.features'.
#
#  First find all features that contain 'mean' or 'std', but do not include 
#  features that contain 'meanFreq' (the 'meanFreq' features are weighted means. 
#  See 'features_info.txt'.) Also exclude magnitude variables.
tmp <- df.features[(grepl("mean", df.features$name, ignore.case = TRUE)
                    |  grepl("std", df.features$name, ignore.case = TRUE))
                   & !grepl("meanFreq", df.features$name)
                   & !grepl("Mag-", df.features$name), ]

#  Only include features starting with 't' (time). This will exclude:
#    -  features that start with 'f' (frequency-domain features), and 
#    -  features starting with 'angle' (geometric angles).
tmp <- tmp[substring(tmp$name, 1,1) == 't', ]

#  Sort feature names alphabetically and store the result 
#  in 'df.selected.features'.
df.selected.features <- tmp[with(tmp, order(tmp$name)), ]

#  (Cosmetics) Remove the 'row.names' column in the selected features data 
#  frame. This is identical with the 'feature.nr' column already present.
rownames(df.selected.features) <- NULL 

#  --------------------------------------------------------------------------
#   Step 3:  Introduce descriptive activity names to name the activities 
#            in the data set.
#  --------------------------------------------------------------------------
activity.names <- data.frame(nr = 1:6, 
                             description = c('Walking', 
                                             'Walking.upstairs', 
                                             'Walking.downstairs', 
                                             'Sitting', 
                                             'Standing', 
                                             'Laying'))

#  Use the factor command to treat the numbers 1, ..., 6 in 'df.featuredata' 
#  as encoding the above strings 'Walking', ..., 'Laying'. 
df.featuredata$activity <- factor(df.featuredata$activity, 
                                  levels = activity.names$nr, 
                                  labels = activity.names$description)


#  --------------------------------------------------------------------------
#    Step 4: Appropriately label the data set with descriptive variable 
#            names. 
#
#    Output is stored in the data frame 'df.new'.
#  --------------------------------------------------------------------------
#
#  The feature names in 'df.selected.features' are not valid column names
#  in R. For example, these contain '-' characters. Next, rename these
#  names into valid column names (for R) that are also descriptive. 
#
#  This renaming is done with the following 'rewrite' function. It 
#  renames the selected feature variable names into valid 'R' column names. 
#
#  For example, 
#     rewrite('tBodyAccJerk-mean()-Z') = 'BodyAccJerk.Zmean'
#
rewrite <- function(input) {
    t <- substring(input, 2, nchar(input)) # drop leading 't'
    
    t <- gsub('mean()-X', 'Xmean', t, fixed=TRUE)
    t <- gsub('mean()-Y', 'Ymean', t, fixed=TRUE)
    t <- gsub('mean()-Z', 'Zmean', t, fixed=TRUE)
    
    t <- gsub('std()-X', 'Xstd', t, fixed=TRUE)
    t <- gsub('std()-Y', 'Ystd', t, fixed=TRUE)
    t <- gsub('std()-Z', 'Zstd', t, fixed=TRUE)
    
    t <- gsub('-', '.', t, fixed=TRUE)
    
    t
}

#
#  At this point, the feature columns in 'df.featuredata' are still 
#  labeled 'V1', 'V2', ..., 'V561'. The next function translates 
#  a feature number into its name in the original dataset.
#  For example:
#    feature.name(1) = 'tBodyAcc-mean()-X'
#    ...
#    feature.name(561) = 'angle(Z,gravityMean)'
#  
feature.name <- function(n) {
    df.features[df.features$feature.nr == n, ]$name
}

#
#   The next function is a convenience function for checking
#   if a feature number has been selected. For example, 
#
#       feature.nr.is.selected(1) = TRUE
#       feature.nr.is.selected(561) = FALSE
#
feature.nr.is.selected <- function(n) {
    # select those rows from 'df.selected.features' where the
    # 'feature.nr' column matches 'n'. 
    res <- df.selected.features[df.selected.features$feature.nr == n, ]    
    
    # Return TRUE if one 'n' is the number of a selected feature. Otherwise
    # return FALSE.
    return (nrow(res) == 1)
}

#   Create new data frame for containing the same data as 'df.featuredata',
#   but only with the selected feature variables. The data frame is 
#   initialized with columns 'subject' and 'activity'. 
df.new = data.frame(activity = df.featuredata$activity, 
                    subject = df.featuredata$subject)

#   Copy the 30 selected features columnwise into descriptive columns named 
#   by 'rewrite'. 
for (i in 1:nrow(df.features)) {
    if (feature.nr.is.selected(i)) {
        df.new[rewrite(feature.name(i))] <- df.featuredata[paste0('V', i)]
    }    
}

#  --------------------------------------------------------------------------
#   Step 5:  From the data set in step 4, creates a second, independent 
#   tidy data set with the average of each variable for each activity and 
#   each subject.
#
#   Output of Step 5 stored in data frame 'df.tidy'.
#  --------------------------------------------------------------------------

# start with empty data frame and build the data frame row by row. 
df.tidy <- data.frame()

# loop over all subject 1, ..., 30:
for(s in 1:30) {
    # Get the selected features for all activities for subject 's'.
    tmp.s <- df.new[df.new$subject == s, ]  
    # loop over the possible activities 'Walking', ..., 'Laying':
    for(a in activity.names$description) {
        tmp.sa <- tmp.s[tmp.s$activity == a, ]
        df.newrow <- data.frame(subject = c(s), 
                                activity = c(a))
        # Loop over all selected features
        for (original.name in df.selected.features$name) {
            # Translate each feature name (from its name in the original
            # data set) into the the name used here. This is done 
            # with the 'rewrite' function.
            f.name <- rewrite(original.name)
            
            # store new row in the tidy data frame. 
            df.newrow[f.name] <- c(mean(tmp.sa[ , f.name]))
        }
        df.tidy <- rbind(df.tidy, df.newrow)
    }
}

message('Done.')

# The file 'submit.txt' submitted on the Coursera web page
# was created using the command
#
#   write.table(df.tidy, file="../submit.txt", row.names=FALSE)
#
# Conversely, this file can be loaded with the command:
#
#   df <- read.table(file="../submit.txt", header=TRUE)
#
# The R-command View(df.tidy) can also be used to inspect the output.
#