

setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../../h2o-runit.R')

# use this for interactive setup
#     library(h2o)
#     library(testthat)
#     h2o.setLogPath(getwd(), "Command")
#     h2o.setLogPath(getwd(), "Error")
#     h2o.startLogging()
#     conn = h2o.init()

test.cbind <- function(conn) {

    # orig
    # df = data.frame(matrix(1:300000, nrow=300000, ncol=150))
    df <- data.frame(matrix(1:30000, nrow=30000, ncol=150))
    sample.IDs <- 1:60000
    index <- data.frame(ifelse(df[,1] %in% sample.IDs,1,0))
    colnames(index) <- c("index")

    df.hex <- as.h2o(conn, df, key="df")
    index.h2o <- as.h2o(conn, index, key="index.h2o")

    df.hex <- cbind(df.hex,index.h2o)
    summary(df.hex[,"index"])

    df.train <- h2o.assign(df.hex[df.hex$index==1,],"df.train")
    df.test <- h2o.assign(df.hex[df.hex$index==0,],"df.test")

    # This works fine but a subsequent update of the added (or any other column
    # seems to break the object
    df.hex[,"index"] <- index.h2o[,"index"]
    summary(df.hex[,"index"])
    df.train <- h2o.assign(df.hex[df.hex$index==1,],"df.train")
    df.test <- h2o.assign(df.hex[df.hex$index==0,],"df.test")

    testEnd()
}

doTest("Test cbind.", test.cbind)

