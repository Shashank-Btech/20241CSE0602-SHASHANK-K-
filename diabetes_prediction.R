# Diabetes Prediction Using R
# Algorithm: Logistic Regression

packages <- c("ggplot2", "pROC")
for (p in packages) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}
library(ggplot2)
library(pROC)

# Load the Pima Indians Diabetes dataset
url <- "https://raw.githubusercontent.com/jbrownlee/Datasets/master/pima-indians-diabetes.data.csv"
diabetes <- read.csv(url, header = FALSE)
names(diabetes) <- c("Pregnancies", "Glucose", "BloodPressure",
                     "SkinThickness", "Insulin", "BMI",
                     "DiabetesPedigreeFunction", "Age", "Outcome")

# In this dataset, zero values in these columns represent missing measurements.
zero_missing <- c("Glucose", "BloodPressure", "SkinThickness", "Insulin", "BMI")
for (col in zero_missing) {
  diabetes[[col]][diabetes[[col]] == 0] <- NA
  diabetes[[col]][is.na(diabetes[[col]])] <-
    median(diabetes[[col]], na.rm = TRUE)
}

diabetes$Outcome <- factor(diabetes$Outcome,
                           levels = c(0, 1),
                           labels = c("No Diabetes", "Diabetes"))

dir.create("visualizations", showWarnings = FALSE)

# Given problem confusion-matrix values
TP <- 70; FN <- 10; FP <- 20; TN <- 100
given_metrics <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1 Score"),
  Value = c((TP + TN) / (TP + TN + FP + FN),
            TP / (TP + FP),
            TP / (TP + FN),
            2 * TP / (2 * TP + FP + FN))
)
given_metrics$Percent <- given_metrics$Value * 100

given_cm <- data.frame(
  Actual = factor(c("Positive", "Positive", "Negative", "Negative"),
                  levels = c("Positive", "Negative")),
  Predicted = factor(c("Positive", "Negative", "Positive", "Negative"),
                     levels = c("Positive", "Negative")),
  Count = c(TP, FN, FP, TN)
)
p <- ggplot(given_cm, aes(Predicted, Actual, fill = Count)) +
  geom_tile(color = "white") + geom_text(aes(label = Count), size = 6) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(title = "Given Problem - Confusion Matrix", x = "Predicted", y = "Actual")
ggsave("visualizations/01_given_confusion_matrix.png", p, width = 6, height = 5)

p <- ggplot(given_metrics, aes(Metric, Percent, fill = Metric)) +
  geom_col(show.legend = FALSE) + geom_text(aes(label = sprintf("%.2f%%", Percent)),
                                             vjust = -0.4) +
  ylim(0, 110) + labs(title = "Given Problem - Performance Metrics", y = "Percentage", x = "")
ggsave("visualizations/02_given_performance_metrics.png", p, width = 7, height = 5)

p <- ggplot(given_metrics, aes(x = "Given Problem", y = Metric, fill = Percent)) +
  geom_tile() + geom_text(aes(label = sprintf("%.2f%%", Percent)), color = "black") +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(title = "Given Problem - Metrics Heatmap", x = "", y = "")
ggsave("visualizations/03_given_metrics_heatmap.png", p, width = 6, height = 4)

# Exploratory data visualizations
p <- ggplot(diabetes, aes(Outcome, fill = Outcome)) +
  geom_bar() + labs(title = "Diabetes Outcome Distribution", x = "Outcome", y = "Count")
ggsave("visualizations/04_diabetes_outcome_distribution.png", p, width = 6, height = 5)

p <- ggplot(diabetes, aes(Glucose, fill = Outcome)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  labs(title = "Glucose Distribution", x = "Glucose", y = "Frequency")
ggsave("visualizations/05_glucose_distribution.png", p, width = 7, height = 5)

p <- ggplot(diabetes, aes(Glucose, BMI, color = Outcome)) +
  geom_point(alpha = 0.7) +
  labs(title = "BMI vs Glucose", x = "Glucose", y = "BMI")
ggsave("visualizations/06_bmi_vs_glucose.png", p, width = 7, height = 5)

p <- ggplot(diabetes, aes(Age, fill = Outcome)) +
  geom_histogram(bins = 25, alpha = 0.7, position = "identity") +
  labs(title = "Age Distribution", x = "Age", y = "Frequency")
ggsave("visualizations/07_age_distribution.png", p, width = 7, height = 5)

# Stratified 80/20 train-test split
set.seed(123)
train_rows <- unlist(lapply(split(seq_len(nrow(diabetes)), diabetes$Outcome),
                            function(idx) sample(idx, floor(0.8 * length(idx)))))
train_data <- diabetes[sort(train_rows), ]
test_data <- diabetes[-sort(train_rows), ]

# Train supervised classification model: Logistic Regression
model <- glm(Outcome ~ ., data = train_data, family = binomial())

probabilities <- predict(model, newdata = test_data, type = "response")
predicted <- factor(ifelse(probabilities >= 0.5, "Diabetes", "No Diabetes"),
                    levels = levels(test_data$Outcome))
actual <- test_data$Outcome

cm <- table(Actual = actual, Predicted = predicted)
print("Model Confusion Matrix")
print(cm)

TPm <- ifelse(all(c("Diabetes", "Diabetes") %in% c(rownames(cm), colnames(cm))),
              cm["Diabetes", "Diabetes"], 0)
TNm <- ifelse(all(c("No Diabetes", "No Diabetes") %in% c(rownames(cm), colnames(cm))),
              cm["No Diabetes", "No Diabetes"], 0)
FPm <- ifelse("No Diabetes" %in% rownames(cm) && "Diabetes" %in% colnames(cm),
              cm["No Diabetes", "Diabetes"], 0)
FNm <- ifelse("Diabetes" %in% rownames(cm) && "No Diabetes" %in% colnames(cm),
              cm["Diabetes", "No Diabetes"], 0)

model_metrics <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1 Score"),
  Value = c((TPm + TNm) / sum(cm),
            ifelse(TPm + FPm == 0, 0, TPm / (TPm + FPm)),
            ifelse(TPm + FNm == 0, 0, TPm / (TPm + FNm)),
            ifelse(2 * TPm + FPm + FNm == 0, 0,
                   2 * TPm / (2 * TPm + FPm + FNm)))
)
model_metrics$Percent <- model_metrics$Value * 100

cm_df <- as.data.frame(cm)
p <- ggplot(cm_df, aes(Predicted, Actual, fill = Freq)) +
  geom_tile(color = "white") + geom_text(aes(label = Freq), size = 6) +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(title = "Logistic Regression - Confusion Matrix", x = "Predicted", y = "Actual")
ggsave("visualizations/08_model_confusion_matrix.png", p, width = 6, height = 5)

p <- ggplot(model_metrics, aes(Metric, Percent, fill = Metric)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.2f%%", Percent)), vjust = -0.4) +
  ylim(0, 110) + labs(title = "Logistic Regression - Performance Metrics",
                      y = "Percentage", x = "")
ggsave("visualizations/09_model_performance_metrics.png", p, width = 7, height = 5)

p <- ggplot(model_metrics, aes(x = "Logistic Regression", y = Metric, fill = Percent)) +
  geom_tile() + geom_text(aes(label = sprintf("%.2f%%", Percent)), color = "black") +
  scale_fill_gradient(low = "white", high = "steelblue") +
  labs(title = "Model Metrics Heatmap", x = "", y = "")
ggsave("visualizations/10_model_metrics_heatmap.png", p, width = 6, height = 4)

roc_obj <- roc(actual, probabilities, levels = c("No Diabetes", "Diabetes"),
               direction = "<", quiet = TRUE)
roc_data <- data.frame(
  Specificity = roc_obj$specificities,
  Sensitivity = roc_obj$sensitivities
)
p <- ggplot(roc_data, aes(x = 1 - Specificity, y = Sensitivity)) +
  geom_line(linewidth = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  coord_equal() + labs(title = paste0("ROC Curve (AUC = ", round(as.numeric(auc(roc_obj)), 3), ")"),
                       x = "False Positive Rate", y = "True Positive Rate")
ggsave("visualizations/11_roc_curve.png", p, width = 6, height = 5)

write.csv(model_metrics, "visualizations/evaluation_metrics.csv", row.names = FALSE)
write.csv(data.frame(Actual = actual, Predicted = predicted,
                     Diabetes_Probability = probabilities),
          "visualizations/prediction_results.csv", row.names = FALSE)

cat("\nModel: Logistic Regression\n")
print(model_metrics)
cat("ROC-AUC:", as.numeric(auc(roc_obj)), "\n")
cat("All 11 plots and result CSV files were saved in the visualizations folder.\n")
