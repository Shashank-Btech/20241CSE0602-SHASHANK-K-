# Diabetes Prediction Using R — Outputs

This folder contains the execution output and visualization references for the R-based diabetes prediction project.

## Model
- **Algorithm:** Logistic Regression using `glm(..., family = binomial)`
- **Dataset:** Pima Indians Diabetes (768 rows, 9 columns)
- **Split:** 80% training (614 records), 20% testing (154 records)
- **ROC-AUC:** 0.891

## Files
- `execution_output.txt` — complete numerical output supplied for the project, including the given problem, model coefficients, confusion matrices, metrics, and sample predictions.
- `given_problem_confusion_matrix.svg` — given-problem confusion matrix.
- `visualizations/README.md` — notes on generating the remaining charts from the Colab notebook.

## Evaluation results

| Metric | Given problem | Logistic Regression model |
|---|---:|---:|
| Accuracy | 85.00% | 80.52% |
| Precision | 77.78% | 78.57% |
| Recall | 87.50% | 61.11% |
| F1-score | 82.35% | 68.75% |
| ROC-AUC | — | 0.891 |

Open `Diabetes_Prediction_Using_R.ipynb` in Google Colab and run all cells from top to bottom to regenerate the R visualizations. The notebook contains separate R plotting cells.
