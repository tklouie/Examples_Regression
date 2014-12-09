# Logistic Regression Example in R

# Import the data
file = "DataAnalysisProject_11_11_2014.csv"
getwd()
setwd("xx")
getwd()
logRegData = read.csv(file)
age = logRegData$age
death = logRegData$death
cursmoke = logRegData$cursmoke
bmicat = logRegData$bmicat
is.factor(bmicat)

# Two ways to visually see the dataset (commented out currently)
str(logRegData)
logRegData

# Summmary of data, including number of missing values
summary(logRegData)

# Logistic regression for death as a function of age
# Note: AIC can be used to compare different (non-nested) models
glm.out = glm(death ~ age,family=binomial(logit), data=logRegData)

# Aspects of the regression model one can look at (fitted values, coefficients, residuals, ANOVA, etc.)
summary(glm.out)
glm.out$coef
glm.out$fitted
glm.out$resid
glm.out$effects
anova(glm.out)

# Interpretation of model: OR = 1.12 for a 1 year increase in age, 3.03 for a 10 year increase in age
# In this dataset, people who are 61 years old have 1.12 times the odds of death compared to that of 60 year olds

exp(0.1107748)
exp(10*0.1107748)

# Plot data and logistic regression on graph
plot(death ~ age, data=logRegData)
lines(age, glm.out$fitted, type = "l", col="red")
title(main="Death vs. Age Data with Fitted Logistic Regression Line")

# If one wanted to have multiple covariates
# NOTE- all variables are currently considered continuous
glm.out = glm(death ~ cursmoke * bmicat * age, family=binomial(logit), data=logRegData)
summary(glm.out)
plot(glm.out$fitted)
