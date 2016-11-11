# TODO: Add comment
# 
# Author: davidmonteagudo
###############################################################################



#https://github.com/ledell/useR-machine-learning-tutorial/blob/master/gradient-boosting-machines.Rmd
#
rm(list = ls())
# 
library(xgboost)
library(Matrix)
library(cvAUC)
install.packages("cvAUC")


# Load 2-class HIGGS dataset
setwd('~/dataScience/workspace/santander/code/xgboost')

system("ls")

train <- read.csv("higgs_train_10k.csv")
test <- read.csv("higgs_test_5k.csv")

# Set seed because we column-sample
set.seed(1)

y <- "response"
train.mx <- sparse.model.matrix(response ~ ., train)
test.mx <- sparse.model.matrix(response ~ ., test)
dtrain <- xgb.DMatrix(train.mx, label = train[,y])
dtest <- xgb.DMatrix(test.mx, label = test[,y])

train.gdbt <- xgb.train(params = list(objective = "binary:logistic",
				#num_class = 2,
				#eval_metric = "mlogloss",
				eta = 0.3,
				max_depth = 5,
				subsample = 1,
				colsample_bytree = 0.5), 
		data = dtrain, 
		nrounds = 70, 
		watchlist = list(train = dtrain, test = dtest))


#Generate predictions on test dataset
preds <- predict(train.gdbt, newdata = dtest)
labels <- test[,y]

# Compute AUC on the test set
cvAUC::AUC(predictions = preds, labels = labels)


#Advanced functionality of xgboost
#install.packages("Ckmeans.1d.dp")
library(Ckmeans.1d.dp)

# Compute feature importance matrix
names <- dimnames(data.matrix(train[,-1]))[[2]]
importance_matrix <- xgb.importance(names, model = train.gdbt)

# Plot feature importance
xgb.plot.importance(importance_matrix[1:10,])



