/*  
=======================================================
 PHASE–2 : SQL QUERY MASTERY  
 Hospital Management System
 By: SHRUTI TIWARI  
=======================================================
*/

/* ----------------------------------------------------
   1️ DDL QUERIES (20 QUERIES)
---------------------------------------------------- */

-- 1. Create a new table for hospital branches
CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    location VARCHAR(100)
);

-- 2. Add a new column to doctors
ALTER TABLE doctors ADD COLUMN qualification VARCHAR(50);

-- 3. Modify datatype of patient phone number
ALTER TABLE patients MODIFY phone VARCHAR(15);

-- 4. Drop an unwanted column in nurses table
ALTER TABLE nurses DROP COLUMN temporary_address;

-- 5. Rename table billing → payments
RENAME TABLE billing TO payments;

-- 6. Create table with CHECK constraint
CREATE TABLE insurance (
    insurance_id INT PRIMARY KEY,
    patient_id INT,
    provider VARCHAR(100),
    amount DECIMAL(10,2) CHECK (amount > 0)
);

-- 7. Add FOREIGN KEY with ON DELETE CASCADE
ALTER TABLE insurance 
ADD CONSTRAINT fk_insurance_patient
FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
ON DELETE CASCADE;

-- 8. Create table for surgeries
CREATE TABLE surgeries (
    surgery_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    surgery_date DATE,
    type VARCHAR(50)
);

-- 9. Truncate table
TRUNCATE TABLE test_results;

-- 10. Drop table
DROP TABLE emergency_cases;

-- 11. Add UNIQUE constraint to doctors
ALTER TABLE doctors ADD CONSTRAINT unique_email UNIQUE(email);

-- 12. Drop UNIQUE constraint  
ALTER TABLE doctors DROP INDEX unique_email;

-- 13. Add NOT NULL constraint  
ALTER TABLE rooms MODIFY status VARCHAR(20) NOT NULL;

-- 14. Add DEFAULT constraint  
ALTER TABLE staff ADD COLUMN active_status VARCHAR(10) DEFAULT 'Active';

-- 15. Table with ON UPDATE CASCADE
CREATE TABLE department_heads (
    dept_id INT PRIMARY KEY,
    head_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON UPDATE CASCADE
);

-- 16. Rename column age → patient_age
ALTER TABLE patients RENAME COLUMN age TO patient_age;

-- 17. Add multiple columns in medicines
ALTER TABLE medicines 
ADD COLUMN expiry_date DATE,
ADD COLUMN stock INT;

-- 18. Create a backup table
CREATE TABLE patients_backup AS SELECT * FROM patients;

-- 19. Create a view
CREATE VIEW doctor_overview AS
SELECT doctor_id, doctor_name, specialization FROM doctors;

-- 20. Drop view
DROP VIEW doctor_overview;


/* ----------------------------------------------------
   2️ DML QUERIES (20 QUERIES)
---------------------------------------------------- */

-- 1. Insert new doctor
INSERT INTO doctors (doctor_id, doctor_name, specialization) 
VALUES (201, 'Dr. Aditi Rao', 'Dermatology');

-- 2. Insert multiple patients
INSERT INTO patients (patient_id, name, gender, phone, patient_age) VALUES
(501, 'Ravi Kumar', 'Male', '9876543210', 45),
(502, 'Megha Roy', 'Female', '9785632410', 32);

-- 3. Update doctor specialization
UPDATE doctors SET specialization = 'Cardiology' WHERE doctor_id = 201;

-- 4. Delete a patient
DELETE FROM patients WHERE patient_id = 501;

-- 5. Increase nurse salary (arithmetic operator)
UPDATE nurses SET salary = salary * 1.10;

-- 6. Mark ICU rooms as occupied
UPDATE rooms SET status = 'Occupied' 
WHERE room_type = 'ICU';

-- 7. Reduce medicine stock
UPDATE medicines SET stock = stock - 5 WHERE medicine_id = 10;

-- 8. Delete old prescriptions
DELETE FROM prescriptions WHERE issue_date < '2024-01-01';

-- 9. Increase test cost
UPDATE lab_tests SET cost = cost + (cost * 0.05);

-- 10. Insert admission
INSERT INTO admissions (admission_id, patient_id, doctor_id, room_id) 
VALUES (301, 502, 201, 5);

-- 11. Delete inactive staff
DELETE FROM staff WHERE active_status = 'Inactive';

-- 12. Update doctor phone numbers
UPDATE doctors SET phone = REPLACE(phone, '0', '9');

-- 13. Insert new room
INSERT INTO rooms VALUES (40, 'General', 'Available');

-- 14. Update patient address
UPDATE patients SET address = 'Delhi' WHERE patient_id = 502;

-- 15. Delete test results by patient
DELETE FROM test_results WHERE patient_id = 502;

-- 16. Insert departments
INSERT INTO departments VALUES
(21, 'Neurology'), (22, 'Oncology');

-- 17. Update payment status
UPDATE payments SET status = 'Paid' WHERE payment_id = 1001;

-- 18. Delete missed appointments
DELETE FROM appointments WHERE appointment_date < CURDATE();

-- 19. Increase doctor fee
UPDATE doctors SET fee = fee + 200;

-- 20. Insert new nurse
INSERT INTO nurses VALUES (301, 'Priya Sharma', 'Night Shift', 25000);


/* ----------------------------------------------------
   3️ DQL QUERIES (20 QUERIES)
---------------------------------------------------- */

-- 1. Show all patients
SELECT * FROM patients;

-- 2. Doctors in cardiology
SELECT doctor_name FROM doctors WHERE specialization = 'Cardiology';

-- 3. Patients older than 40
SELECT name, patient_age FROM patients WHERE patient_age > 40;

-- 4. Available rooms
SELECT room_id FROM rooms WHERE status = 'Available';

-- 5. Total doctors (aggregation)
SELECT COUNT(*) AS TotalDoctors FROM doctors;

-- 6. Average nurse salary
SELECT AVG(salary) AS AvgSalary FROM nurses;

-- 7. Highest test cost
SELECT MAX(cost) AS HighestCost FROM lab_tests;

-- 8. Today's admissions
SELECT * FROM admissions WHERE admission_date = CURDATE();

-- 9. Appointment list sorted
SELECT * FROM appointments ORDER BY appointment_date DESC;

-- 10. Doctors earning above 50k
SELECT doctor_name, fee FROM doctors WHERE fee > 50000;

-- 11. Group patients by gender
SELECT gender, COUNT(*) FROM patients GROUP BY gender;

-- 12. HAVING clause – departments with > 5 doctors
SELECT d.dept_id, COUNT(*) AS TotalDocs
FROM doctors dr
JOIN departments d ON dr.dept_id = d.dept_id
GROUP BY d.dept_id
HAVING COUNT(*) > 5;

-- 13. Medicine stock between range
SELECT * FROM medicines WHERE stock BETWEEN 10 AND 50;

-- 14. Search by name
SELECT * FROM patients WHERE name LIKE 'S%';

-- 15. Column alias
SELECT doctor_name AS Name, specialization AS Field FROM doctors;

-- 16. Join with table alias
SELECT p.name, d.doctor_name, a.appointment_date
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id;

-- 17. Total revenue
SELECT SUM(amount) AS TotalRevenue FROM payments;

-- 18. Tests by patient
SELECT t.test_name, r.result
FROM test_results r
JOIN lab_tests t ON r.test_id = t.test_id
WHERE r.patient_id = 502;

-- 19. Top 5 earning doctors
SELECT doctor_name, fee FROM doctors ORDER BY fee DESC LIMIT 5;

-- 20. Count surgeries by type
SELECT type, COUNT(*) FROM surgeries GROUP BY type;
