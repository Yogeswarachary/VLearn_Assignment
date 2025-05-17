/* 1. Customer Risk Analysis: Identify customers with low credit scores and high-risk loans to predict 
potential defaults and prioritize risk mitigation strategies. */

# As per Indian Cibil Score Norms "If a Person have below 700 Cibil score, those people hardly get Loans from banks".
select * from customer_table where credit_score < 700 order by credit_score asc;

/* 2. Loan Purpose Insights: Determine the most popular loan purposes and their associated 
revenues to align financial products with customer demands. */

select loan_purpose, count(*) as total_count, sum((loan_amount/100)*interest_rate) as loan_revenue from loan_table
group by loan_purpose order by loan_revenue desc limit 1;

/* 3. High-Value Transactions: Detect transactions that exceed 30% of their respective loan amounts 
to flag potential fraudulent activities. */
select tt.customer_id, tt.loan_id, tt.transaction_amount,
lt.loan_amount as above_30_percent_loan_amount from transaction_table as tt left join loan_table as lt
on tt.loan_id = lt.loan_id group by tt.customer_id, tt.loan_id, tt.transaction_amount,
lt.loan_amount having tt.transaction_amount > ((loan_amount/100)*30)
order by tt.customer_id asc;

/* 4. Missed EMI Count: Analyze the number of missed EMIs per loan to identify loans at risk of 
default and suggest intervention strategies. */
select transaction_type, loan_id, count(*) as count_of_missed_EMI_per_loan_id from transaction_table
where transaction_type = 'Missed EMI' group by loan_id order by count(loan_id) desc limit 129;

/* 5. Regional Loan Distribution: Examine the geographical distribution of loan disbursements to 
assess regional trends and business opportunities. */

-- Add a Copy Customer table. In that add new column called state_code
ALTER TABLE copy_customer_table ADD COLUMN state_code VARCHAR(30);

/* then do the sub-string index from address -2, then store result in the
new column called state_code */
SET SQL_SAFE_UPDATES = 0;  -- Disable safe mode - need to Run First
UPDATE copy_customer_table 
SET state_code = SUBSTRING_INDEX(address, ' ', -2);
SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe mode - Need to Run after updating the Table

-- Actual Query
select cct.state_code as Loan_approval_per_state, count(lt.loan_id) as approved_loan_count
from copy_customer_table as cct right join loan_table as lt on cct.customer_id = lt.customer_id
where lt.loan_status = 'Approved' group by cct.state_code
order by approved_loan_count desc;

/* 6. Loyal Customers: List customers who have been associated with Cross River Bank for over five 
years and evaluate their loan activity to design loyalty programs. */

# Sub Tasks before running Actual Query

# Add a New Column
alter table customer_table add customer_since_date date;

SET SQL_SAFE_UPDATES = 0; -- Disable safe mode - need to Run First

# Converting the customer_since column to proper date format and that is added to customer_since_column
update customer_table
set customer_since_date = str_to_date(customer_since, "%c/%e/%Y");

SET SQL_SAFE_UPDATES = 1; -- Re-enable safe mode - Need to Run after updating the Table

# Cheking the New column is actually having the data in Date type
select customer_since_date from customer_table where customer_since_date > date_sub(curdate(), interval 3 year)
order by customer_since_date asc;

# Removing the old column which is having the text data instead of date type
alter table customer_table drop customer_since;
alter table customer_table;

# Renaming the column from cusomter_since_date to customer_since
alter table customer_table
change customer_since_date customer_since date;

# Now checking the logic based example which works or not
select customer_since as loyal_cust from customer_table where customer_since > date_sub(curdate(), interval 3 year)
order by customer_since asc;

# Actual Query
select ct.customer_id,ct.name, ct.phone, ct.email,ct.customer_since, lt.loan_status as loan_activity from customer_table as ct left join loan_table as lt
on ct.customer_id = lt.customer_id where customer_since > date_sub(curdate(), interval 5 year) and 
loan_status not in ('Closed','Rejected');

/*select ct.customer_id,ct.name, ct.phone, ct.email,ct.customer_since, lt.loan_status as loan_activity from customer_table as ct left join loan_table as lt
on ct.customer_id = lt.customer_id where customer_since > date_sub(curdate(), interval 5 year); */

/* 7. High-Performing Loans: Identify loans with excellent repayment histories to refine lending 
policies and highlight successful products. */

select ct.customer_id, ct.name, lt.loan_id, tt.remarks as repayment_update, round(sum((loan_amount/100)*interest_rate),2) as max_revenue
from customer_table as ct left join loan_table as lt
on ct.customer_id = lt.customer_id
left join transaction_table as tt on
lt.loan_id = tt.loan_id where tt.status = 'Successful' and tt.remarks = 'On-time payment.'
group by ct.customer_id, ct.name, lt.loan_id, tt.remarks order by max_revenue desc;

/* 8. Age-Based Loan Analysis: Analyze loan amounts disbursed to customers of different age groups 
to design targeted financial products. */
select case
when ct.age between 18 and 25 then '18-25 age group'
when ct.age between 26 and 40 then '26-40 age group'
when ct.age between 41 and 55 then '41-55 age group'
when ct.age between 56 and 70 then '56-70 age group'
when ct.age > 70 then '70+ age group'
else 'unknown' end as diff_age_groups,
count(*) as num_of_loans, sum(lt.loan_amount) as total_loan_amounts
from customer_table as ct join loan_table as lt
on ct.customer_id = lt.customer_id
group by diff_age_groups order by diff_age_groups asc;

/* 9. Seasonal Transaction Trends: Examine transaction patterns over years and months to identify 
seasonal trends in loan repayments. */

# Update data type of the columnSET SQL_SAFE_UPDATES = 0;

SET SQL_SAFE_UPDATES = 0;
alter table transaction_table add column transaction_new_date datetime;

update transaction_table
set transaction_new_date = str_to_date(transaction_date, '%c/%e/%Y %H:%i:%s');

alter table transaction_table
drop transaction_date;

alter table transaction_table
change transaction_new_date transaction_date Datetime;
SET SQL_SAFE_UPDATES = 1;

# Actual Query
select count(*) as num_of_transactions, year(transaction_date),
month(transaction_date), sum(transaction_amount) as total_value_of_transactions
from transaction_table group by year(transaction_date), month(transaction_date)
order by year(transaction_date) desc, month(transaction_date) desc;

/* 10. Repayment History Analysis: Rank loans by repayment performance using window functions.*/

select loan_summary.loan_id, loan_summary.loan_amount, total_paid, repayment_ratio,
rank() over(order by repayment_ratio desc) as repayment_rank
from (select lt.loan_id, lt.loan_amount,
sum(tt.transaction_amount) as total_paid, 
sum(tt.transaction_amount)/lt.loan_amount as repayment_ratio
from loan_table as lt left join transaction_table as tt
on lt.loan_id = tt.loan_id
where tt.transaction_type = 'EMI Payment' and status = 'Successful'
group by lt.loan_id, lt.loan_amount)as loan_summary;

/* 11. Credit Score vs. Loan Amount: Compare average loan amounts for different credit score ranges. */
select case
when ct.credit_score between 300 and 450 then 'poor credit score (300-450)'
when ct.credit_score between 451 and 550 then 'below average credit score (451-550)'
when ct.credit_score between 551 and 650 then 'average credit score (551-650)'
when ct.credit_score between 651 and 750 then 'Good credit score (651-750)'
when ct.credit_score between 751 and 850 then 'Excellent credit score (751-850)'
when ct.credit_score > 850 then 'outstanding credit score'
else 'uknown' end as credit_score_range,
round(avg(lt.loan_amount),2) as average_loan_amount
from  customer_table as ct join loan_table as lt
on ct.customer_id = lt.customer_id
group by credit_score_range order by case
when credit_score_range = 'poor credit score (300-450)' then 1
when credit_score_range = 'below average credit score (451-550)' then 2
when credit_score_range = 'average credit score (551-650)' then 3
when credit_score_range = 'Good credit score (651-750)' then 4
when credit_score_range = 'Excellent credit score (751-850)' then 5
when credit_score_range = 'outstanding credit score (>850)' then 6
else 7 end;

/* 12. Top Borrowing Regions: Identify regions with the highest total loan disbursements.*/

select cct.state_code as loan_approval_state_or_region, 
count(lt.loan_id) as approved_loan_count,
max(lt.loan_amount) as max_loan_amount 
from copy_customer_table as cct join loan_table as lt
on cct.customer_id = lt.loan_id where lt.loan_status = 'Approved' 
group by loan_approval_state_or_region
order by approved_loan_count desc;

/* 13. Early Repayment Patterns: Detect loans with frequent early repayments and their impact on 
revenue.*/

select lt.loan_id, lt.loan_amount, count(tt.transaction_id) as total_prepayment_count,
sum(tt.transaction_amount) as total_prepayment_amount,
round((lt.loan_amount*lt.interest_rate/100),2) as expected_revenue,
round(case when count(tt.transaction_id) > 0 then (lt.loan_amount*lt.interest_rate/100)*0.5
else (lt.loan_amount*lt.interest_rate/100) end,2) as estimated_revenue
from loan_table as lt left join transaction_table as tt
on lt.customer_id = tt.customer_id
and tt.transaction_type='Prepayment' and tt.status='Successful' and tt.remarks = 'On-time payment.'
group by lt.loan_id, lt.loan_amount, lt.interest_rate 
having total_prepayment_count > 0 order by total_prepayment_amount desc;

