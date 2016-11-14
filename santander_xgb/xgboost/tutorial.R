# TODO: Add comment 
# 
# Author: davidmonteagudo
###############################################################################

#http://datascienceplus.com/eclipse-an-alternative-to-rstudio-part-2/

#http://xgboost.readthedocs.io/en/latest/R-package/xgboostPresentation.html#

#https://www.analyticsvidhya.com/blog/2016/01/xgboost-algorithm-easy-steps/xgboost

#XGBoost only works with numeric vectors

#A simple method to convert categorical variable into numeric vector is One Hot Encoding



rm(list = ls())

library(data.table)
library(ggplot2)
library(xgboost)
library(Matrix)


#Seems like they want us to predict 6/2016 products, excluding those purchased in 5/2016


WIN <- TRUE
if (WIN) {setwd("c:/repos/eclipse/santander_xgb/santander/code/")}



suppressWarnings(train <- fread('../input/train_ver2.csv', nrows = 1000000))
train[, response := FALSE] # incluimos columna submision
output_vector = train[,response] == "Responder"

sparse_matrix <- sparse.model.matrix(response ~ .-1, data = train)



suppressWarnings(test <- fread('../input/test_ver2.csv', nrows = 10000))
test[, response := TRUE]   # incluimos columna submision


df_all = rbind(train,test, fill = TRUE)
