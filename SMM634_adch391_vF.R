#==============================Importing libraries==============================
#Loading the relevant packages
library(MASS)
library(tidyr)
getwd()
setwd("")
#=============================Understanding the data=============================
# Reading the dataset
wine <- read.table("wine.txt", header=TRUE)

# Summary statistics of the dataset
summary(wine)

# plotting the distribution of the dependent variable
hist(wine$price) # visible right-skew

# creating and visualisisng a log-transformation
par(mfrow=c(1,2))
hist(wine$price, xlab = "Price", main = "Distribution of Price")
hist(log(wine$price), xlab = "log(Price)", main = "Distribution of log(Price)") # reduction in right-skew

# plotting the explanatory variables against the price
par(mfrow=c(2,3))
plot(wine$year, wine$price, xlab="Year of Production", ylab="Price", main="Price v/s Year")
plot(wine$h.rain, wine$price, xlab="Rain in harvest month (mm)", ylab="Price", main="Price v/s h.rain")
plot(wine$s.temp, wine$price, xlab="Avg. temp. in summer before harvest (C)", ylab="Price", main="Price v/s s.temp")
plot(wine$w.rain, wine$price, xlab="Rain in winter before harvest (mm)", ylab="Price", main="Price v/s w.rain")
plot(wine$h.temp, wine$price, xlab="Avg. temp. during harvest (C)", ylab="Price", main="Price v/s h.temp")
plot(wine$parker, wine$price, xlab="Rating of wine quality", ylab="Price", main="Price v/s Parker")

# deleting the 9 rows without a response variable
wine <- wine %>% drop_na(price)
# removing the parker column
wine <- subset(wine, select= -c(parker)) #removing na's for parker column reduces observation size to 29

# correlation analysis
corr = subset(wine, select = -c(price))
round(cor(corr),2)
# removing h.temp
wine <- subset(wine, select= -c(h.temp))

#==============================Regression analysis==============================
# creating an initial linear model
lm <- lm(log(price) ~ year + h.rain + s.temp + w.rain, data=wine)
summary(lm)
# analysis of the residual plots
par(mfrow=c(2,2))
plot(lm)

# fitting a generalized linear model under the poisson family (all the observations have the same exposure)
glm_p <- glm(price ~ year + h.rain + s.temp + w.rain, family = poisson, data=wine)
summary(glm_p)
# analysis of the residual plots
par(mfrow=c(2,2))
plot(glm_p)

# fitting a generalized linear model under the gamma family
glm_g <- glm(price ~ year + h.rain + s.temp + w.rain, family = Gamma(link = "log"), data=wine)
summary(glm_g)
# analysis of the residual plots
par(mfrow=c(2,2))
plot(glm_g)

stepAIC(lm)
stepAIC(glm_p)
stepAIC(glm_g)

pchisq((13.5749-3.7626), (37-33))
