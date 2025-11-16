/* 1. INNER JOIN → Patients with their Appointments */
SELECT p.patient_id, p.full_name, a.appointment_date, a.doctor_id
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id;

/* 2. INNER JOIN → Doctors with their Departments */
SELECT d.doctor_name, dept.department_name
FROM doctors d
INNER JOIN departments dept ON d.department_id = dept.department_id;

/* 3. INNER JOIN → Bills with Patients */
SELECT b.bill_id, p.full_name, b.total_amount
FROM bills b
JOIN patients p ON b.patient_id = p.patient_id;

/* 4. LEFT JOIN → All Patients & Their Prescriptions (even if none) */
SELECT p.full_name, pr.medicine_name
FROM patients p
LEFT JOIN prescriptions pr ON p.patient_id = pr.patient_id;

/* 5. RIGHT JOIN → Rooms with assigned patients */
SELECT r.room_number, p.full_name
FROM patients p
RIGHT JOIN rooms r ON p.room_id = r.room_id;

/* 6. FULL JOIN (Use UNION for MySQL) */
SELECT p.patient_id, p.full_name, a.appointment_date
FROM patients p LEFT JOIN appointments a ON p.patient_id = a.patient_id
UNION
SELECT p.patient_id, p.full_name, a.appointment_date
FROM patients p RIGHT JOIN appointments a ON p.patient_id = a.patient_id;

/* 7. SELF JOIN → Employees who report to a manager */
SELECT e.employee_name AS Employee, m.employee_name AS Manager
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id;

/* 8. CROSS JOIN → All doctor-room combinations */
SELECT d.doctor_name, r.room_number
FROM doctors d
CROSS JOIN rooms r;

/* 9. Patients with their doctor name via appointment */
SELECT p.full_name, d.doctor_name, a.appointment_date
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

/* 10. Medicines issued by pharmacists */
SELECT pr.medicine_name, ph.pharmacist_name
FROM prescriptions pr
JOIN pharmacists ph ON pr.pharmacist_id = ph.pharmacist_id;

/* 11. Multiple JOIN – Billing with Doctor & Patient */
SELECT b.bill_id, p.full_name, d.doctor_name, b.total_amount
FROM bills b
JOIN patients p ON b.patient_id = p.patient_id
JOIN doctors d ON b.doctor_id = d.doctor_id;

/* 12. Test results with patients and lab */
SELECT p.full_name, t.test_type, l.lab_name
FROM lab_tests t
JOIN patients p ON t.patient_id = p.patient_id
JOIN labs l ON t.lab_id = l.lab_id;

/* 13. LEFT JOIN – Patients without emergency contact */
SELECT p.full_name, ec.contact_name
FROM patients p
LEFT JOIN emergency_contacts ec ON p.patient_id = ec.patient_id
WHERE ec.contact_name IS NULL;

/* 14. RIGHT JOIN – Surgeries with/without assigned doctors */
SELECT s.surgery_name, d.doctor_name
FROM surgeries s
RIGHT JOIN doctors d ON s.doctor_id = d.doctor_id;

/* 15. JOIN – Nurses assigned to room */
SELECT n.nurse_name, r.room_number
FROM nurses n
JOIN rooms r ON n.room_id = r.room_id;

/* 16. JOIN – Appointments with payment status */
SELECT p.full_name, pay.status
FROM appointments a
JOIN payments pay ON a.appointment_id = pay.appointment_id
JOIN patients p ON a.patient_id = p.patient_id;

/* 17. JOIN – Patients & Insurance Providers */
SELECT p.full_name, i.provider_name
FROM insurance i
JOIN patients p ON i.patient_id = p.patient_id;

/* 18. JOIN – Doctors & Shifts */
SELECT d.doctor_name, s.shift_time
FROM doctors d
JOIN doctor_shifts s ON d.doctor_id = s.doctor_id;

/* 19. JOIN – Wards with patients in them */
SELECT w.ward_name, p.full_name
FROM wards w
LEFT JOIN patients p ON w.ward_id = p.ward_id;

/* 20. JOIN – Appointments with diagnosis */
SELECT p.full_name, dg.diagnosis_details
FROM appointments a
JOIN diagnosis dg ON a.appointment_id = dg.appointment_id
JOIN patients p ON a.patient_id = p.patient_id;




/* 1. Scalar subquery → Patients with above-avg bill */
SELECT p.full_name, b.total_amount
FROM bills b
JOIN patients p ON b.patient_id = p.patient_id
WHERE b.total_amount > (SELECT AVG(total_amount) FROM bills);

/* 2. IN → Doctors who performed surgeries */
SELECT doctor_id, doctor_name
FROM doctors
WHERE doctor_id IN (SELECT doctor_id FROM surgeries);

/* 3. EXISTS → Patients who have prescriptions */
SELECT full_name
FROM patients p
WHERE EXISTS (SELECT 1 FROM prescriptions pr WHERE pr.patient_id = p.patient_id);

/* 4. Subquery in FROM → Highest 5 billing patients */
SELECT full_name, total_amount
FROM (
    SELECT p.full_name, b.total_amount
    FROM bills b JOIN patients p ON b.patient_id = p.patient_id
    ORDER BY b.total_amount DESC LIMIT 5
) AS t;

/* 5. ANY → Doctors charging more than ANY surgeon */
SELECT doctor_name, consultation_fee
FROM doctors
WHERE consultation_fee > ANY(SELECT fee FROM surgeons);

/* 6. ALL → Rooms with capacity greater than ALL ward capacities */
SELECT room_number
FROM rooms
WHERE capacity > ALL(SELECT ward_capacity FROM wards);

/* 7. Correlated → Patients with multiple bills */
SELECT p.full_name
FROM patients p
WHERE 2 <= (
    SELECT COUNT(*)
    FROM bills b
    WHERE b.patient_id = p.patient_id
);

/* 8. Subquery → Most booked doctor */
SELECT doctor_name
FROM doctors
WHERE doctor_id = (
    SELECT doctor_id
    FROM appointments
    GROUP BY doctor_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

/* 9. Patients who took more than 3 tests */
SELECT patient_id
FROM lab_tests
GROUP BY patient_id
HAVING COUNT(test_id) > 3;

/* 10. Patients having a surgery */
SELECT full_name
FROM patients
WHERE patient_id IN (SELECT patient_id FROM surgeries);

/* 11. Employees paid above their department avg */
SELECT employee_name
FROM employees e
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
);

/* 12. Most expensive medicine */
SELECT medicine_name
FROM medicines
WHERE price = (SELECT MAX(price) FROM medicines);

/* 13. Doctors with no appointments */
SELECT doctor_name
FROM doctors
WHERE doctor_id NOT IN (SELECT doctor_id FROM appointments);

/* 14. Subquery for occupied rooms */
SELECT room_number
FROM rooms
WHERE room_id IN (SELECT room_id FROM patients);

/* 15. Patients admitted in largest ward */
SELECT full_name
FROM patients
WHERE ward_id = (SELECT ward_id FROM wards ORDER BY ward_capacity DESC LIMIT 1);

/* 16. Labs that performed more tests than avg */
SELECT lab_name
FROM labs
WHERE lab_id IN (
    SELECT lab_id
    FROM lab_tests
    GROUP BY lab_id
    HAVING COUNT(test_id) > (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM lab_tests GROUP BY lab_id) AS x)
);

/* 17. Doctors charging top 10% fees */
SELECT doctor_name
FROM doctors
WHERE consultation_fee > (
    SELECT 0.9 * MAX(consultation_fee) FROM doctors
);

/* 18. Find oldest patient */
SELECT full_name
FROM patients
WHERE dob = (SELECT MIN(dob) FROM patients);

/* 19. Appointments in last 7 days */
SELECT *
FROM appointments
WHERE appointment_date >= (SELECT CURDATE() - INTERVAL 7 DAY);

/* 20. Subquery → Patients prescribed antibiotics */
SELECT full_name
FROM patients
WHERE patient_id IN (
    SELECT patient_id FROM prescriptions WHERE medicine_name LIKE '%biotic%'
);




/* 1. Uppercase patient names */
SELECT UPPER(full_name) FROM patients;

/* 2. Lowercase doctor emails */
SELECT LOWER(email) FROM doctors;

/* 3. Round bill amount */
SELECT bill_id, ROUND(total_amount) FROM bills;

/* 4. Calculate patient age */
SELECT full_name, TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age FROM patients;

/* 5. Month-wise appointments */
SELECT MONTH(appointment_date) AS month, COUNT(*) AS total
FROM appointments
GROUP BY month;

/* 6. Concatenate doctor name & department */
SELECT CONCAT(d.doctor_name, ' - ', dept.department_name) AS doctor_info
FROM doctors d JOIN departments dept ON d.department_id = dept.department_id;

/* 7. Get today’s admitted patients */
SELECT full_name FROM patients WHERE admission_date = CURDATE();

/* 8. Get minimum consultation fee */
SELECT MIN(consultation_fee) AS MinFee FROM doctors;

/* 9. Average medicine cost */
SELECT AVG(price) FROM medicines;

/* 10. Total billing amount */
SELECT SUM(total_amount) FROM bills;




/* 1. Annual Salary Function */
CREATE FUNCTION GetAnnualSalary(monthly DECIMAL(10,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
RETURN monthly * 12;

/* USE */
SELECT employee_name, GetAnnualSalary(salary) AS yearly_salary FROM employees;

/* 2. Patient Age Calculator */
CREATE FUNCTION PatientAge(dob DATE)
RETURNS INT
DETERMINISTIC
RETURN TIMESTAMPDIFF(YEAR, dob, CURDATE());

/* USE */
SELECT full_name, PatientAge(dob) FROM patients;

/* 3. Calculate GST on billing */
CREATE FUNCTION BillGST(amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN amount * 0.18;

/* USE */
SELECT bill_id, BillGST(total_amount) AS gst FROM bills;

/* 4. Total medicine cost per prescription */
CREATE FUNCTION MedicineCost(price DECIMAL(10,2), qty INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN price * qty;

/* USE */
SELECT pr.prescription_id, MedicineCost(m.price, pr.quantity)
FROM prescriptions pr JOIN medicines m ON pr.medicine_id = m.medicine_id;

/* 5. FullName Formatter */
CREATE FUNCTION MakeFullName(f VARCHAR(50), l VARCHAR(50))
RETURNS VARCHAR(120)
DETERMINISTIC
RETURN CONCAT(f, ' ', l);

/* USE */
SELECT MakeFullName(first_name, last_name) FROM staff;
