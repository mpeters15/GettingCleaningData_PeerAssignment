library(dplyr)

filename <- "Coursera_DS3_Final.zip"

# Check if archive already exists
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method="curl")
}  

# Check if folder exists
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# Assign each data set to variables
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

# Merge the training and the test sets to create one data set.
Subject <- rbind(subject_train, subject_test)
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Merged_Data <- cbind(Subject, Y, X)

# Extract only the measurements on the mean and standard deviation for each measurement.
DataofInterest <- Merged_Data %>% select(subject, code, contains("mean"), contains("std"))

activities[DataofInterest$code, 2]

# Label the data set with descriptive variable names.
names(DataofInterest)[2] = "activity"
names(DataofInterest)<-gsub("Acc", "Accelerometer", names(DataofInterest))
names(DataofInterest)<-gsub("Gyro", "Gyroscope", names(DataofInterest))
names(DataofInterest)<-gsub("BodyBody", "Body", names(DataofInterest))
names(DataofInterest)<-gsub("Mag", "Magnitude", names(DataofInterest))
names(DataofInterest)<-gsub("^t", "Time", names(DataofInterest))
names(DataofInterest)<-gsub("^f", "Frequency", names(DataofInterest))
names(DataofInterest)<-gsub("tBody", "TimeBody", names(DataofInterest))
names(DataofInterest)<-gsub("-mean()", "Mean", names(DataofInterest), ignore.case = TRUE)
names(DataofInterest)<-gsub("-std()", "STD", names(DataofInterest), ignore.case = TRUE)
names(DataofInterest)<-gsub("-freq()", "Frequency", names(DataofInterest), ignore.case = TRUE)
names(DataofInterest)<-gsub("angle", "Angle", names(DataofInterest))
names(DataofInterest)<-gsub("gravity", "Gravity", names(DataofInterest))

# Create a second, independent tidy data set with the average of each variable for each activity and each subject
FinalData <- DataofInterest %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))
write.table(FinalData, "FinalData.txt", row.name=FALSE)
