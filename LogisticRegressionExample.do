/// DETERMINE EXTENT OF MISSING DATA ///
* Note: to determine whether which covariates of interest to include, whether categorical or continuous, etc., perform literature review and discuss with experts

// Determine which outcomes have missing data
mdesc angina hospmi mi_fchd anychd stroke cvd hyperten death
sum angina hospmi mi_fchd anychd stroke cvd hyperten death
tab1 angina hospmi mi_fchd anychd stroke cvd hyperten death
* Results: no missing values
* Results: sufficient number of cases and controls and is a serious condition for anychd
* Results: choose coronary heart disease (anychd) as the outcome 

// Determine which covariates have missing data
mdesc sex age agecat sysbp diabp bpmeds cursmoke cigpday totchol bmi bmicat obese_normal glucose diabetes heartrte prevap prevchd prevmi prevstrk prevhyp
sum sex age agecat sysbp diabp bpmeds cursmoke cigpday totchol bmi bmicat obese_normal glucose diabetes heartrte prevap prevchd prevmi prevstrk prevhyp
tabulate sysbpcat
* Results: obese_normal has a significant number of missing values (42.43%), as well as glucose (8.26%) 
* Results: choose categorical systolic blood pressure as main effect to evaluate, adjusting for sex, categorical age, continuous BMI, categorical serum total cholesterol, and continuous heart rate

/// CREATE VARIABLES ///

// Create variable to tag rows with missing data for these variables of interest
mdesc anychd sysbpcat sex2 age50 totcholcat bmi heartrte 
generate keep = 1
replace keep = 0 if sysbpcat == . | sex2 == . | age50 == . | totcholcat == . | bmi == .| heartrte == .

// Recode sex categories with 0 and 1, instead of 1 and 2
gen sex2 = 0
replace sex2 = 1 if sex == 2.

// Create variable with age categories
gen age50 = 0
replace age50 = 1 if agecat == 3
replace age50 = 1 if agecat == 4
replace age50 = . if agecat == .

// Create variable with serum total cholesterol categories
gen totcholcat = 0
replace totcholcat = 1 if totchol > 199
replace totcholcat = 2 if totchol > 239
replace totcholcat = . if totchol == .

// Create variable with heart rate categories
gen heartrtecat = 0
replace heartrtecat = 1 if heartrte > 75
replace heartrtecat = . if heartrte == .

// Create variable with systolic blood pressure categories
gen sysbpcat = 0
replace sysbpcat = 1 if sysbp >= 120
replace sysbpcat = 2 if sysbp >= 140
replace sysbpcat = 3 if sysbp >= 160
gen sysbpcat = . if sysbp == .

// Create variable with systolic blood pressure categories as indicator variables
gen sysbpcat01 = 0 if sysbpcat == 0
replace sysbpcat01 = 1 if sysbpcat == 1
gen sysbpcat02 = 0 if sysbpcat == 0
replace sysbpcat02 = 1 if sysbpcat == 2
gen sysbpcat03 = 0 if sysbpcat == 0
replace sysbpcat03 = 1 if sysbpcat == 3

/// DESCRIBE COVARIATES BY OUTCOME ///

// Describe variables by systolic blood pressure
by sysbpcat, sort : tabulate sex2
by sysbpcat, sort : tabulate age50
by sysbpcat, sort : tabulate totcholcat
by sysbpcat, sort: sum bmi, detail
by sysbpcat, sort: sum heartrte, detail

tabulate sex sysbpcat01, cchi2 chi2
tabulate sex sysbpcat02, cchi2 chi2
tabulate sex sysbpcat03, cchi2 chi2

tabulate age50 sysbpcat01, cchi2 chi2
tabulate age50 sysbpcat02, cchi2 chi2
tabulate age50 sysbpcat03, cchi2 chi2

tabulate totcholcat sysbpcat01, cchi2 chi2
tabulate totcholcat sysbpcat02, cchi2 chi2
tabulate totcholcat sysbpcat03, cchi2 chi2

ttest heartrte, by(sysbpcat01)
ttest heartrte, by(sysbpcat02)
ttest heartrte, by(sysbpcat03)

ttest bmi, by(sysbpcat01)
ttest bmi, by(sysbpcat02)
ttest bmi, by(sysbpcat03)

/// MODEL BUILDING- Method 1: Forward selection model building ///

// Add 1 adjusting covariate at a time to the model of systolic blood pressure in predicting coronary heart disease
// P_entry = 0.1
logistic anychd i.sysbpcat sex2 if keep == 1
logistic anychd i.sysbpcat age50 if keep == 1
logistic anychd i.sysbpcat bmi if keep == 1
logistic anychd i.sysbpcat i.totcholcat if keep == 1
logistic anychd i.sysbpcat heartrte if keep == 1
* Results: heart rate covariate is not significant at p = 0.10, so propose not including it in the model
* Results: as all of the other covariates are highly significant, propose adding sex covariate to the model

// Add 1 adjusting covariate at a time to the model of systolic blood pressure and sex in predicting coronary heart disease
logistic anychd i.sysbpcat sex2 age50 if keep == 1
logistic anychd i.sysbpcat sex2 i.totcholcat if keep == 1
logistic anychd i.sysbpcat sex2 bmi if keep == 1
* Results: all of the other covariates are highly significant, so propose adding age covariate to the model

// Add 1 adjusting covariate at a time to the model of systolic blood pressure, sex, and age in predicting coronary heart disease
logistic anychd i.sysbpcat sex2 age50 i.totcholcat if keep == 1
logistic anychd i.sysbpcat sex2 age50 bmi if keep == 1
* Results: both of the other covariates are significant, so propose adding BMI covariate to the model

// Add 1 adjusting covariate at a time to the model of systolic blood pressure, sex, age, and BMI in predicting coronary heart disease
logistic anychd i.sysbpcat sex2 age50 bmi i.totcholcat if keep == 1
* Results: all of the covariates are significant at the p = 0.10 level, so have all potential final main effects in the model

// Assess whether we need to adjust for these final covariates because they are confounders
logistic anychd i.sysbpcat if keep == 1
logistic anychd i.sysbpcat sex2 if keep == 1
logistic anychd i.sysbpcat age50 if keep == 1
logistic anychd i.sysbpcat sex2 age50 if keep == 1
logistic anychd i.sysbpcat sex2 age50 bmi if keep == 1
logistic anychd i.sysbpcat sex2 age50 i.totcholcat if keep == 1
logistic anychd i.sysbpcat sex2 age50 i.totcholcat bmi if keep == 1
* Results: ORs for systolic blood pressure are significantly different (>10%), when adjusting for age and sex in the model
* Results: ORs for systolic blood pressure are significantly different (>10%), when adjusting for BMI in the model
* Results: ORs for systolic blood pressure are not significantly different (>10%), when adjusting for cholesterol in the model
* Results: Include covariates of systolic blood pressure, adjusting for the confounders of age, sex, and BMI, in the model

/// Assess inclusion of non-linear covariate terms
gam anychd sysbpcat sex2 age50 totcholcat bmi heartrte if keep == 1, family(binomial) link(logit) df(heartrte: 4)
gam anychd sysbpcat sex2 age50 totcholcat bmi heartrte if keep == 1, family(binomial) link(logit) df(bmi: 4)
gam anychd sysbpcat sex2 age50 totcholcat bmi heartrte if keep == 1, family(binomial) link(logit) df(totcholcat: 2)
gam anychd sysbpcat sex2 age50 totcholcat bmi heartrte if keep == 1, family(binomial) link(logit) df(sysbpcat: 3)
* Results: sysbp does not depart from linearity, bmi does not depart from linearity

// Out of these covariates, determine which ones might by highly correrlated--> multicollinearity
corr sex2 age50
corr sex2 sysbpcat
corr sex2 bmi
corr age50 sysbpcat
corr age50 bmi
corr sysbpcat bmi
corr totcholcat bmi
* Results: age50 and sysbp have r = 0.3819, sysbp and bmi r = 0.313

// Add in relevant interaction terms believed to be of interest to analyze evidence of effect modification
gen intx_sysbpcat_bmi = sysbpcat*bmi
gen intx_sex2_age50 = sex2*age50
gen intx_sex2_bmi = sex2*bmi
gen intx_age50_bmi = age50*bmi

logistic anychd i.sysbpcat sex2 age50 bmi intx_sysbpcat_bmi if keep == 1
logistic anychd i.sysbpcat sex2 age50 bmi intx_sex2_age50 if keep == 1
logistic anychd i.sysbpcat sex2 age50 bmi intx_sex2_bmi if keep == 1
logistic anychd i.sysbpcat sex2 age50 bmi intx_age50_bmi if keep == 1
* Results: interactions of interest are not significant
* Results: no evidence of effect modification between the chosen covariates

/// MODEL BUILDING- Method 2: Backward elimination model building ///
// P_remove = 0.11

// Include all main effects of interest in model
logistic anychd i.sysbpcat sex2 age50 i.totcholcat bmi heartrte if keep == 1
estat gof, group(10)
lroc, nograph
estat ic
* Results: adequate calibration using Hosmer-Lemeshow goodness-of-fit test (p = 0.4238)
* Results: good discrimination, area under ROC curve = 0.7028
* Results: AIC = 1224.88, BIC = 1275.207
* Results: heartrte not significant (p = .168), so propose to remove from model

// Removed heart rate variable from the model
logistic anychd i.sysbpcat sex2 age50 i.totcholcat bmi if keep == 1
estat gof, group(10)
lroc, nograph
estat ic
* Results: adequate calibration using Hosmer-Lemeshow goodness-of-fit test (p = 0.4058)
* Results: good discrimination, area under ROC curve = 0.7015
* Results: AIC = 1224.801, BIC = 1270.095
* Results: every covariate is significant except for systolic blood pressure, predictor of interest
* Results: propose assessing confounding to determine necessity of either BMI or cholesterol variables
* Note: from analysis above, cholesterol variable does not have significant evidence of being a confounder; thus propose to remove from the model

// Removed cholesterol variable from the model
logistic anychd i.sysbpcat sex2 age50 bmi if keep == 1
estat gof, group(10)
lroc
estat ic

// Represent model in terms of its coefficients rather than the odds ratios
logit anychd i.sysbpcat sex2 age50 bmi if keep == 1
* Results: every adjusting covariate currently in the model is significant and has evidence of being a confounder
* Results: adequate calibration (p = 0.2340)
* Results: good discrimination, area under ROC curve = 0.6916
* Results: AIC = 1235.586, BIC = 1270.814
* Results: These are the final main effects in the model
* Note: from analysis above, no evidence of effect modification or non-linear terms; thus, this is the final model
