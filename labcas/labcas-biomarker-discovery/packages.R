# R installation tools
install.packages('devtools', repos='http://cran.us.r-project.org')
library(devtools)

install.packages('shiny', repos='http://cran.us.r-project.org')
install.packages('DT', repos='http://cran.us.r-project.org')
install.packages('pROC', repos='http://cran.us.r-project.org')
install.packages('ROCR', repos='http://cran.us.r-project.org')
install.packages('markdown', repos='http://cran.us.r-project.org')
install.packages('gplots', repos='http://cran.us.r-project.org')

# rabbit
install_github("jperezrogers/rabbit", ref="master")

# other biomarker dependencies
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
