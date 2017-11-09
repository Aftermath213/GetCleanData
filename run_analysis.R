if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/raw.zip")
unzip("./data/raw.zip") 

activLabel <- read.table("UCI HAR Dataset/activity_labels.txt")
featName <- read.table("UCI HAR Dataset/features.txt")

#Load training data
subjTrain <- read.table("UCI HAR Dataset/train/subject_train.txt") 
activTrain <- read.table("UCI HAR Dataset/train/y_train.txt")
featTrain <- read.table("UCI HAR Dataset/train/X_train.txt")

#Load test data
subjTest <- read.table("UCI HAR Dataset/test/subject_test.txt") 
activTest <- read.table("UCI HAR Dataset/test/y_test.txt")
featTest <- read.table("UCI HAR Dataset/test/X_test.txt")

#Combine training and test data
subject <- rbind(subjTrain, subjTest)
activity <- rbind(activTrain, activTest)
features <- rbind(featTrain, featTest)

#Label the columns of the merged data frames
colnames(features) <- t(featName[2])
colnames(activity) <- "activity"
colnames(subject) <- "subject"

#Bind the columns of the finished data frames
data <- cbind(features, activity, subject)

#Get just the columns with mean / std
extract <- grep(".*Mean.*|.*Std.*", names(data), ignore.case=T)

#Add col #s for activity + subject
extractCols <- c(extract, 562, 563)

#Filter it down
finData <- data[,extractCols]

#Activities names
activLabel[,2] <- as.character(activLabel[,2])
finData$activity <- factor(finData$activity, levels=activLabel[,1], labels=activLabel[,2])

names(finData)

#Create descriptive names for variables
names(finData) <- gsub("-mean()", "Mean", names(finData), ignore.case=T)
names(finData) <- gsub("-std()", "StdDev", names(finData), ignore.case=T)
names(finData) <- gsub("^t", "Time", names(finData))
names(finData) <- gsub("^f", "Frequency", names(finData))
names(finData) <- gsub("-", "", names(finData))
names(finData) <- gsub("BodyBody", "Body", names(finData))
names(finData) <- gsub("Freq", "Frequency", names(finData))

#Create tidy data set with means
library(reshape2)
melted <- melt(finData, id=c("activity", "subject"))
tidyMean <- dcast(melted, activity + subject ~ variable, mean)
write.table(tidyMean, "tidy.txt", row.names=F)

getwd()
