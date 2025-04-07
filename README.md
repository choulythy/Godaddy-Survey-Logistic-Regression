## 📈 Logistic Regression: GoDaddy Customer Advocacy

This model was designed to **predict the likelihood of a customer being an Advocate (1) vs. Non-Advocate (0)** based on survey data.

---

### 🧹 Data Preprocessing

- Extracted raw data from the `"Data"` sheet in Excel.
- Selected survey questions: Q2, Q5, Q5a–Q5d, Q6, Q9, Q11–Q14, Q25.
- **Nullified** Q5a–Q5d for respondents whose website purpose wasn't "Commercial."
- Replaced coded missing values:  
  - `-7` and `-9` → `"Inapplicable"`  
  - `-8` → `"Prefer not to answer"`
- Merged numerical responses with **text labels** from the `"Values"` sheet.
- Cleaned label formatting (e.g., `(1) Yes` → `Yes`).
- Converted numeric fields to `numeric` type and categorical fields to `factors` for modeling.

---

### 🔍 Key Predictors (Statistically Significant)

- **Website Traffic: 11–100 users**  
  - Coefficient: β = 0.54028  
  - Odds Ratio: `exp(0.54028)` ≈ **1.72**  
  - Interpretation: These customers are 1.72x more likely to be Advocates compared to those with 1–10 visitors.

- **Customer Care Rating:**  
  - *Good* (β = -2.14612) → Odds Ratio ≈ **0.12**  
  - *Fair* (β = -3.02309) → Odds Ratio ≈ **0.05**  
  - Compared to "Excellent" rating, these groups are significantly less likely to be Advocates.

- **Website Importance: Very Important**  
  - β = 0.90168  
  - Odds Ratio: `exp(0.90168)` ≈ **2.46**  
  - Interpretation: Customers who find the website “Very Important” are 2.46x more likely to be Advocates than those who only find it “Important.”

---

### 📊 Model Performance

| Metric                      | Value       |
|----------------------------|-------------|
| **Accuracy**               | 72.89%      |
| **Benchmark Accuracy**     | 60.7%       |
| **AUC (Area Under Curve)** | 0.7563      |
| **Sensitivity** (TPR)      | 74.6%       |
| **Specificity** (TNR)      | 63.3%       |

> ✅ The model shows strong performance in distinguishing Advocates from Non-Advocates.

---

### 📌 Visual Results

**Confusion Matrix**  
![Confusion Matrix](https://github.com/choulythy/Godaddy-Survey-Logistic-Regression/blob/main/Screenshot%202025-04-07%20at%204.38.27%20in%20the%20afternoon.png)

**ROC Curve**  
![ROC Curve](https://github.com/choulythy/Godaddy-Survey-Logistic-Regression/blob/main/Screenshot%202025-04-07%20at%204.38.41%20in%20the%20afternoon.png)

---

### 💡 Business Implications

- 🚀 **Boost Website Traffic**: Moderate traffic volumes (11–100 visitors) correlate strongly with advocacy.
- 🛠 **Deliver Excellent Customer Care**: Ratings below "Excellent" significantly reduce the odds of advocacy.
- 🌐 **Emphasize Website Value**: Customers who view their websites as “Very Important” are more likely to recommend GoDaddy.
