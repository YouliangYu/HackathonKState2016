#############################################################################
#title: Predicting Hospital Readmissions, Hack K-State, 2016               ##
#author: Youliang Yu                                                       ##
#date: Nov. 12, 2016                                                       ##      
#############################################################################

library(caret)  
library(data.table) 
library(xgboost)
library(Metrics)

train <- fread('data/Challenge_1_Training.csv',header =TRUE,stringsAsFactors = FALSE,
               na.strings=c("?","No","NO","None",""),data.table= FALSE)
test <- fread('data/Challenge_1_Testing.csv',header =TRUE,stringsAsFactors = FALSE,
               na.strings=c("?","No","NO","None",""),data.table= FALSE)
train <- train[!is.na(train$readmitted),] #rm label NA
y <- as.integer(as.factor(train$readmitted))-1
train <- train[,!names(train) %in% c("encounter_id","patient_nbr","readmitted")] #remove IDs 
test <- test[,!names(test) %in% c("encounter_id","patient_nbr")] 

# factorize char vars
fact_vars <- colnames(train)[sapply(train, is.character)]
for (f in fact_vars) {
  if (class(train[[f]])=="character") {
    levels <- unique(c(train[[f]],test[[f]]))
    train[[f]] <- as.integer(factor(train[[f]], levels=levels)) 
    test[[f]] <- as.integer(factor(test[[f]], levels=levels)) 
  }
}

#remove constant features
cst_vars <- names(train)[apply(train, 2, function(x) length(unique(x))==1)]
for (f in cst_vars){train[[f]] <- NULL; test[[f]] <- NULL}

# remove features with all NA(>99.99%)
na_var <- names(train)[apply(train, 2, function(x)  sum(is.na(x))/nrow(train)>0.999)]
for (f in na_var){train[[f]] <- NULL; test[[f]] <- NULL}

# impute NA
train[is.na(train)] <- 0

#one-hot-encode
encode_vars <- names(train)[apply(rbind(train), 2, function(x) length(unique(x))<100)]
for (f in intersect(names(train),union(encode_vars,fact_vars))){ 
  dummyfact <- as.factor(c(-100000,train[[f]],testx[[f]]))
  temp <- model.matrix(~dummyfact)
  k=0
  for (j in 2:ncol(temp)){
    colnames(temp)[j] <- paste0(f,"Dummy",k)
    k <- k+1
  }
  train <- cbind(train,temp[2:(nrow(train)+1),-1])
  test <- cbind(test,temp[(nrow(test)+2):nrow(temp),-1])
  rm(temp);rm(dummyfact);gc()
}

#build xgb model
set.seed(1229);dtrain <- xgb.DMatrix(as.matrix(train), label = y)
param <- list(booster ="gbtree", objective = 'binary:logistic', eval_metric = 'rmse',
              nthread = 6,eta = 0.02, colsample_bytree = 0.4, subsample = 0.8, max_depth = 6, min_child_weight=11)
#bst.cv = xgb.cv(param=param, data = dtrain, nfold = 5, nrounds = 5000, early.stop.round = 50)
#[460]	train-rmse:0.402558+0.000524	test-rmse:0.419567+0.003207
#tmp <- bst.cv$test.rmse.mean; n=which(tmp==min(tmp))[1]
bst <- xgb.train(params=param, data=dtrain, nround = as.integer(460/0.8))
pred <- predict(bst, as.matrix(test));print(pred)

 