Sys.time()
if (!require("pacman")) install.packages("pacman")
pacman::p_load(knitr, tidyverse, data.table, lubridate, zoo, DescTools, lightgbm, tictoc, pryr, caret)
set.seed(1)               
options(scipen = 9999, warn = -1, digits= 4)


output_filename <- "lgb_45mm_sample.csv"
data_partition_num <- 0

total_rows <- 184903890  # from prior data exploratio

debug  <- FALSE # TRUE
#######################################################
testing_size <- 100000

total_rows <- 184903890  # from prior data exploratio
if (!debug) {
  train_rows <- 4500000 #40000000
  skip_rows_train <- train_rows * data_partition_num   # total_rows - train_rows
  test_rows <- -1L
} else {
  train_rows <- testing_size
  skip_rows_train <- 0
  test_rows <- testing_size
}
##############################

train_path <- "../input/train.csv"
test_path  <- "../input/test.csv"
mem_before <- mem_used()

#######################################################

train_col_names <- c("ip", "app", "device", "os", "channel", 
                     "click_time", "attributed_time", "is_attributed")

most_freq_hours_in_test_data <- c("4","5","9","10","13","14")
least_freq_hours_in_test_data <- c("6","11","15")

#######################################################


cat("Reading ", train_rows, "training data records, from row ", skip_rows_train, " to row ", (train_rows + skip_rows_train))
train <- fread(train_path, skip = skip_rows_train, nrows = train_rows, colClasses = list(numeric=1:5),
               showProgress = FALSE, col.names = train_col_names) %>% select(-c(attributed_time))           
invisible(gc())

#######################################################
cbind(before=mem_before, after=mem_used())
Sys.time()

#*****************************************************************
# A function for processing the train/test data

process <- function(df) {
    df <- df %>% mutate(wday = Weekday(click_time), 
                        hour = hour(click_time),
                        in_test_hh = ifelse(hour %in% most_freq_hours_in_test_data, 1,
                                            ifelse(hour %in% least_freq_hours_in_test_data, 3, 2))) %>%
        select(-c(click_time)) %>%
        add_count(ip, wday, in_test_hh) %>% rename("nip_day_test_hh" = n) %>%
        select(-c(in_test_hh)) %>%
        add_count(ip, wday, hour) %>% rename("n_ip" = n) %>%
        add_count(ip, wday, hour, os) %>% rename("n_ip_os" = n) %>% 
        add_count(ip, wday, hour, app) %>% rename("n_ip_app" = n) %>%
        add_count(ip, wday, hour, app, os) %>% rename("n_ip_app_os" = n) %>% 
        add_count(app, wday, hour) %>% rename("n_app" = n) %>%
        select(-c(wday)) %>% select(-c(ip)) 
    return(df)
}




cat("Processing the training data...\n")
mem_before <- mem_used()
head(train)
train[, UsrappCount:=.N, by=list(ip,app,device,os)]
train[, UsrappNewness:=1:.N, by=list(ip,app,device,os)]
train[, UsrCount:=.N, by=list(ip,device,os)]
train[, UsrNewness:=1:.N, by=list(ip,device,os)]

train <- process(train)
head(train)
invisible(gc())
cbind(before=mem_before, after=mem_used())



cat("The training set has", nrow(train), "rows and", ncol(train), "columns.\n")
cat("The column names of the train are: \n")
cat(colnames(train), "\n")
print("The size of the train is: ") 
print(object.size(train), units = "auto")

percent_attributed <- mean(train$is_attributed)
cat("The table of class unbalance ", (mean(train$is_attributed)), "%\n")
table(train$is_attributed)







print("Prepare data for modeling")
val_ratio <- .9
train.index <- createDataPartition(train$is_attributed, p = val_ratio, list = FALSE)

dtrain <- train[ train.index,]
valid  <- train[-train.index,]

rm(train)
invisible(gc())





mem_before <- mem_used()
categorical_features <- c("app", "device", "os", "channel", "hour")


cat("Creating the 'dtrain' for modeling...")
dtrain <- lgb.Dataset(data = as.matrix(dtrain[, colnames(dtrain) != "is_attributed"]), 
                      label = dtrain$is_attributed, categorical_feature = categorical_features)


cat("Creating the 'dvalid' for modeling...")
dvalid <- lgb.Dataset(data = as.matrix(valid[, colnames(valid) != "is_attributed"]), 
                      label = valid$is_attributed, categorical_feature = categorical_features)

#######################################################

rm(train, valid)
invisible(gc())
cbind(before=mem_before, after=mem_used())




Sys.time()
mem_before <- mem_used()

params <- list(objective = "binary", 
               metric = "auc", 
               learning_rate = 0.1,
               num_leaves = 7,
               max_depth = 4,
               min_child_samples = 100,
               max_bin = 100,
               subsample = 0.7, 
               subsample_freq = 1,
               colsample_bytree = 0.7,
               min_child_weight = 0,
               min_split_gain = 0,
               scale_pos_weight = 99.7)

model <- lgb.train(params, dtrain, valids = list(validation = dvalid), nthread = 4,
                   nrounds = 1500, verbose= 1, early_stopping_rounds = 50, eval_freq = 25)

#######################################################

rm(dtrain, dvalid)
invisible(gc())
cbind(before=mem_before, after=mem_used())
#######################################################

Sys.time()
cat("Validation AUC @ best iter: ", max(unlist(model$record_evals[["validation"]][["auc"]][["eval"]])), "\n\n")



mem_before = mem_used()
cat("Reading the test data: ", test_rows, " rows. \n")
test <- fread(test_path, nrows=test_rows, colClasses=list(numeric=2:6), showProgress = FALSE) 

#######################################################

cat("Setting up the submission file... \n")
sub <- data.table(click_id = test$click_id, is_attributed = NA) 
test$click_id <- NULL
invisible(gc())

#######################################################

cat("Processing the test data...\n")
test[, UsrappCount:=.N, by=list(ip,app,device,os)]
test[, UsrappNewness:=1:.N, by=list(ip,app,device,os)]
test[, UsrCount:=.N, by=list(ip,device,os)]
test[, UsrNewness:=1:.N, by=list(ip,device,os)]


test <-process(test)
invisible(gc())

cbind(before=mem_before, after=mem_used())

cat("The test set has", nrow(test), "rows and", ncol(test), "columns.\n")
cat("The column names of the test set are: \n")
cat(colnames(test), "\n")
print("The size of the test set is: ") 
print(object.size(test), units = "auto")

#######################################################



Sys.time()

preds <- predict(model, data = as.matrix(test[, colnames(test)], n = model$best_iter))
preds <- as.data.frame(preds)
sub$is_attributed <- preds

rm(test)
invisible(gc())

sub$is_attributed <- round(sub$is_attributed, 4)

#fwrite(sub, "lgb_submission.csv")
fwrite(sub,  output_filename)
head(sub, 10)
