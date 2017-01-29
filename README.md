# Hack K-State 2016: Data Science Challenge For Social Good

In this hackathon challenge, we build BetterDAI(https://devpost.com/software/betterdai): a web application that apply hardcore data analysis and machine learning to ensure hospital patients are treated correct, within 40 hours.

The goal is to predict which patients will be re-admitted to the hospital within 30 days of their discharge. This is a real problem for hospitals, who don't get paid for a re-admission if it happens within 30 days after the patient was discharged, and patients, who would like to live their life outside the walls of a hospital and be healthy.

This repository first includes a quick and dirty exploratory data analysis, involving data preprocessing as well as basic data visualization, which could be found in EDA_Visualization.Rmd. The back-end machine learning algorithm that actually carries out the prediction could be found in ensemble.R, which consists of one logistic classification model and four decision tree models(two random forest, two boosting). This final model ensemble achieved around 95% accuracy for an independent test dataset during the final MLH demo and eventually won the 1st place in the Data Science Challenge For Social Good.

The web app based on the prediction model in the back-end won the 3rd place in general scheme in this Hackathon. The full web app repository could be found at https://github.com/srjayhawkfan/HackKState2016. 

