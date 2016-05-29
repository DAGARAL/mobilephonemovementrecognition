
# Set the environment variables
library(reshape2)
library(dplyr)
setwd("C:/Users/leche/Desktop/Bioinformatica/Getting and cleaning data/R session")
filename <- "getdata_dataset.zip"

## Download the file locally
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Get the desired labels from the data
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Select the mean and the standard deviation. Discard the rest
myfeatures <- grep(".*mean.*|.*std.*", features[,2])
myfeatures.names <- features[myfeatures,2]
myfeatures.names = gsub('-mean', 'Mean', myfeatures.names)
myfeatures.names = gsub('-std', 'Std', myfeatures.names)
myfeatures.names <- gsub('[-()]', '', myfeatures.names)

# Carga de datos and bind them
train <- read.table("UCI HAR Dataset/train/X_train.txt")[myfeatures]
Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(Subjects, Activities, train)
test <- read.table("UCI HAR Dataset/test/X_test.txt")[myfeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# unify data and add the labels
myData <- rbind(train, test)
colnames(myData) <- c("subject", "activity", myfeatures.names)

# turn activities and subjects into levels
myData$activity <- factor(myData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
myData$subject <- as.factor(myData$subject)

#Melt the dataframes
combinedFinal <- melt(myData, id = c("subject", "activity"))
myData.mean <- dcast(combinedFinal, subject + activity ~ variable, mean)

# Write the results to tidy
write.table(myData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

