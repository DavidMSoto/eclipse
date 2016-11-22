# TODO: Add comment
# 
# Author: davidmonteagudo
###############################################################################

require(xgboost)
require(Matrix)
require(data.table)


WIN <- TRUE
if (WIN) {setwd("c:/repos/repo/santander/code/")} else
	setwd('~/git/santander_xgb/santander_xgb/santander/code/')


suppressWarnings(train <- fread('../input/train_ver2.csv', nrows = 1000000))
train[, submission := FALSE] # incluimos columna submision

head(train)


str(train)

#This is the one-hot encoding step.
sparse_matrix <- sparse.model.matrix(Improved~.-1, data = df)
head(sparse_matrix)
