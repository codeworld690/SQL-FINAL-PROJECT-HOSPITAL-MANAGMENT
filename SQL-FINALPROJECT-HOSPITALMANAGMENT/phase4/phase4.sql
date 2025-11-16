/* ======================================================
   PHASE-4 : ADVANCED DATABASE CONCEPTS
   Hospital Management System
   By: Shruti Tiwari
   Single SQL script: Views, Cursors, Stored Procedures,
   Window Functions, DCL/TCL, Triggers
   ====================================================== */

/* ---------------------------
   ASSUMPTIONS / NOTES
   ---------------------------
   - Database: hospital_db
   - Core tables from Phase-1 exist: patients, doctors, appointments,
     departments, rooms, admissions, nurses, payments, prescriptions,
     lab_tests, test_results, medicines, staff, surgeries, etc.
   - This script uses MySQL syntax (adjust for other engines).
*/

/* ======================================================
   SECTION A: VIEWS
   - Create simple, joined and aggregated views
   ====================================================== */

-- 1) View: Active Patients (currently admitted)
CREATE OR REPLACE VIEW view_active_patients AS
SELECT a.admission_id, p.patient_id, p.name AS patient_name, a.admit_date, a.room_id
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
WHERE a.discharge_date IS NULL;

-- 2) View: Doctor Overview (basic)
CREATE OR REPLACE VIEW view_doctor_overview AS
SELECT d.doctor_id, d.doctor_name, d.specialization, de.dept_name
FROM doctors d
LEFT JOIN departments de ON d.dept_id = de.dept_id;

-- 3) View: PatientBillingSummary (aggregated payments per patient)
CREATE OR REPLACE VIEW view_patient_billing_summary AS
SELECT p.patient_id, p.name,
       COALESCE(SUM(pay.amount),0) AS total_paid,
       COUNT(pay.payment_id) AS payments_count
FROM patients p
LEFT JOIN payments pay ON p.patient_id = pay.patient_id
GROUP BY p.patient_id, p.name;

-- 4) View: DoctorEarnings (by month)
CREATE OR REPLACE VIEW view_doctor_earnings_monthly AS
SELECT d.doctor_id, d.doctor_name,
       YEAR(pay.payment_date) AS yr, MONTH(pay.payment_date) AS mon,
       SUM(pay.amount) AS monthly_revenue
FROM doctors d
JOIN payments pay ON pay.doctor_id = d.doctor_id
GROUP BY d.doctor_id, YEAR(pay.payment_date), MONTH(pay.payment_date);

-- 5) View: LowStockMedicines
CREATE OR REPLACE VIEW view_low_stock_medicines AS
SELECT medicine_id, medicine_name, stock
FROM medicines
WHERE stock < 20;

-- 6) View: PendingAppointments (future & pending)
CREATE OR REPLACE VIEW view_pending_appointments AS
SELECT a.appointment_id, p.name AS patient_name, d.doctor_name, a.appointment_date, a.status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE a.status = 'Pending' AND a.appointment_date >= CURDATE();

-- 7) View: TestResultsSummary per patient
CREATE OR REPLACE VIEW view_test_results_summary AS
SELECT r.patient_id, p.name,
       COUNT(r.result_id) AS total_tests,
       MAX(r.result_date) AS last_test_date
FROM test_results r
JOIN patients p ON r.patient_id = p.patient_id
GROUP BY r.patient_id, p.name;

-- 8) View: RoomOccupancy (rooms with current patient)
CREATE OR REPLACE VIEW view_room_occupancy AS
SELECT r.room_id, r.room_type, r.status, a.patient_id
FROM rooms r
LEFT JOIN admissions a ON r.room_id = a.room_id AND a.discharge_date IS NULL;

-- 9) View: PrescriptionDetails (joined)
CREATE OR REPLACE VIEW view_prescription_details AS
SELECT pr.prescription_id, pr.patient_id, p.name AS patient_name,
       pr.issue_date, m.medicine_name, pm.dosage, pm.duration
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.patient_id
JOIN prescription_medicines pm ON pr.prescription_id = pm.prescription_id
JOIN medicines m ON pm.medicine_id = m.medicine_id;

-- 10) View: SurgerySchedule
CREATE OR REPLACE VIEW view_surgery_schedule AS
SELECT s.surgery_id, s.surgery_date, s.type, p.name AS patient_name, d.doctor_name
FROM surgeries s
JOIN patients p ON s.patient_id = p.patient_id
JOIN doctors d ON s.doctor_id = d.doctor_id
WHERE s.surgery_date >= CURDATE();


/* ======================================================
   SECTION B: CURSORS
   - Row-by-row processing examples (MySQL)
   ====================================================== */

-- Note: MySQL requires stored routines for cursors; we'll create a stored procedure that uses a cursor.

DELIMITER $$

/* 1) Cursor: Print (SELECT) all active patients and their room ids one by one
   (Example procedure that selects and uses cursor) */
CREATE PROCEDURE proc_iterate_active_patients()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_admission_id INT;
  DECLARE v_patient_id INT;
  DECLARE v_patient_name VARCHAR(200);
  DECLARE v_room_id INT;

  DECLARE cur1 CURSOR FOR
    SELECT a.admission_id, a.patient_id, p.name, a.room_id
    FROM admissions a
    JOIN patients p ON a.patient_id = p.patient_id
    WHERE a.discharge_date IS NULL;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur1;
  read_loop: LOOP
    FETCH cur1 INTO v_admission_id, v_patient_id, v_patient_name, v_room_id;
    IF done THEN
      LEAVE read_loop;
    END IF;
    -- Example row-by-row logic: insert into audit table or print (here we insert into a simple audit)
    INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_iterate_active_patients', CONCAT('AdmID=', v_admission_id, ', PatID=', v_patient_id, ', Room=', v_room_id), NOW());
  END LOOP;
  CLOSE cur1;
END$$

/* 2) Cursor: Update low-stock medicines one-by-one (restock simulation) */
CREATE PROCEDURE proc_restock_low_medicines(IN restock_qty INT)
BEGIN
  DECLARE done2 INT DEFAULT FALSE;
  DECLARE v_med_id INT;
  DECLARE v_med_name VARCHAR(200);
  DECLARE cur2 CURSOR FOR
    SELECT medicine_id, medicine_name FROM medicines WHERE stock < 10;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;

  OPEN cur2;
  r_loop: LOOP
    FETCH cur2 INTO v_med_id, v_med_name;
    IF done2 THEN LEAVE r_loop; END IF;
    -- Update stock
    UPDATE medicines SET stock = stock + restock_qty WHERE medicine_id = v_med_id;
    INSERT INTO procedural_audit (proc_name, details, log_time)
      VALUES ('proc_restock_low_medicines', CONCAT('Restocked ', v_med_name, ' (ID=', v_med_id, ') by ', restock_qty), NOW());
  END LOOP;
  CLOSE cur2;
END$$

/* 3) Cursor: Create notifications for upcoming appointments (next 24 hours) */
CREATE PROCEDURE proc_notify_upcoming_appointments()
BEGIN
  DECLARE done3 INT DEFAULT FALSE;
  DECLARE v_app_id INT;
  DECLARE v_patient_id INT;
  DECLARE v_patient_name VARCHAR(200);
  DECLARE v_date DATETIME;
  DECLARE cur3 CURSOR FOR
    SELECT a.appointment_id, a.patient_id, p.name, a.appointment_date
    FROM appointments a
    JOIN patients p ON a.patient_id = p.patient_id
    WHERE a.appointment_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 1 DAY);

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;

  OPEN cur3;
  n_loop: LOOP
    FETCH cur3 INTO v_app_id, v_patient_id, v_patient_name, v_date;
    IF done3 THEN LEAVE n_loop; END IF;
    INSERT INTO notifications (patient_id, message, created_at)
      VALUES (v_patient_id, CONCAT('Reminder: Appointment on ', DATE_FORMAT(v_date, '%Y-%m-%d %H:%i')), NOW());
  END LOOP;
  CLOSE cur3;
END$$

/* 4) Cursor: Archive old payments older than X years (example) */
CREATE PROCEDURE proc_archive_old_payments(IN years_old INT)
BEGIN
  DECLARE done4 INT DEFAULT FALSE;
  DECLARE v_pid INT;
  DECLARE v_amount DECIMAL(10,2);
  DECLARE v_date DATE;
  DECLARE cur4 CURSOR FOR
    SELECT payment_id, amount, payment_date FROM payments WHERE payment_date < DATE_SUB(CURDATE(), INTERVAL years_old YEAR);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4 = TRUE;

  OPEN cur4;
  a_loop: LOOP
    FETCH cur4 INTO v_pid, v_amount, v_date;
    IF done4 THEN LEAVE a_loop; END IF;
    INSERT INTO payments_archive (payment_id, amount, payment_date) VALUES (v_pid, v_amount, v_date);
    DELETE FROM payments WHERE payment_id = v_pid;
  END LOOP;
  CLOSE cur4;
END$$

/* 5) Cursor: Calculate monthly average test cost per lab_test row-by-row and log */
CREATE PROCEDURE proc_calc_monthly_test_avg()
BEGIN
  DECLARE done5 INT DEFAULT FALSE;
  DECLARE v_test_id INT;
  DECLARE v_avg DECIMAL(10,2);
  DECLARE cur5 CURSOR FOR SELECT test_id FROM lab_tests;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;

  OPEN cur5;
  m_loop: LOOP
    FETCH cur5 INTO v_test_id;
    IF done5 THEN LEAVE m_loop; END IF;
    SELECT ROUND(AVG(cost),2) INTO v_avg FROM test_results WHERE test_id = v_test_id AND YEAR(result_date) = YEAR(CURDATE()) AND MONTH(result_date) = MONTH(CURDATE());
    INSERT INTO procedural_audit (proc_name, details, log_time)
      VALUES ('proc_calc_monthly_test_avg', CONCAT('TestID=', v_test_id, ', ThisMonthAvg=', IFNULL(v_avg,0)), NOW());
  END LOOP;
  CLOSE cur5;
END$$

DELIMITER ;

/* ======================================================
   SECTION C: STORED PROCEDURES & STORED LOGIC
   - Parameterized procedures, transactional procedures
   ====================================================== */

DELIMITER $$

-- 1) Procedure: Admit patient (transactional: create admission, mark room occupied, create initial billing)
CREATE PROCEDURE proc_admit_patient(
  IN in_patient_id INT,
  IN in_doctor_id INT,
  IN in_room_id INT,
  IN in_admit_date DATE
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    -- Log failure
    INSERT INTO procedural_audit (proc_name, details, log_time)
      VALUES ('proc_admit_patient', CONCAT('Failed to admit patient ', in_patient_id), NOW());
  END;

  START TRANSACTION;
    INSERT INTO admissions (patient_id, doctor_id, room_id, admit_date) 
      VALUES (in_patient_id, in_doctor_id, in_room_id, in_admit_date);
    UPDATE rooms SET status = 'Occupied' WHERE room_id = in_room_id;
    INSERT INTO payments (patient_id, amount, payment_date, status)
      VALUES (in_patient_id, 0.00, CURDATE(), 'Pending');
  COMMIT;

  -- Log success
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_admit_patient', CONCAT('Admitted patient ', in_patient_id, ' to room ', in_room_id), NOW());
END$$

-- 2) Procedure: Discharge patient (calculate bill, free room)
CREATE PROCEDURE proc_discharge_patient(IN in_admission_id INT)
BEGIN
  DECLARE v_patient INT;
  DECLARE v_room INT;
  DECLARE v_total DECIMAL(10,2);

  SELECT patient_id, room_id INTO v_patient, v_room FROM admissions WHERE admission_id = in_admission_id;
  -- simplistic billing calc: sum of payments/charges etc.
  SELECT COALESCE(SUM(amount),0) INTO v_total FROM payments WHERE patient_id = v_patient;

  START TRANSACTION;
    UPDATE admissions SET discharge_date = CURDATE() WHERE admission_id = in_admission_id;
    UPDATE rooms SET status = 'Available' WHERE room_id = v_room;
    UPDATE payments SET status = 'Paid' WHERE patient_id = v_patient AND status = 'Pending';
  COMMIT;

  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_discharge_patient', CONCAT('Discharged admission ', in_admission_id, ', Patient=', v_patient, ', TotalPaid=', v_total), NOW());
END$$

-- 3) Procedure: Update doctor fee by percentage
CREATE PROCEDURE proc_update_doctor_fee(IN pct DECIMAL(6,2))
BEGIN
  UPDATE doctors SET fee = ROUND(fee * (1 + pct/100),2);
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_update_doctor_fee', CONCAT('Updated doctor fees by ', pct, '%'), NOW());
END$$

-- 4) Procedure: Add new department + head (shows transaction)
CREATE PROCEDURE proc_add_department(IN dept_name VARCHAR(100), IN head_id INT)
BEGIN
  START TRANSACTION;
    INSERT INTO departments (dept_name) VALUES (dept_name);
    SET @last_dept_id = LAST_INSERT_ID();
    INSERT INTO department_heads (dept_id, head_id) VALUES (@last_dept_id, head_id);
  COMMIT;
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_add_department', CONCAT('Added dept ', dept_name, ' with head ', head_id), NOW());
END$$

-- 5) Procedure: Bulk insert sample patients (demonstration)
CREATE PROCEDURE proc_bulk_insert_patients()
BEGIN
  INSERT INTO patients (patient_id, name, gender, phone, patient_age)
  VALUES (601,'Aman Verma','Male','9870001111',29),
         (602,'Sana Khan','Female','9870002222',34),
         (603,'Karan Patel','Male','9870003333',52);
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_bulk_insert_patients', 'Inserted 3 sample patients', NOW());
END$$

-- 6) Procedure: Transfer patient to another room (with SAVEPOINT example)
CREATE PROCEDURE proc_transfer_room(IN in_patient_id INT, IN new_room INT)
BEGIN
  DECLARE old_room INT;
  START TRANSACTION;
    SELECT room_id INTO old_room FROM admissions WHERE patient_id = in_patient_id AND discharge_date IS NULL LIMIT 1;
    SAVEPOINT before_transfer;
    UPDATE admissions SET room_id = new_room WHERE patient_id = in_patient_id AND discharge_date IS NULL;
    UPDATE rooms SET status = 'Available' WHERE room_id = old_room;
    UPDATE rooms SET status = 'Occupied' WHERE room_id = new_room;
  COMMIT;
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_transfer_room', CONCAT('Patient ', in_patient_id, ' moved from ', old_room, ' to ', new_room), NOW());
END$$

-- 7) Procedure: Apply discount to payments of a patient
CREATE PROCEDURE proc_apply_discount(IN in_patient_id INT, IN discount_pct DECIMAL(5,2))
BEGIN
  UPDATE payments SET amount = ROUND(amount * (1 - discount_pct/100),2) WHERE patient_id = in_patient_id AND status = 'Pending';
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_apply_discount', CONCAT('Applied ', discount_pct, '% to patient ', in_patient_id), NOW());
END$$

-- 8) Procedure: Consolidate test results into summary table
CREATE PROCEDURE proc_summarize_test_results(IN in_patient_id INT)
BEGIN
  INSERT INTO test_summary (patient_id, test_count, last_test_date)
  SELECT in_patient_id, COUNT(*), MAX(result_date)
  FROM test_results WHERE patient_id = in_patient_id;
END$$

-- 9) Procedure: Refund payment (demonstrates rollback on error)
CREATE PROCEDURE proc_refund_payment(IN pay_id INT)
BEGIN
  DECLARE v_amount DECIMAL(10,2);
  SELECT amount INTO v_amount FROM payments WHERE payment_id = pay_id;
  START TRANSACTION;
    UPDATE payments SET status = 'Refunded' WHERE payment_id = pay_id;
    -- Imagine external call fails, we simulate by a condition (not executed here), rollback if needed
  COMMIT;
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_refund_payment', CONCAT('Refunded payment ', pay_id, ' amt=', v_amount), NOW());
END$$

-- 10) Procedure: Recalculate doctor ratings (example aggregated update)
CREATE PROCEDURE proc_recalc_doctor_ratings()
BEGIN
  UPDATE doctors d
  JOIN (
    SELECT doctor_id, ROUND(AVG(rating),2) AS avg_rating
    FROM reviews
    GROUP BY doctor_id
  ) rr ON d.doctor_id = rr.doctor_id
  SET d.rating = rr.avg_rating;
  INSERT INTO procedural_audit (proc_name, details, log_time)
    VALUES ('proc_recalc_doctor_ratings', 'Recalculated doctor ratings', NOW());
END$$

DELIMITER ;

/* ======================================================
   SECTION D: WINDOW FUNCTIONS (Analytical Queries)
   - Examples of ROW_NUMBER, RANK, LAG, LEAD, NTILE etc.
   ====================================================== */

-- 1) Row number of doctors by fee (global)
SELECT doctor_id, doctor_name, fee,
       ROW_NUMBER() OVER (ORDER BY fee DESC) AS rn
FROM doctors;

-- 2) Rank doctors within department by fee
SELECT doctor_id, doctor_name, dept_id, fee,
       RANK() OVER (PARTITION BY dept_id ORDER BY fee DESC) AS dept_rank
FROM doctors;

-- 3) Dense rank for patients by number of visits
SELECT patient_id, visit_count,
       DENSE_RANK() OVER (ORDER BY visit_count DESC) AS visit_rank
FROM (
  SELECT p.patient_id, COUNT(a.admission_id) AS visit_count
  FROM patients p
  LEFT JOIN admissions a ON p.patient_id = a.patient_id
  GROUP BY p.patient_id
) t;

-- 4) Lead and lag: show previous and next appointment dates per patient
SELECT appointment_id, patient_id, appointment_date,
       LAG(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date) AS prev_app,
       LEAD(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date) AS next_app
FROM appointments;

-- 5) NTILE: split doctors into quartiles by fee
SELECT doctor_id, doctor_name, fee,
       NTILE(4) OVER (ORDER BY fee) AS fee_quartile
FROM doctors;

-- 6) Moving average of test cost (last 3 results per test)
SELECT test_id, result_date, cost,
       ROUND(AVG(cost) OVER (PARTITION BY test_id ORDER BY result_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS moving_avg_3
FROM test_results;

-- 7) Cumulative revenue per day
SELECT payment_date, SUM(amount) AS daily_sum,
       SUM(SUM(amount)) OVER (ORDER BY payment_date) AS cumulative_revenue
FROM payments
GROUP BY payment_date
ORDER BY payment_date;

-- 8) Top N doctors per department using ROW_NUMBER
SELECT doctor_id, doctor_name, dept_id, fee FROM (
  SELECT d.doctor_id, d.doctor_name, d.dept_id, d.fee,
         ROW_NUMBER() OVER (PARTITION BY d.dept_id ORDER BY d.fee DESC) AS rn
  FROM doctors d
) x WHERE rn <= 3;

-- 9) Percent rank of doctors by fee
SELECT doctor_id, doctor_name, fee,
       PERCENT_RANK() OVER (ORDER BY fee) AS pct_rank
FROM doctors;

-- 10) Windowed aggregates for patient billing: average payment in last 6 payments
SELECT payment_id, patient_id, payment_date, amount,
       AVG(amount) OVER (PARTITION BY patient_id ORDER BY payment_date ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS avg_last_6
FROM payments;


/* ======================================================
   SECTION E: DCL (GRANT/REVOKE) & TCL (Transactions)
   ====================================================== */

-- DCL Examples (requires proper privileges to run)
-- 1) Grant read-only access to reporting user
GRANT SELECT ON hospital_db.* TO 'report_user'@'localhost';

-- 2) Grant specific privileges to billing user
GRANT SELECT, INSERT, UPDATE ON hospital_db.payments TO 'billing_user'@'localhost';

-- 3) Revoke a privilege
REVOKE INSERT ON hospital_db.payments FROM 'billing_user'@'localhost';

-- TCL Examples (transaction control)
-- 4) Transfer payment (demonstration of transaction)
START TRANSACTION;
  UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
  UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;
COMMIT;

-- 5) Example with rollback on error (pseudo)
START TRANSACTION;
  UPDATE medicines SET stock = stock - 5 WHERE medicine_id = 10;
  -- if stock below 0 then rollback
  -- SELECT IF((SELECT stock FROM medicines WHERE medicine_id=10) < 0, ROLLBACK, COMMIT);
COMMIT;

/* ======================================================
   SECTION F: TRIGGERS
   - BEFORE / AFTER triggers for auditing & constraints
   ====================================================== */

DELIMITER $$

-- 1) AFTER INSERT on payments -> log to payment_audit
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
  INSERT INTO payment_audit (payment_id, patient_id, amount, action_time)
  VALUES (NEW.payment_id, NEW.patient_id, NEW.amount, NOW());
END$$

-- 2) BEFORE UPDATE on medicines -> prevent negative stock
CREATE TRIGGER trg_before_medicine_update
BEFORE UPDATE ON medicines
FOR EACH ROW
BEGIN
  IF NEW.stock < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
  END IF;
END$$

-- 3) AFTER INSERT on admissions -> mark room occupied (safety)
CREATE TRIGGER trg_after_admission_insert
AFTER INSERT ON admissions
FOR EACH ROW
BEGIN
  UPDATE rooms SET status = 'Occupied' WHERE room_id = NEW.room_id;
  INSERT INTO audit_log (entity, action, entity_id, action_time)
    VALUES ('admissions', 'INSERT', NEW.admission_id, NOW());
END$$

-- 4) AFTER UPDATE on admissions -> if discharge_date set, free room
CREATE TRIGGER trg_after_admission_update
AFTER UPDATE ON admissions
FOR EACH ROW
BEGIN
  IF NEW.discharge_date IS NOT NULL AND OLD.discharge_date IS NULL THEN
    UPDATE rooms SET status = 'Available' WHERE room_id = NEW.room_id;
    INSERT INTO audit_log (entity, action, entity_id, action_time)
      VALUES ('admissions', 'DISCHARGE', NEW.admission_id, NOW());
  END IF;
END$$

-- 5) BEFORE INSERT on prescriptions -> auto-fill issue_date
CREATE TRIGGER trg_before_prescription_insert
BEFORE INSERT ON prescriptions
FOR EACH ROW
BEGIN
  IF NEW.issue_date IS NULL THEN
    SET NEW.issue_date = CURDATE();
  END IF;
END$$

-- 6) AFTER INSERT on test_results -> update last_test_date in patients
CREATE TRIGGER trg_after_test_result_insert
AFTER INSERT ON test_results
FOR EACH ROW
BEGIN
  UPDATE patients SET last_test_date = NEW.result_date WHERE patient_id = NEW.patient_id;
END$$

-- 7) AFTER DELETE on doctors -> cascade to doctor_schedules log (just log)
CREATE TRIGGER trg_after_doctor_delete
AFTER DELETE ON doctors
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (entity, action, entity_id, action_time)
    VALUES ('doctors', 'DELETE', OLD.doctor_id, NOW());
END$$

-- 8) BEFORE INSERT on payments -> validate amount > 0
CREATE TRIGGER trg_before_payment_insert
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
  IF NEW.amount <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount must be positive';
  END IF;
END$$

-- 9) AFTER UPDATE on medicines -> if expiry_date passed, set stock to 0
CREATE TRIGGER trg_after_medicine_update_expiry
AFTER UPDATE ON medicines
FOR EACH ROW
BEGIN
  IF NEW.expiry_date IS NOT NULL AND NEW.expiry_date < CURDATE() THEN
    UPDATE medicines SET stock = 0 WHERE medicine_id = NEW.medicine_id;
    INSERT INTO procedural_audit (proc_name, details, log_time)
      VALUES ('trg_after_medicine_update_expiry', CONCAT('Medicine ', NEW.medicine_id, ' expired, stock set 0'), NOW());
  END IF;
END$$

-- 10) AFTER INSERT on surgeries -> notify OR team (insert into notifications)
CREATE TRIGGER trg_after_surgery_insert
AFTER INSERT ON surgeries
FOR EACH ROW
BEGIN
  INSERT INTO notifications (recipient, message, created_at)
    VALUES ('OR_TEAM', CONCAT('New surgery scheduled: ID=', NEW.surgery_id, ', Date=', NEW.surgery_date), NOW());
END$$

DELIMITER ;

/* ======================================================
   SECTION G: CLEANUP / USAGE NOTES
   - How to call stored procedures and view results
   ====================================================== */

-- Examples of calling procedures:
-- CALL proc_admit_patient(502, 201, 5, CURDATE());
-- CALL proc_restock_low_medicines(50);
-- CALL proc_iterate_active_patients();

-- Query views:
-- SELECT * FROM view_active_patients;
-- SELECT * FROM view_patient_billing_summary ORDER BY total_paid DESC LIMIT 10;

-- Window function queries can be executed directly in MySQL 8+ or other engines that support them.

-- DCL commands require admin privileges. Triggers & procedures require appropriate CREATE ROUTINE and TRIGGER privileges.

-- End of PHASE-4 script
