-- Task1: Use logical mapping to add employee_id to the Training Programs dataset by matching department_id and 
-- employee_name from the Employee Details dataset.

select ed.employeeid, tpc.* from employee_details as ed
join training_programs_copy as tpc on
ed.employeename = tpc.employeename and
ed.department_id = tpc.department_id order by ed.employeeid asc;

-- Task2: Analysis Tasks 

-- 1. Employee Productivity Analysis: Identify employees with the highest total hours worked and least absenteeism.
select ed.employeeid, ed.employeename, ed.job_title, sum(ar.total_hours) as Total_Working_Hours,
sum(ar.days_absent) less_absent_count from employee_details as ed join attendance_records as ar on ed.employeeid = ar.employeeid
group by ed.employeeid, ed.employeename, ed.job_title order by Total_working_hours desc, less_absent_count asc limit 50;

-- 2. Departmental Training Impact: Analyze how training programs improve departmental performance.
select tp.department_id, count(tp.program_id) as total_training_programs, round(avg(tp.feedback_score),3) as average_feedback_score,
sum(case when tp.certificate_awarded='Yes' then 1 else 0 end) as total_certificate_awarded,
round(avg(case when ed.performance_score in ('Excellent','Good') then 1 else 0 end),3) as average_performance_score
from training_programs as tp join employee_details as ed on tp.employeeid = ed.employeeid
group by tp.department_id order by average_performance_score desc;

-- 3. Project Budget Efficiency: Evaluate the efficiency of project budgets by calculating costs per hour worked.
select project_id, project_name, budget, hours_worked, budget/hours_worked as cost_per_hour_worked 
from project_assignments order by cost_per_hour_worked asc;

-- 4. Attendance Consistency: Measure attendance trends and identify departments with significant deviations.
select ed.department_id, round(avg(ar.days_present),2) as average_days_present,
round(avg(ar.days_absent),2) as average_days_absent, round(avg(ar.late_check_ins),2) as average_late_checkins, 
round(avg(ar.sick_leaves),2) as average_sick_leaves, round(avg(ar.vacation_leaves),2) average_vacation_leaves 
from employee_details as ed join attendance_records as ar on ed.employeeid = ar.employeeid
group by ed.department_id order by ed.department_id asc;

-- 5. Training and Project Success Correlation: Link training technologies with project milestones to assess the real-world impact of training.
select pa.project_name, tp.technologies_covered, round(avg(pa.milestones_achieved),2) as average_milestones_achieved
from project_assignments as pa join training_programs as tp on pa.employeeid = tp.employeeid
where tp.certificate_awarded = 'Yes' and tp.completion_status = 'Completed'
group by pa.project_name ,tp.technologies_covered order by average_milestones_achieved desc;

-- 6. High-Impact Employees: Identify employees who significantly contribute to high-budget projects while maintaining excellent performance scores.
select ed.employeeid, ed.employeename, ed.performance_score, pa.project_name, pa.hours_worked, pa.milestones_achieved, pa.budget
from employee_details as ed join project_assignments as pa on ed.employeeid = pa.employeeid
where ed.performance_score = 'Excellent' and pa.budget > (select avg(budget) from project_assignments) order by pa.budget desc;

-- 7. Cross Analysis of Training and Project Success: 
#  Identify employees who have undergone training in specific technologies and contributed to high performing projects using those technologies. 
select distinct tp.employeename, tp.program_name, tp.technologies_covered, pa.project_status, ed.performance_score, pa.technologies_used
from training_programs as tp join project_assignments as pa on tp.employeeid = pa.employeeid
join employee_details as ed on pa.employeeid = ed.employeeid where pa.project_status = 'Completed' and tp.completion_status = 'Completed' 
and tp.certificate_awarded = 'Yes' and ed.performance_score = 'Excellent' and tp.technologies_covered = pa.technologies_used
order by tp.employeename, tp.program_name;

select distinct tp.employeename, tp.program_name, tp.technologies_covered, pa.project_status, ed.performance_score, pa.technologies_used
from training_programs as tp join project_assignments as pa on tp.employeeid = pa.employeeid
join employee_details as ed on pa.employeeid = ed.employeeid where pa.project_status = 'Completed' and tp.completion_status = 'Completed' 
and tp.certificate_awarded = 'Yes' and ed.performance_score = 'Excellent' order by tp.employeename, tp.program_name;
