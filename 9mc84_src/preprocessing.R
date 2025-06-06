library(mlr)

# load data
phonedata <- read.csv("phonedata.csv", fileEncoding = "utf-8")

# rename target variable
names(phonedata)[which(names(phonedata) == "E2_sum")] <- "Soci"

# remove participants with missing target
phonedata <- phonedata[complete.cases(phonedata$Soci),]

# remove participants which did not use whatsapp
phonedata <- phonedata[phonedata$daily_mean_num_.com.whatsapp != 0,]

# remove one case which includes anomalies in the raw logging data
phonedata <- phonedata[phonedata$userId != 458,]

# remove userID
phonedata$userId <- NULL
# remove unused extraversion variables
phonedata <- phonedata[, -which(names(phonedata) %in% c("E1_sum", "E3_sum", "E4_sum", 
                                                        "E5_sum", "E6_sum"))]
# remove unused demographic variables
phonedata <- phonedata[, -which(names(phonedata) %in% c("age", "gender", "education"))]

# code Inf values as NA for some features
is.na(phonedata) <- sapply(phonedata, is.infinite)

# impute missing values with the median of the respective variable
phonedata <- impute(phonedata, target = "Soci", 
                    classes = list(numeric = imputeMedian(), 
                                   integer = imputeMedian()))$data

# standardize all numeric features
phonedata <- normalizeFeatures(phonedata, target = "Soci")
# cap extreme feature values (they completely destroy linear models)
phonedata <- capLargeValues(phonedata, target = "Soci", threshold = 2.5, impute = 3)
