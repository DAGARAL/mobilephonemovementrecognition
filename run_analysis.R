
library(dplyr)
setwd("C:/Users/leche/Desktop/Bioinformatica/Getting and cleaning data/R session")
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt",sep=" ",header=FALSE)
features<-read.table("./UCI HAR Dataset/features.txt",sep=" ",header=FALSE)

X_train<-read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
y_train_labels<-read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)

X_test<-read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
y_test_labels<-read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)

X_train2<-X_train
colnames(X_train2)<-features[,2]
X_train3<-cbind(X_train2,y_train_labels)
head(X_train3)

X_test2<-X_test
X_test3<-cbind(X_test2,y_test_labels)

names(X_test3)<-names(X_train3)
X_total<-rbind(X_train3,X_test3)

Xmeansandstd <- X_total[(grep(("mean|std"),colnames(X_total)))]

Xmeansandstdwithact<-merge(X_total,by.x="V1",activity_labels,by.y="V1")
subject<-rbind(subject_train,subject_test)
Xmeansandstdwithactandsubj<-cbind(Xmeansandstdwithact,subject)

rename(Xmeansandstdwithactandsubj, ACTIVITY=V2, SUBJECT=V1)
oldvarnames<-colnames(Xmeansandstdwithactandsubj)
oldvarnames[563]<-"ACTIVITY"
oldvarnames[564]<-"SUBJECT"
colnames(Xmeansandstdwithactandsubj)<-oldvarnames

X_final <- Xmeansandstdwithactandsubj[(grep(("mean|std|ACTIVITY|SUBJECT"),colnames(Xmeansandstdwithactandsubj)))]

by1<-levels(as.factor(X_final$ACTIVITY))
by2<-levels(as.factor(X_final$SUBJECT))
library(reshape2)
melted<-melt(X_final, id=c("ACTIVITY","SUBJECT"), measure.vars=c("tBodyAcc-mean()-X","tBodyAcc-std()-X"))
actdata<-dcast(melted,~ACTIVITY,mean)
write.table(X_final,file="tidy_data.txt",row.name=FALSE)
