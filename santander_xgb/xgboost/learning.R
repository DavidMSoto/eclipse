# TODO: Add comment
# 
# Author: davidmonteagudo
###############################################################################


#https://github.com/dmlc/xgboost/blob/master/R-package/vignettes/discoverYourData.Rmd


require(xgboost)
require(Matrix)
require(data.table)
if (!require('vcd')) install.packages('vcd')

data(Arthritis)
df <- data.table(Arthritis, keep.rownames = F)


head(df)


str(df)
