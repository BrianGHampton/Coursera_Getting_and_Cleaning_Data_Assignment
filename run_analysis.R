library(dplyr)

# Check if archive exists:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

# Check if folder exists and unzip downloaded data:
zipFile <- "./getdata_projectfiles_UCI HAR Dataset.zip"
outDir <- getwd()
unzip(zipFile ,exdir=outDir)

# Establish file paths for the unzipped data:
unZipped = file.path("./UCI HAR Dataset")
unZ_test = file.path("./UCI HAR Dataset/test")
unZ_train = file.path("./UCI HAR Dataset/train")

# Identify/read the txt files from the unzipped file and name the desired variables:
features <- read.table(file.path(unZipped, "features.txt"), col.names = c("n","functions"))
activities <- read.table(file.path(unZipped, "activity_labels.txt"), col.names = c("code", "activity"))
subject_test <- read.table(file.path(unZ_test, "subject_test.txt"), col.names = "subject")
x_test <- read.table(file.path(unZ_test, "X_test.txt"), col.names = features$functions)
y_test <- read.table(file.path(unZ_test, "y_test.txt"), col.names = "code")
subject_train <- read.table(file.path(unZ_train, "subject_train.txt"), col.names = "subject")
x_train <- read.table(file.path(unZ_train, "X_train.txt"), col.names = features$functions)
y_train <- read.table(file.path(unZ_train, "y_train.txt"), col.names = "code")

# Merge the data into one data frame
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject, Y, X)

# Extract the mean and standard deviation for each measurement:
TidyData <- Merged_Data %>% select(subject, code, contains("mean"), contains("std"))

# Replace the numeric activity code with the character word description:
TidyData$code <- activities[TidyData$code, 2]

# Replace the variable labels with readable/understandable label names:
names(TidyData)[2] = "activity"
names(TidyData)<-gsub("Acc", "Acceleration", names(TidyData))
names(TidyData)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData)<-gsub("BodyBody", "Body", names(TidyData))
names(TidyData)<-gsub("Mag", "Magnitude", names(TidyData))
names(TidyData)<-gsub("^t", "Time", names(TidyData))
names(TidyData)<-gsub("^f", "Frequency", names(TidyData))
names(TidyData)<-gsub("tBody", "TimeBody", names(TidyData))
names(TidyData)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("angle", "Angular", names(TidyData))
names(TidyData)<-gsub("gravity", "Gravity", names(TidyData))

# Create text file of tidy data:
FinalTidyData <- TidyData %>%
        group_by(subject, activity) %>%
        summarise_all(funs(mean))
write.table(FinalTidyData, "TidyData.txt", row.name=FALSE)

