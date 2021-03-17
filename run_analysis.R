#1. get dataset from web

rawDataDir <- "./rawData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFilename <- "rawData.zip"
rawDataDFn <- paste(rawDataDir, "/", "rawData.zip", sep = "")
dataDir <- "./data"

if (!file.exists(rawDataDir)) {
  dir.create(rawDataDir)
  download.file(url = rawDataUrl, destfile = rawDataDFn)
}
if (!file.exists(dataDir)) {
  dir.create(dataDir)
  unzip(zipfile = rawDataDFn, exdir = dataDir)
}

x_train<-read.table("data/UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("data/UCI HAR Dataset/train/subject_train.txt")

x_test<-read.table("data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("data/UCI HAR Dataset/test/y_test.txt")
subject_test<-read.table("data/UCI HAR Dataset/test/subject_test.txt")

# merge {train, test} data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(subject_train, subject_test)

mean_data<-colMeans(x_data)
std_data<-apply(x_data, 2, sd)

a_label <- read.table(paste("data/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])

feature<-read.table("data/UCI HAR Dataset/features.txt")

selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)


#4. extract data by cols & using descriptive name
x_data <- x_data[selectedCols]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

allData$Activity <- factor(allData$Activity, levels = a_label[,1], labels = a_label[,2])
allData$Subject <- as.factor(allData$Subject)


#5. generate tidy data set
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

