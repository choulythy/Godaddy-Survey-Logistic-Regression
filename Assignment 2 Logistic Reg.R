library(rpart) #One of the packages that supports CART.
library(rpart.plot) #For nicer plotting of trees
library(gmodels) #For confusion matrix
library(readxl)
library(ggplot2)
library(dplyr)
library(janitor)
library(shiny)
library(shinythemes)

####################################################################################################################
#PART1: Import and clean data 
####################################################################################################################
knitr::opts_knit$set(root.dir = '~/Downloads/Field Project/Assignment 1') 
df3 <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Data")

#extract data
df <- df3[c("q2", "q5", "q5a", "q5b", "q5c", "q5d", "q6", "q9", "q11", "q12", "q13", "q14", "q25")]
rm(df3)
summary(df)
hist(df$q14)


#match data with value from sheet 2
values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B15:C19", col_names = c("q2", "q2_text"))
df=merge(df,values, by="q2", all.x=T)

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B24:C28", col_names = c("q5", "q5_text"))
df=merge(df,values, by="q5", all.x=T)

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B29:C33", col_names = c("q5a", "q5a_text"))
df=merge(df,values, by="q5a", all.x=T)
df <- df %>%
  mutate(q5a_text = ifelse(q5a == -8, "Prefer not to answer", q5a_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B34:C36", col_names = c("q5b", "q5b_text"))
df=merge(df,values, by="q5b", all.x=T)
df <- df %>%
  mutate(q5b_text = ifelse(q5b == -8, "Prefer not to answer", q5b_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B37:C50", col_names = c("q5c", "q5c_text"))
df=merge(df,values, by="q5c", all.x=T)
df <- df %>%
  mutate(q5c_text = ifelse(q5c == -8, "Prefer not to answer", q5c_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B51:C61", col_names = c("q5d", "q5d_text"))
df=merge(df,values, by="q5d", all.x=T)
df <- df %>%
  mutate(q5d_text = ifelse(q5d == -8, "Prefer not to answer", q5d_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B62:C66", col_names = c("q6", "q6_text"))
df=merge(df,values, by="q6", all.x=T)
df <- df %>%
  mutate(q6_text = ifelse(q6 == -8, "Prefer not to answer", q6_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B107:C111", col_names = c("q9", "q9_text"))
df=merge(df,values, by="q9", all.x=T)
df <- df %>%
  mutate(q9_text = ifelse(q9 == -8, "Prefer not to answer", q9_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B367:C369", col_names = c("q11", "q11_text"))
df=merge(df,values, by="q11", all.x=T)
df <- df %>%
  mutate(q11_text = ifelse(q11 == -8, "Prefer not to answer", q11_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B372:C375", col_names = c("q12", "q12_text"))
df=merge(df,values, by="q12", all.x=T)
df <- df %>%
  mutate(q12_text = ifelse(q12 == -8, "Prefer not to answer", q12_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B387:C390", col_names = c("q13", "q13_text"))
df=merge(df,values, by="q13", all.x=T)
df <- df %>%
  mutate(q13_text = ifelse(q13 == -8, "Prefer not to answer", q13_text))

values <- read_excel("VF_US_National_JUL19_RawData-1.xlsx", sheet = "Values", range = "B425:C434", col_names = c("q25", "q25_text"))
df=merge(df,values, by="q25", all.x=T)
df <- df %>%
  mutate(q25_text = ifelse(q25 == -8, "Prefer not to answer", q25_text))

rm(values)

#remove the column without the Values
df <- df[, !names(df) %in% c("q2", "q5", "q5a", "q5b", "q5c", "q5d", "q6", "q9", "q11", "q12", "q13", "q25")]

#dealing with missing value, replace NA with Inapplicable
df[is.na(df)] <- "Inapplicable"

#remove the numbers before the text i.e. (1),(2),.....
df[] <- lapply(df, function(x) gsub("^\\([0-9]+\\) ", "", x))

summary(df)
df$q14=as.numeric(df$q14)
hist(df$q14)

####################################################################################################################
#PART2: LOGISTIC REGRESSION MODEL
####################################################################################################################

options(scipen=999)
library(gmodels)
library(pROC)

#Enter the cutoff for classification
cutoff=0.5

str(df)
median(df$q14)


#Create a binary version for recommendation
df$q14_group=ifelse(df$q14 == 10, "1", "0")
table(df$q14_group)

#START OF VARIABLE REDEFINITION
df$recommendation=df$q14_group 
df$q14_group=NULL

df$recommendation=as.factor(df$recommendation) 

#END OF VARIABLE REDEFINITION

#Correlation matrix between numeric predictors - there are no numeric predictor
#cor(mydata[,c("Length", "Diameter", "Height", "Whole_Weight")])

#START OF REDUNDANT VARIABLE REMOVAL

#Remove these variables as these can only be available only after killing the abalone
df$q5a_text=NULL      
df$q5b_text=NULL 
df$q5c_text=NULL 
df$q5d_text=NULL
df$q9_text=NULL 
df$q25_text=NULL  

#Remove 'Rings' as we are modeling its categorical version (rings_grp)
df$q14=NULL

#START OF VARIABLE TRANSFORMATION

df <- df %>% mutate_all(as.factor)

#add statements similar to above as needed

#END OF VARIABLE TRANSFORMATION

str(df)
summary(df)

#############################################################################################
################################FITTING A DESCRIPTIVE MODEL #################################
#############################################################################################

logistic_desc=glm(formula=recommendation~.,family=binomial,data=df) 
summary(logistic_desc)

#############################################################################################
################################START OF PREDICTIVE MODEL ###################################
#############################################################################################

#############################################################################################
########################DO NOT MODIFY LINES BELOW UNTIL WHERE IT SAYS########################
###########################"END DATA BREAKDOWN FOR HOLDOUT METHOD"###########################


#START DATA BREAKDOWN FOR HOLDOUT METHOD

#Find the number of categorical predictors first

numpredictors=dim(df)[2]-1

numfac=0

for (i in 1:numpredictors) {
  if ((is.factor(df[,i]))){
    numfac=numfac+1} 
}

#End finding the number of categorical predictors 

nobs=dim(df)[1]
set.seed(1) #sets the seed for random sampling

#Below is the setup for stratified 80-20 holdout sampling

prop = prop.table(table(df$recommendation))
length.vector = round(0.8*nobs*prop)
train_size=sum(length.vector)
test_size=nobs-train_size
class.names = as.data.frame(prop)[,1]
numb.class = length(class.names)
resample=1

#The 'while' conditional construct below breaks the data into testing(20%) and training(80%) sets assuring that the unique levels
#of each of the categorical variables is the same in mydata, testing, and training sets. If for a particular partition
#those levels do not match, then RStudio continues to perform 80-20 random splits untill such partition is found.

while (resample==1) {
  
  train_index = c()
  
  for(i in 1:numb.class){
    index_temp = which(df$recommendation==class.names[i])
    train_index_temp = sample(index_temp, length.vector[i], replace = F)
    train_index = c(train_index, train_index_temp)
  }
  
  df_train=df[train_index,] #randomly select the data for training set using the row numbers generated above
  df_test=df[-train_index,]#everything not in the training set should go into testing set
  
  right_fac=0 #denotes the number of factors with "right" distributions (i.e. - the unique levels match across mydata, test, and train data sets)
  
  for (i in 1:numpredictors) {
    if (is.factor(df_train[,i])) {
      if (setequal(intersect(as.vector(unique(df_train[,i])), as.vector(unique(df_test[,i]))),as.vector(unique(df[,i])))==TRUE)
        right_fac=right_fac+1
    }
  }
  
  if (right_fac==numfac) (resample=0) else (resample=1)
  
}

dim(df_test) #confirms that testing data has only 20% of observations
dim(df_train) #confirms that training data has 80% of observations


#END DATA BREAKDOWN FOR HOLDOUT METHOD

#############################################################################################
############################SPECIFY THE MODEL TO BE FITTED BELOW#############################
#############################################################################################

logistic_fit=glm(formula=recommendation~.,family=binomial,data=df_train)  #This fits the logistic regression model
#"family"=binomial tells the "glm" function
#that we are dealing with a binary outcome and
#that logistic regression is what needs to be fit.
#If all of the predictors that you retained
#in 'mydata' need to be used in regression
#then leave 'myresponse~.' notation unchanged.
#If, however, only part of the predictors need
#to be used, say x1, x2, and x3, then list 
#those predictors as follows 'myresponse ~ x1+x2+x3' 
#by leaving the rest of the syntax in 'glm' formula the same.


#############################################################################################
############################DO NOT MODIFY THE CODE BEYOND THIS POINT########################
#############################################################################################


predicted=predict(logistic_fit, df_test, type="response") #Predicts the probabilities in the testing set
#using the model built on a training set.

#START EVALUATING CLASSIFICATION ACCURACY

predicted1=as.data.frame(predicted)
id=as.numeric(rownames(predicted1))
predicted_tbl0=cbind(id,predicted1)
if ("id" %in% names(df_test)==FALSE) {df_test=cbind(id, df_test)}
predicted_tbl=merge(predicted_tbl0,df_test, by.x="id", all.x=T)
predicted_tbl$predicted_class=as.numeric(predicted_tbl$predicted>=cutoff)


#Evaluate the predictive accuracy
#Confusion matrix

Confusion_Matrix=CrossTable(predicted_tbl$recommendation,predicted_tbl$predicted_class,dnn=c("True Class","Predicted Class"), prop.chisq=F,prop.t=F) 

#Compare with benchmark performance, i.e. if all predictions for testing set observations
#Were the class that dominated the training set (i.e. most frequent training class)

benchmark.pred=rep(names(which.max(table(df_train$recommendation))), nrow(df_test))
bench.df=as.data.frame(cbind(predicted=benchmark.pred, df_test))

bench.acc=100*sum(bench.df$predicted==bench.df$recommendation)/nrow(bench.df)
model.acc=100*sum(predicted_tbl$predicted_class==predicted_tbl$recommendation)/nrow(predicted_tbl)

#Print benchmark and model performance
print(paste("Benchmark Accuracy: ", round(bench.acc,2)))
print(paste("Model Accuracy: ", round(model.acc,2)))


#START CONSTRUCTING THE ROC CURVE FOR TESTING DATA

y=factor(df_test$recommendation)
n=length(predicted)
p=as.vector(predicted)
Q=p>matrix(rep(seq(0,1,length=500),n),ncol=500,byrow=T)
fp=colSums((y==levels(y)[1])*Q)/sum(y==levels(y)[1])
tp=colSums((y==levels(y)[2])*Q)/sum(y==levels(y)[2])
plot(fp,tp,xlab="1-Specificity", ylab="Sensitivity")
abline(a=0,b=1,lty=2,col=8)

g=pROC::roc(df_test$recommendation~predicted) #gets a smoother version of the curve for calculating AUC
g[9] #prints the AUC

#END CONSTRUCTING THE ROC CURVE FOR TESTING DATA


