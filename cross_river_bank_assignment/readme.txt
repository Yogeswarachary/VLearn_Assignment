# Fraud Detection and Risk Analysis in Cross River Bank 🚀

## Objective

#### To analyze structured and unstructured data independently to identify loan fraud, assess customer 
risk, and understand customer behavior. This case study focuses on the loan and transaction data 
of Cross River Bank, leveraging MySQL and MongoDB for a comprehensive analysis.

### Problem Statement

Cross River Bank, a U.S.-based financial institution, faces challenges in detecting fraudulent 
activities and assessing customer risk effectively. With an increasing volume of loans and 
transactions, traditional manual methods are insufficient. The bank requires an automated system 
to analyze both structured data (e.g., customer, loan, and transaction data) and unstructured data 
(e.g., customer feedback, behavior logs) to identify patterns of fraud, optimize lending policies, and 
improve customer satisfaction. 

### Files Included for Analysis

The following files contain structured and unstructured data used for this case study: 
1. Customer Table (CSV): Includes customer details such as ID, name, age, income, credit 
score, and address. 
2. Loan Table (CSV): Contains loan information, including loan ID, customer ID, loan amount, 
purpose, and default risk. 
3. Transaction Table (CSV): Details transactions related to loans, including transaction type, 
amount, and date. 
4. Behavior Logs (JSON): Captures customer activities such as login, missed payments, and 
early repayments. 
5. Customer Feedback (JSON): Includes feedback from customers, sentiment scores, 
escalation flags, and feedback categories.

#### Note: Customer_table, there is one specific column which is called "address", which can hold the customer's address details. For finding customers state/city/region, I used the Substring Negative index function to split 'state/city/region code' and that is stored in the new column called 'state_code', and named this table as 'copy_customer_table', while keeping the original customer_table. Some of the queries(one or two queries) are written using this 'copy_customer_table'.
