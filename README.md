# Diabetes Prediction Using R

A supervised machine learning project that predicts diabetes status using the **Logistic Regression** classification algorithm in R.

## Algorithm
- **Model:** Logistic Regression
- **Learning type:** Supervised learning
- **Task:** Binary classification
- **Target:** No Diabetes (0) or Diabetes (1)

## Dataset
The project uses the Pima Indians Diabetes dataset (768 records and 8 input attributes). The CSV is downloaded automatically from a public GitHub dataset mirror when the script runs.

Input attributes include pregnancies, glucose, blood pressure, skin thickness, insulin, BMI, diabetes pedigree function, and age.

Zero values in selected medical measurement columns are treated as missing and replaced with the column median.

## Evaluation
The model is evaluated using:
- Confusion matrix
- Accuracy
- Precision
- Recall
- F1-score
- ROC curve and AUC

The script also calculates the separately supplied example confusion-matrix values (TP=70, FN=10, FP=20, TN=100). These example metrics are not the trained model's test results.

## Run the project

### In RStudio
1. Open `diabetes_prediction.R`.
2. Run the complete script.
3. The script downloads the dataset, trains the model, prints evaluation results, and creates the visualizations folder.

### In Google Colab
Install R and the R kernel first, then upload `diabetes_prediction.R` and run:

```r
source("/content/diabetes_prediction.R")
```

## Visualizations
The script generates 11 separate PNG files in `visualizations/`:
1. Given problem confusion matrix
2. Given problem performance metrics
3. Given problem metrics heatmap
4. Diabetes outcome distribution
5. Glucose distribution
6. BMI vs glucose
7. Age distribution
8. Model confusion matrix
9. Model performance metrics
10. Model metrics heatmap
11. ROC curve

It also saves prediction results and evaluation metrics as CSV files.

## Requirements
- R
- ggplot2
- pROC

The script installs the required R packages if they are not already installed.

## Disclaimer
This is an educational machine learning project, not a medical diagnostic tool. Predictions must not be used for clinical decisions.

## Author
**Shashank K**
