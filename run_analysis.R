## load necessary packages
library(dplyr)

feature <- readLines("UCI HAR Dataset/features.txt", 561)
#feature <- read.table("./UCI HAR Dataset/features.txt", sep=" ")

# Read test data

## Read x
x_width <- rep(16, times =561)
x_test <- read.fwf("UCI HAR Dataset/test/X_test.txt", x_width, header = FALSE, buffersize = 10)
## Read y
y_test <- readLines("UCI HAR Dataset/test/y_test.txt")
## Read subjects
test_subjects <- readLines("UCI HAR Dataset/test/subject_test.txt")
    
# Read training data
# Read x
x_train <- read.fwf("UCI HAR Dataset/train/X_train.txt", x_width, header = FALSE, buffersize = 5)
# Read y
y_train <- readLines("UCI HAR Dataset/train/y_train.txt")
# Read subjects
train_subjects <- readLines("UCI HAR Dataset/train/subject_train.txt")
    
## put test data together
variables <- strsplit(feature, " ")
colnames(x_test) <- make.names(feature, unique = TRUE)
colnames(x_train) <- make.names(feature, unique = TRUE)
##v <- gsub("[0-9]+ ", "", feature)

# add subject and activity columns
x_test$labels <- y_test
x_test$subjects <- test_subjects

x_train$labels <- y_train
x_train$subjects <- train_subjects

# read activities column
activities <- read.table("UCI HAR Dataset/activity_labels.txt")

# Step 1: Merge test and train dataset
data <- rbind(x_test, x_train)

# Step 2:Extracts only the measurements on the mean and standard deviation for each measurement. (mean & std)
data <- select(data, contains("labels"), contains("subjects"), contains("std"), contains("mean"))

# Step3: Use descriptive activity names to name the activities in the data set
data <- merge(data, activities, by.x = "labels", by.y = "V1", all=TRUE)

# Step4: Appropriately labels the data set with descriptive variable names. 
# relabel the activity names
colnames(data) [89] <- "activities"

#remove numbers from variable names
colnames(data) <- gsub("X([0-9]){1,3}.", "", colnames(data))
colnames(data) <- gsub("\\.{1,3}", "_", colnames(data))
colnames(data) <- gsub("_$", "", colnames(data))
colnames(data) <- gsub("^_", "", colnames(data))
data <- select(data, -labels )


# Step5:From the data set in step 4, creates a second, independent tidy data set with the average
## of each variable for each activity and each subject. 
summarydata <- summarize_all(group_by(data, subjects, activities), mean)
