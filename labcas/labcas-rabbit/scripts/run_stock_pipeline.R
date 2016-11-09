# set paths
usr.libs <- "~/R_LIBS"
.libPaths(c(.libPaths(),file.path(usr.libs)));

# load the rabbit package and stock pipeline
library(affy)
library(rabbit)
data(stockPipeline)

# read in command-line arguments
arguments <- commandArgs(TRUE)

# theoretically we could read in 1) the training set, 2) the output directory, 3) the seed, 4) the iteration number, but really
# we just need the iteration for now
iter <- arguments[1]

# load the data
training.set <- readRDS(file="/restricted/projectnb/pulmarray/rabbit/data/GSE20194_training_set.rds")
training.set.y <- as.factor(ifelse(training.set$characteristics_ch1.3=="er_status: P",1,0))

# run the stock pipeline
run(stockPipeline, x=exprs(training.set), y=training.set.y, outputdir="/restricted/projectnb/pulmarray/rabbit/Pipeline_Output", 
	iter=iter, seed=1234, verbose=TRUE, force=TRUE)
