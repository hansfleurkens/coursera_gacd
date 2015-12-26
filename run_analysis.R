# Course project Getting and Cleaning Data
# Author  : Hans Fleurkens

library(reshape2)

###############################################################################
# Step 1a. Read all tables into R
###############################################################################

feature_table <- read.table("./features.txt")
activity_labels <- read.table("./activity_labels.txt")

# Read tables in 'train' directory, ignore 'Inertial Signals' subdirectory
subject_train <- read.table("./train/subject_train.txt")
X_train <- read.table("./train/X_train.txt")
Y_train <- read.table("./train/Y_train.txt")

# Read tables in 'test' directory, ignore 'Inertial Signals' subdirectory
subject_test <- read.table("./test/subject_test.txt")
X_test <- read.table("./test/X_test.txt")
Y_test <- read.table("./test/Y_test.txt")

###############################################################################
# Step 1b. Create one large table
###############################################################################

# Bind subject and activity columns to measurements
# - for train data
colnames(subject_train) <- c("Subject")
colnames(Y_train) <- c("ActivityNumber")
train_data <- cbind (subject_train, Y_train, X_train)
# - for test data
colnames(subject_test) <- c("Subject")
colnames(Y_test) <- c("ActivityNumber")
test_data <- cbind (subject_test, Y_test, X_test)

# Merge test and train data into one table
all_data <- rbind(train_data, test_data)
# cleanup intermediate data
rm(train_data,test_data)

###############################################################################
# Step 2. Select the relevant measurements
###############################################################################

# Create a vector with the variable names
vars <- as.character(feature_table[,2])

# create logical vector with features that contain std() or mean()
selected_vars <- grepl('(mean|std)\\(\\)',vars)
varnames <- vars[grep('(mean|std)\\(\\)',vars)]

# Also select the subject and activity columns
selected_vars <- c("TRUE","TRUE",selected_vars)
selected_data <- all_data[,selected_vars==TRUE]

###############################################################################
# Step 3. Replace the activity numbers by descriptive names
###############################################################################

colnames(activity_labels) <- c("ActivityNumber","Activity")
activity_labels[,2] <- as.character(activity_labels[,2])
activity_labels[,2] <- gsub("_"," ",activity_labels[,2])
# Capitalize whole string
activity_labels[,2] <- gsub("(\\w)(\\w*)", "\\U\\1\\L\\2", 
                            activity_labels[,2], perl=TRUE)

# Now replace activity number with descriptive text
selected_data <- merge(activity_labels,selected_data)
# And remove the redundant activity number column
selected_data$ActivityNumber <- NULL

###############################################################################
# Step 4. Replace variable by descriptive names
###############################################################################

# Remove special characters and capitalize:
varnames <- gsub("-mean\\(\\)","Mean",varnames)
varnames <- gsub("-std\\(\\)","StdDev",varnames)
varnames <- gsub("-","", varnames)

# Change to actual measurement devices:
varnames <- gsub("Acc","Accelerometer", varnames)
varnames <- gsub("Gyr","Gyrometer", varnames)
colnames(selected_data)[3:ncol(selected_data)] <- varnames

###############################################################################
# Step 5. Create tidy dataset with average for each variable for each
# subject and activity
###############################################################################
melted <- melt(selected_data,id=1:2)
# The wide representation of the tidy dataset
tidy_data_wide <- dcast(melted,Activity + Subject ~ variable, mean)
# And the narrow tidy dataset
tidy_data_narrow <- melt(tidy_data_wide,id=1:2)
# Update column names
colnames(tidy_data_narrow)[3:4] <- c("Measurement","AverageValue")

# Write one of the formats
#write.table(tidy_data_wide,"./uci_har_dataset.txt", row.names=FALSE)
write.table(tidy_data_narrow,"./uci_har_dataset.txt", row.names=FALSE)



