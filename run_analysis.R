setwd("~/LearningR/GettingAndCleaningData/CourseProject")
library(data.table)
library(LaF)

# read the metadata
features <- read.table("UCI HAR Dataset/features.txt", sep = " ", col.names = c("ID", "name"), colClasses = c("integer", "character"))
features <- features[,'name']

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep = " ", col.names = c("ID", "name"), colClasses = c("integer", "character"))
activity_labels <- data.table(activity_labels)
setkey(activity_labels, ID)

# read training data into data.table
train <- laf_open_fwf("UCI HAR Dataset/train/X_train.txt", 
                      column_widths = rep(16, length(features)), 
                      column_types=rep("double", length(features)),
                      column_names = features)
train_x <- data.table(train[,])
setnames(train_x, features)
train_y <- read.table("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

# read test data into data.table
test <- laf_open_fwf("UCI HAR Dataset/test/X_test.txt", 
                      column_widths = rep(16, length(features)), 
                      column_types=rep("double", length(features)),
                      column_names = features, )
test_x <- data.table(test[,])
setnames(test_x, features)
test_y <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = c("Activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# merge training and test data
combined_x <- rbind(train_x, test_x)
combined_y <- data.table(rbind(train_y, test_y))
combined_subject <- data.table(rbind(subject_train, subject_test))

# extract "mean" and "std" feature columns 
mean_std_features_idx <- grep('mean\\()|std\\()', features)
output <- combined_x[, mean_std_features_idx, with=F]
# merge in Activity and Subject data
output <- output[, Activity := activity_labels[combined_y]$name]
output <- output[, Subject := combined_subject]

# write the tidy dataset from step 4 into a file
write.table(output, "UCI HAR Dataset cleaned.txt", row.names = F)

# create tidy dataset for step 5 
avg_per_activity_subject <- output[, lapply(.SD,mean), by=.(Activity, Subject)]
write.table(avg_per_activity_subject, "Avg_per_activity_subject.txt", row.names = F)







