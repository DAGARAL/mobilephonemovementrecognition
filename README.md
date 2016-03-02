# README: EXPLANATION OF THE CODE

# PROJECT
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# A) READING THE TRAINING DATA
# A.1) LOAD THE COMMON DATA
library(dplyr)
setwd("C:/Users/leche/Desktop/Bioinformatica/Getting and cleaning data/R session")
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt",sep=" ",header=FALSE)
features<-read.table("./UCI HAR Dataset/features.txt",sep=" ",header=FALSE)
# A.2) LOAD INTO R ALL THE TRAINING DATA
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
y_train_labels<-read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)
# A.3) LOAD INTO R ALL THE TEST DATA
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
y_test_labels<-read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
# A.4) MERGE THE DATASETS
# We create a X train total with the names of the features and the names of the subjects
X_train2<-X_train
colnames(X_train2)<-features[,2]
X_train3<-cbind(X_train2,y_train_labels)
head(X_train3)
# We add the names of the subjects to the X_test dataset
X_test2<-X_test
X_test3<-cbind(X_test2,y_test_labels)
# We add X_test to the end of X train
names(X_test3)<-names(X_train3)
X_total<-rbind(X_train3,X_test3)
# B) EXTRACT ONLY THE MEASUREMENTS ON THE MEAN AND STANDARD DEVIATION
# B.1) We use a grep to get the variable names that have "mean" or "std" in 
# the variable description
Xmeansandstd <- X_total[(grep(("mean|std"),colnames(X_total)))]

# C) NAME THE ACTIVITIES IN THE DATASET WITH THE DESCRIPTIVE NAMES
# C.1) We translate the vector that describes the activities from 1...6 to
# the actual words
Xmeansandstdwithact<-merge(X_total,by.x="V1",activity_labels,by.y="V1")
subject<-rbind(subject_train,subject_test)
Xmeansandstdwithactandsubj<-cbind(Xmeansandstdwithact,subject)

# D) LABEL THE DATASET WITH DESCRIPTIVE NAMES
# We need to replace V1 and V2 because they are not informative
rename(Xmeansandstdwithactandsubj, ACTIVITY=V2, SUBJECT=V1)
oldvarnames<-colnames(Xmeansandstdwithactandsubj)
oldvarnames[563]<-"ACTIVITY"
oldvarnames[564]<-"SUBJECT"
colnames(Xmeansandstdwithactandsubj)<-oldvarnames
# Finally, we simplify by extracting only the means and std as required
X_final <- Xmeansandstdwithactandsubj[(grep(("mean|std|ACTIVITY|SUBJECT"),colnames(Xmeansandstdwithactandsubj)))]
# E) From the data set in step 4, creates a second, independent tidy data 
# set with the average of each variable for each activity and each subject.
by1<-levels(as.factor(X_final$ACTIVITY))
by2<-levels(as.factor(X_final$SUBJECT))
library(reshape2)
melted<-melt(X_final, id=c("ACTIVITY","SUBJECT"), measure.vars=c("tBodyAcc-mean()-X","tBodyAcc-std()-X"))
actdata<-dcast(melted,~ACTIVITY,mean)
write.table(X_final,file="tidy_data.txt",row.name=FALSE)
