

# notas -------------------------------------------------------------------


# git hub
# cd /c/repo/root
#git init
#git commit -am "v2"
#git push origin master
#git add *


#setwd("c:/repo/root/")
#https://github.com/wehrley/wehrley.github.io/blob/master/SOUPTONUTS.md
#http://lifehacker.com/5812578/the-coffee-lovers-guide-to-tea

#http://trevorstephens.com/kaggle-titanic-tutorial/getting-started-with-r/


rm(list = ls())


# read --------------------------------------------------------------------


readData <- function(path.name, file.name, column.types, missing.types) {
	read.csv( url( paste(path.name, file.name, sep="") ), 
			colClasses=column.types,
			na.strings=missing.types )
}


Titanic.path <- "https://raw.github.com/wehrley/Kaggle_Titanic/master/"
train.data.file <- "train.csv"
test.data.file <- "test.csv"
missing.types <- c("NA", "")
train.column.types <- c('integer',   # PassengerId
		'factor',    # Survived 
		'factor',    # Pclass
		'character', # Name
		'factor',    # Sex
		'numeric',   # Age
		'integer',   # SibSp
		'integer',   # Parch
		'character', # Ticket
		'numeric',   # Fare
		'character', # Cabin
		'factor'     # Embarked
)
test.column.types <- train.column.types[-2]     # # no Survived column in test.csv

train.raw <- readData(Titanic.path, train.data.file, 
		train.column.types, missing.types)
df.train <- train.raw

test.raw <- readData(Titanic.path, test.data.file, 
		test.column.types, missing.types)
df.infer <- test.raw 


# Data Munging feature enginering  ------------------------------------------------------------


###########AGE 
## function for extracting honorific (i.e. title) from the Name feature
head(df.train$Name, n=10L)
getTitle <- function(data) {
	title.dot.start <- regexpr("\\,[A-Z ]{1,20}\\.", data$Name, TRUE)
	title.comma.end <- title.dot.start + attr(title.dot.start, "match.length")-1
	data$Title <- substr(data$Name, title.dot.start+2, title.comma.end-1)
	return (data$Title)
}   

df.train$Title <- getTitle(df.train)
unique(df.train$Title)

options(digits=2)

library(Hmisc)

bystats(df.train$Age, df.train$Title,   fun=function(x)c(Mean=mean(x),Median=median(x)))


## list of titles with missing Age value(s) requiring imputation
titles.na.train <- c("Dr", "Master", "Mrs", "Miss", "Mr")

# hace la media separada por las categorias de los titulos nobiliarios
imputeMedian <- function(impute.var, filter.var, var.levels) {
	for (v in var.levels) {
		impute.var[ which( filter.var == v)] <- impute(impute.var[ 
						which( filter.var == v)])
	}
	return (impute.var)
}
#For example, the single record with a missing Age value and Title="Dr" will be assigned the median of the ages from the 6 records with Title="Dr" which do have age data.
df.train$Age[which(df.train$Title=="Dr")]
df.train$Age <- imputeMedian(df.train$Age, df.train$Title, titles.na.train)
df.train$Age[which(df.train$Title=="Dr")]
summary(df.train$Age)
#end of Age enginering feature, for now .. we have used a new variable (Tittle) to be able to do it. 


############Embarked / PORT two missings - a lo mejor esq habia 2 polizontes q sobrevivien ...
#it should be fine to replace those missings with "S", the most common value.

#que edades tienen los que se colaron ??

summary(df.train$Embarked)
df.train$Embarked[which(is.na(df.train$Embarked))] <- 'S'


############Fare / many of them are 0 
summary(df.train$Fare)

subset(df.train, Fare < 7)[order(subset(df.train, Fare < 7)$Fare, 
				subset(df.train, Fare < 7)$Pclass), 
		c("Age", "Title", "Pclass", "Fare")]

## impute missings on Fare feature with median fare by Pclass
df.train$Fare[ which( df.train$Fare == 0 )] <- NA
df.train$Fare <- imputeMedian(df.train$Fare, df.train$Pclass, 
		as.numeric(levels(df.train$Pclass)))


df.train$Title <- factor(df.train$Title,
		c("Capt","Col","Major","Sir","Lady","Rev", "Dr","Don","Jonkheer","the Countess","Mrs",
				"Ms","Mr","Mme","Mlle","Miss","Master"))


boxplot(df.train$Age ~ df.train$Title,     main="Passenger Age by Title", xlab="Title", ylab="Age")

############title
## function for assigning a new title value to old title(s) 

##ver los viejos titulos



changeTitles <- function(data, old.titles, new.title) {
	for (honorific in old.titles) {
		
		data$Title[ which( data$Title == honorific)] <- new.title
	}
	return (data$Title)
}

describe(df.train$Title )
summary(df.train$Title)
describe(df.train$Title)
## Title consolidation

#sapply(df.train$Title, class)

## cambiado Noble por Jonkheer
df.train$Title <- changeTitles(df.train, 
		c("Capt", "Col", "Don", "Dr", 
				"Jonkheer", "Lady", "Major", 
				"Rev", "Sir"),
		"Jonkheer")
##nueva pieza de codigo
df.train$Title[which(is.na(df.train$Title))] <- 'Jonkheer'



df.train$Title <- changeTitles(df.train, c("the Countess", "Ms"),            "Mrs")
df.train$Title <- changeTitles(df.train, c("Mlle", "Mme"), "Miss")
df.train$Title <- as.factor(df.train$Title)

require(plyr)     # for the revalue function 
require(stringr)  # for the str_sub function

## test a character as an EVEN single digit
isEven <- function(x) x %in% c("0","2","4","6","8") 
## test a character as an ODD single digit
isOdd <- function(x) x %in% c("1","3","5","7","9") 

## function to add features to training or test data frames
featureEngrg <- function(data) {
	
	head(data$PassengerId, n = 1L)
	
	## Using Fate ILO Survived because term is shorter and just sounds good
	data$Fate <- data$Survived
	## Revaluing Fate factor to ease assessment of confusion matrices later
	data$Fate <- revalue(data$Fate, c("1" = "Survived", "0" = "Perished"))
	## Boat.dibs attempts to capture the "women and children first"
	## policy in one feature.  Assuming all females plus males under 15
	## got "dibs' on access to a lifeboat
	data$Boat.dibs <- "No"
	data$Boat.dibs[which(data$Sex == "female" | data$Age < 15)] <- "Yes"
	data$Boat.dibs <- as.factor(data$Boat.dibs)
	## Family consolidates siblings and spouses (SibSp) plus
	## parents and children (Parch) into one feature
	data$Family <- data$SibSp + data$Parch
	## Fare.pp attempts to adjust group purchases by size of family
	data$Fare.pp <- data$Fare/(data$Family + 1)
	## Giving the traveling class feature a new look
	data$Class <- data$Pclass
	data$Class <- revalue(data$Class, 
			c("1"="First", "2"="Second", "3"="Third"))
	## First character in Cabin number represents the Deck 
	data$Deck <- substring(data$Cabin, 1, 1)
	data$Deck[ which( is.na(data$Deck ))] <- "UNK"
	data$Deck <- as.factor(data$Deck)
	## Odd-numbered cabins were reportedly on the port side of the ship
	## Even-numbered cabins assigned Side="starboard"
	data$cabin.last.digit <- str_sub(data$Cabin, -1)
	data$Side <- "UNK"
	data$Side[which(isEven(data$cabin.last.digit))] <- "port"
	data$Side[which(isOdd(data$cabin.last.digit))] <- "starboard"
	data$Side <- as.factor(data$Side)
	data$cabin.last.digit <- NULL
	return (data)
}

## add remaining features to training data frame
df.train <- featureEngrg(df.train)




train.keeps <- c("Fate", "Sex", "Boat.dibs", "Age", "Title", "Class", "Deck", "Side", "Fare", "Fare.pp", "Embarked", "Family")
df.train.munged <- df.train[train.keeps]

str(df.train.munged)
train.batch <- df.train.munged[training.rows, ]
test.batch <- df.train.munged[-training.rows, ]



















