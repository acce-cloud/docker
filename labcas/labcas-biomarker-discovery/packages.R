# R installation tools
install.packages('devtools', repos='http://cran.us.r-project.org')
library(devtools)

# rabbit
install_github("jperezrogers/rabbit", ref="master")

# other biomarler dependencies
source("https://bioconductor.org/biocLite.R")
biocLite("multtest")
biocLite("impute")
biocLite("samr")
biocLite("e1071")
biocLite("randomForest")
biocLite("klaR")
biocLite("kernlab")
biocLite("glmnet")
biocLite("limma")
biocLite("genefilter")
