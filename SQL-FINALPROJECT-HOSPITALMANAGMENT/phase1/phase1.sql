-- Create Database
CREATE DATABASE HospitalManagementDB;
USE HospitalManagementDB;

-- 1️⃣ Patients Table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M','F','O')),
    DOB DATE NOT NULL,
    Phone VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(255),
    BloodGroup VARCHAR(5),
    EmergencyContact VARCHAR(50)
);

-- 2️⃣ Doctors Table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialty VARCHAR(50) NOT NULL,
    Phone VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    HireDate DATE DEFAULT CURRENT_DATE,
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- 3️⃣ Departments Table
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50) UNIQUE NOT NULL,
    HeadDoctorID INT,
    FOREIGN KEY (HeadDoctorID) REFERENCES Doctors(DoctorID)
);

-- 4️⃣ Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    Reason VARCHAR(255),
    Status VARCHAR(20) DEFAULT 'Scheduled',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- 5️⃣ Rooms Table
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY,
    RoomNumber VARCHAR(10) UNIQUE NOT NULL,
    RoomType VARCHAR(20) CHECK (RoomType IN ('General','Private','ICU')),
    BedCount INT CHECK (BedCount > 0),
    AvailableBeds INT CHECK (AvailableBeds >= 0)
);

-- 6️⃣ Admissions Table
CREATE TABLE Admissions (
    AdmissionID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    RoomID INT NOT NULL,
    AdmitDate DATETIME NOT NULL,
    DischargeDate DATETIME,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

-- 7️⃣ Treatments Table
CREATE TABLE Treatments (
    TreatmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    TreatmentDate DATETIME NOT NULL,
    Description VARCHAR(255),
    Cost DECIMAL(10,2) CHECK (Cost >= 0),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- 8️⃣ Medicines Table
CREATE TABLE Medicines (
    MedicineID INT PRIMARY KEY,
    MedicineName VARCHAR(100) NOT NULL,
    Manufacturer VARCHAR(50),
    ExpiryDate DATE NOT NULL,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    StockQty INT CHECK (StockQty >= 0)
);

-- 9️⃣ Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(50),
    Frequency VARCHAR(50),
    StartDate DATE NOT NULL,
    EndDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (MedicineID) REFERENCES Medicines(MedicineID)
);

-- 10️⃣ Nurses Table
CREATE TABLE Nurses (
    NurseID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    HireDate DATE DEFAULT CURRENT_DATE,
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

-- 11️⃣ LabTests Table
CREATE TABLE LabTests (
    LabTestID INT PRIMARY KEY,
    TestName VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Cost DECIMAL(10,2) CHECK (Cost >= 0)
);

-- 12️⃣ LabReports Table
CREATE TABLE LabReports (
    ReportID INT PRIMARY KEY,
    LabTestID INT NOT NULL,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    ReportDate DATETIME NOT NULL,
    Result VARCHAR(255),
    FOREIGN KEY (LabTestID) REFERENCES LabTests(LabTestID),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- 13️⃣ Billings Table
CREATE TABLE Billings (
    BillingID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    Amount DECIMAL(10,2) CHECK (Amount >= 0),
    BillingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    PaymentStatus VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- 14️⃣ Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    BillingID INT NOT NULL,
    PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    AmountPaid DECIMAL(10,2) CHECK (AmountPaid >= 0),
    PaymentMode VARCHAR(20) CHECK (PaymentMode IN ('Cash','Card','UPI','Insurance')),
    FOREIGN KEY (BillingID) REFERENCES Billings(BillingID)
);

-- 15️⃣ Insurance Table
CREATE TABLE Insurance (
    InsuranceID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    ProviderName VARCHAR(100) NOT NULL,
    PolicyNumber VARCHAR(50) UNIQUE NOT NULL,
    CoverageAmount DECIMAL(10,2) CHECK (CoverageAmount >= 0),
    ValidTill DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- 16️⃣ Shifts Table
CREATE TABLE Shifts (
    ShiftID INT PRIMARY KEY,
    NurseID INT NOT NULL,
    ShiftDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    FOREIGN KEY (NurseID) REFERENCES Nurses(NurseID)
);

-- 17️⃣ Equipment Table
CREATE TABLE Equipment (
    EquipmentID INT PRIMARY KEY,
    EquipmentName VARCHAR(100) NOT NULL,
    Quantity INT CHECK (Quantity >= 0),
    MaintenanceDate DATE
);

-- 18️⃣ Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(50),
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Address VARCHAR(255)
);

-- 19️⃣ EquipmentSupplies Table
CREATE TABLE EquipmentSupplies (
    SupplyID INT PRIMARY KEY,
    EquipmentID INT NOT NULL,
    SupplierID INT NOT NULL,
    SupplyDate DATE NOT NULL,
    QuantitySupplied INT CHECK (QuantitySupplied > 0),
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- 20️⃣ Ambulances Table
CREATE TABLE Ambulances (
    AmbulanceID INT PRIMARY KEY,
    VehicleNumber VARCHAR(20) UNIQUE NOT NULL,
    DriverName VARCHAR(50),
    Status VARCHAR(20) CHECK (Status IN ('Available','On Duty','Maintenance'))
);

-- 21️⃣ AmbulanceRequests Table
CREATE TABLE AmbulanceRequests (
    RequestID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    AmbulanceID INT NOT NULL,
    RequestDate DATETIME NOT NULL,
    Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (AmbulanceID) REFERENCES Ambulances(AmbulanceID)
);

-- 22️⃣ DietPlans Table
CREATE TABLE DietPlans (
    DietID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    PlanDate DATE NOT NULL,
    Breakfast VARCHAR(255),
    Lunch VARCHAR(255),
    Dinner VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- 23️⃣ Feedback Table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    FeedbackDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Comments VARCHAR(255),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- 24️⃣ Staff Table
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(50),
    Phone VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    HireDate DATE DEFAULT CURRENT_DATE
);

-- 25️⃣ Visits Table
CREATE TABLE Visits (
    VisitID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATETIME NOT NULL,
    Reason VARCHAR(255),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

USE HospitalManagementDB;

-- 1️⃣ Patients
INSERT INTO Patients (PatientID, FirstName, LastName, Gender, DOB, Phone, Email, Address, BloodGroup, EmergencyContact)
VALUES
(1,'Shruti','Tiwari','F','1995-03-15','9876543210','shruti.t@example.com','123 ABC St, Mumbai','A+','Raj Tiwari'),
(2,'Rahul','Sharma','M','1990-06-20','9876501234','rahul.s@example.com','456 DEF St, Pune','B+','Anita Sharma'),
(3,'Ananya','Gupta','F','1985-11-10','9876512345','ananya.g@example.com','789 GHI St, Delhi','O-','Karan Gupta'),
(4,'Rohit','Verma','M','1978-01-05','9876523456','rohit.v@example.com','101 JKL St, Bangalore','AB+','Sunita Verma'),
(5,'Sneha','Patel','F','2000-09-25','9876534567','sneha.p@example.com','202 MNO St, Mumbai','A-','Rakesh Patel'),
(6,'Aditya','Singh','M','1992-12-30','9876545678','aditya.s@example.com','303 PQR St, Jaipur','B-','Meera Singh'),
(7,'Pooja','Kumar','F','1998-07-18','9876556789','pooja.k@example.com','404 STU St, Delhi','O+','Vikram Kumar'),
(8,'Vikram','Joshi','M','1982-04-10','9876567890','vikram.j@example.com','505 VWX St, Pune','AB-','Nina Joshi'),
(9,'Meera','Chopra','F','1996-05-22','9876578901','meera.c@example.com','606 YZA St, Mumbai','A+','Sunil Chopra'),
(10,'Rajat','Agarwal','M','1988-08-12','9876589012','rajat.a@example.com','707 BCD St, Delhi','B+','Anjali Agarwal'),
(11,'Kavita','Shah','F','1994-11-30','9876590123','kavita.s@example.com','808 EFG St, Pune','O+','Nilesh Shah'),
(12,'Sahil','Mehta','M','1991-02-28','9876502345','sahil.m@example.com','909 HIJ St, Mumbai','A-','Rekha Mehta'),
(13,'Rina','Kapoor','F','1997-06-15','9876513456','rina.k@example.com','121 KLM St, Delhi','B+','Anil Kapoor'),
(14,'Karan','Malhotra','M','1984-09-10','9876524567','karan.m@example.com','232 NOP St, Pune','AB+','Suman Malhotra'),
(15,'Tanya','Verma','F','1999-12-05','9876535678','tanya.v@example.com','343 QRS St, Mumbai','O-','Rohit Verma'),
(16,'Anil','Joshi','M','1986-03-18','9876546789','anil.j@example.com','454 TUV St, Delhi','A+','Pooja Joshi'),
(17,'Richa','Khandelwal','F','1995-07-22','9876557890','richa.k@example.com','565 WXY St, Pune','B-','Vikram Khandelwal'),
(18,'Nikhil','Rao','M','1990-11-11','9876568901','nikhil.r@example.com','676 ZAB St, Mumbai','O+','Meera Rao'),
(19,'Sanya','Kapoor','F','1998-01-30','9876579012','sanya.k@example.com','787 CDE St, Delhi','AB-','Rajat Kapoor'),
(20,'Manish','Sharma','M','1985-05-25','9876580123','manish.s@example.com','898 FGH St, Pune','A-','Sneha Sharma');

-- 2️⃣ Departments
INSERT INTO Departments (DepartmentID, DepartmentName)
VALUES
(1,'Cardiology'),
(2,'Neurology'),
(3,'Orthopedics'),
(4,'Pediatrics'),
(5,'General Surgery'),
(6,'ENT'),
(7,'Dermatology'),
(8,'Radiology'),
(9,'Oncology'),
(10,'Emergency');

-- 3️⃣ Doctors
INSERT INTO Doctors (DoctorID, FirstName, LastName, Specialty, Phone, Email, Salary, DepartmentID)
VALUES
(1,'Dr. Rajesh','Kumar','Cardiologist','9876000001','rajesh.k@example.com',1200000,1),
(2,'Dr. Anita','Gupta','Neurologist','9876000002','anita.g@example.com',1150000,2),
(3,'Dr. Vikram','Sharma','Orthopedic','9876000003','vikram.s@example.com',1100000,3),
(4,'Dr. Sneha','Patel','Pediatrician','9876000004','sneha.p@example.com',1050000,4),
(5,'Dr. Aditya','Verma','Surgeon','9876000005','aditya.v@example.com',1250000,5),
(6,'Dr. Meera','Joshi','ENT','9876000006','meera.j@example.com',950000,6),
(7,'Dr. Tanya','Kapoor','Dermatologist','9876000007','tanya.k@example.com',900000,7),
(8,'Dr. Rohan','Agarwal','Radiologist','9876000008','rohan.a@example.com',1000000,8),
(9,'Dr. Kavita','Shah','Oncologist','9876000009','kavita.s@example.com',1300000,9),
(10,'Dr. Rajat','Mehta','Emergency Physician','9876000010','rajat.m@example.com',950000,10),
(11,'Dr. Anil','Rao','Cardiologist','9876000011','anil.r@example.com',1200000,1),
(12,'Dr. Rina','Kapoor','Neurologist','9876000012','rina.k@example.com',1150000,2),
(13,'Dr. Karan','Malhotra','Orthopedic','9876000013','karan.m@example.com',1100000,3),
(14,'Dr. Pooja','Verma','Pediatrician','9876000014','pooja.v@example.com',1050000,4),
(15,'Dr. Nikhil','Joshi','Surgeon','9876000015','nikhil.j@example.com',1250000,5),
(16,'Dr. Richa','Khandelwal','ENT','9876000016','richa.k@example.com',950000,6),
(17,'Dr. Manish','Sharma','Dermatologist','9876000017','manish.s@example.com',900000,7),
(18,'Dr. Sanya','Kapoor','Radiologist','9876000018','sanya.k@example.com',1000000,8),
(19,'Dr. Aditya','Rao','Oncologist','9876000019','aditya.r@example.com',1300000,9),
(20,'Dr. Meera','Verma','Emergency Physician','9876000020','meera.v@example.com',950000,10);

-- 4️⃣ Rooms
INSERT INTO Rooms (RoomID, RoomNumber, RoomType, BedCount, AvailableBeds)
VALUES
(1,'101','General',4,4),
(2,'102','General',4,3),
(3,'103','Private',2,2),
(4,'104','Private',2,1),
(5,'105','ICU',1,1),
(6,'106','ICU',1,0),
(7,'107','General',4,4),
(8,'108','Private',2,2),
(9,'109','ICU',1,1),
(10,'110','General',4,3),
(11,'111','General',4,4),
(12,'112','Private',2,2),
(13,'113','ICU',1,1),
(14,'114','General',4,4),
(15,'115','Private',2,2),
(16,'116','ICU',1,1),
(17,'117','General',4,4),
(18,'118','Private',2,2),
(19,'119','ICU',1,1),
(20,'120','General',4,3);

-- 5️⃣ Nurses
INSERT INTO Nurses (NurseID, FirstName, LastName, Phone, Email, DepartmentID)
VALUES
(1,'Neha','Sharma','9877000001','neha.s@example.com',1),
(2,'Ritu','Verma','9877000002','ritu.v@example.com',2),
(3,'Pooja','Joshi','9877000003','pooja.j@example.com',3),
(4,'Sonal','Patel','9877000004','sonal.p@example.com',4),
(5,'Anita','Kapoor','9877000005','anita.k@example.com',5),
(6,'Kavita','Shah','9877000006','kavita.s@example.com',6),
(7,'Rina','Gupta','9877000007','rina.g@example.com',7),
(8,'Tanya','Verma','9877000008','tanya.v@example.com',8),
(9,'Sneha','Joshi','9877000009','sneha.j@example.com',9),
(10,'Meera','Rao','9877000010','meera.r@example.com',10),
(11,'Nikhil','Sharma','9877000011','nikhil.s@example.com',1),
(12,'Rajat','Kapoor','9877000012','rajat.k@example.com',2),
(13,'Sanya','Patel','9877000013','sanya.p@example.com',3),
(14,'Aditya','Verma','9877000014','aditya.v@example.com',4),
(15,'Richa','Joshi','9877000015','richa.j@example.com',5),
(16,'Manish','Sharma','9877000016','manish.s@example.com',6),
(17,'Ananya','Kapoor','9877000017','ananya.k@example.com',7),
(18,'Vikram','Patel','9877000018','vikram.p@example.com',8),
(19,'Shruti','Joshi','9877000019','shruti.j@example.com',9),
(20,'Rahul','Verma','9877000020','rahul.v@example.com',10);

-- 6️⃣ Medicines
INSERT INTO Medicines (MedicineID, MedicineName, Manufacturer, ExpiryDate, Price, StockQty)
VALUES
(1,'Paracetamol','ABC Pharma','2026-12-31',10,200),
(2,'Amoxicillin','XYZ Pharma','2025-11-30',25,150),
(3,'Ibuprofen','HealthCare Ltd','2026-06-30',15,100),
(4,'Metformin','MediCorp','2027-01-15',30,120),
(5,'Aspirin','WellnessPharma','2025-09-20',20,180),
(6,'Ciprofloxacin','ABC Pharma','2026-05-10',35,100),
(7,'Omeprazole','XYZ Pharma','2027-02-28',25,130),
(8,'Atorvastatin','HealthCare Ltd','2026-03-31',40,90),
(9,'Levothyroxine','MediCorp','2025-12-31',28,70),
(10,'Azithromycin','WellnessPharma','2026-08-15',30,100),
(11,'Metoprolol','ABC Pharma','2027-01-31',35,80),
(12,'Furosemide','XYZ Pharma','2026-04-30',20,110),
(13,'Clindamycin','HealthCare Ltd','2025-11-15',25,60),
(14,'Simvastatin','MediCorp','2027-05-31',40,70),
(15,'Hydrochlorothiazide','WellnessPharma','2026-09-30',15,90),
(16,'Gabapentin','ABC Pharma','2027-02-28',30,50),
(17,'Losartan','XYZ Pharma','2026-06-15',35,80),
(18,'Prednisone','HealthCare Ltd','2025-12-20',25,60),
(19,'Clopidogrel','MediCorp','2026-08-31',40,70),
(20,'Warfarin','WellnessPharma','2027-03-31',35,60);

-- 7️⃣ Appointments
INSERT INTO Appointments (AppointmentID, PatientID, DoctorID, AppointmentDate, Reason, Status)
VALUES
(1,1,1,'2025-11-16 10:00:00','Chest Pain','Scheduled'),
(2,2,2,'2025-11-16 11:00:00','Headache','Scheduled'),
(3,3,3,'2025-11-16 12:00:00','Back Pain','Scheduled'),
(4,4,4,'2025-11-16 13:00:00','Fever','Scheduled'),
(5,5,5,'2025-11-16 14:00:00','Surgery Consultation','Scheduled'),
(6,6,6,'2025-11-16 15:00:00','Ear Pain','Scheduled'),
(7,7,7,'2025-11-16 16:00:00','Skin Rash','Scheduled'),
(8,8,8,'2025-11-16 17:00:00','X-Ray Review','Scheduled'),
(9,9,9,'2025-11-17 10:00:00','Cancer Checkup','Scheduled'),
(10,10,10,'2025-11-17 11:00:00','Emergency Visit','Scheduled'),
(11,11,1,'2025-11-17 12:00:00','Heart Checkup','Scheduled'),
(12,12,2,'2025-11-17 13:00:00','Migraine','Scheduled'),
(13,13,3,'2025-11-17 14:00:00','Knee Pain','Scheduled'),
(14,14,4,'2025-11-17 15:00:00','Child Fever','Scheduled'),
(15,15,5,'2025-11-17 16:00:00','Pre-Surgery','Scheduled'),
(16,16,6,'2025-11-17 17:00:00','Sinus Infection','Scheduled'),
(17,17,7,'2025-11-18 10:00:00','Acne Treatment','Scheduled'),
(18,18,8,'2025-11-18 11:00:00','CT Scan Review','Scheduled'),
(19,19,9,'2025-11-18 12:00:00','Cancer Therapy','Scheduled'),
(20,20,10,'2025-11-18 13:00:00','Emergency','Scheduled');

-- 8️⃣ Admissions
INSERT INTO Admissions (AdmissionID, PatientID, RoomID, AdmitDate, DischargeDate)
VALUES
(1,1,1,'2025-11-16 10:00:00',NULL),
(2,2,2,'2025-11-16 11:00:00',NULL),
(3,3,3,'2025-11-16 12:00:00',NULL),
(4,4,4,'2025-11-16 13:00:00',NULL),
(5,5,5,'2025-11-16 14:00:00',NULL),
(6,6,6,'2025-11-16 15:00:00',NULL),
(7,7,7,'2025-11-16 16:00:00',NULL),
(8,8,8,'2025-11-16 17:00:00',NULL),
(9,9,9,'2025-11-17 10:00:00',NULL),
(10,10,10,'2025-11-17 11:00:00',NULL),
(11,11,1,'2025-11-17 12:00:00',NULL),
(12,12,2,'2025-11-17 13:00:00',NULL),
(13,13,3,'2025-11-17 14:00:00',NULL),
(14,14,4,'2025-11-17 15:00:00',NULL),
(15,15,5,'2025-11-17 16:00:00',NULL),
(16,16,6,'2025-11-17 17:00:00',NULL),
(17,17,7,'2025-11-18 10:00:00',NULL),
(18,18,8,'2025-11-18 11:00:00',NULL),
(19,19,9,'2025-11-18 12:00:00',NULL),
(20,20,10,'2025-11-18 13:00:00',NULL);

-- 9️⃣ Treatments
INSERT INTO Treatments (TreatmentID, PatientID, DoctorID, TreatmentDate, Description, Cost)
VALUES
(1,1,1,'2025-11-16 10:30:00','Heart Monitoring',5000),
(2,2,2,'2025-11-16 11:30:00','MRI Scan',8000),
(3,3,3,'2025-11-16 12:30:00','Physiotherapy',3000),
(4,4,4,'2025-11-16 13:30:00','Fever Treatment',1500),
(5,5,5,'2025-11-16 14:30:00','Surgery Prep',10000),
(6,6,6,'2025-11-16 15:30:00','Ear Infection Treatment',2000),
(7,7,7,'2025-11-16 16:30:00','Skin Allergy Treatment',2500),
(8,8,8,'2025-11-16 17:30:00','X-Ray Analysis',1500),
(9,9,9,'2025-11-17 10:30:00','Cancer Screening',12000),
(10,10,10,'2025-11-17 11:30:00','Emergency Care',5000),
(11,11,1,'2025-11-17 12:30:00','Heart Checkup',4000),
(12,12,2,'2025-11-17 13:30:00','Migraine Treatment',2000),
(13,13,3,'2025-11-17 14:30:00','Knee Surgery',15000),
(14,14,4,'2025-11-17 15:30:00','Child Fever Treatment',1800),
(15,15,5,'2025-11-17 16:30:00','Surgery Follow-up',7000),
(16,16,6,'2025-11-17 17:30:00','Sinus Care',2200),
(17,17,7,'2025-11-18 10:30:00','Acne Treatment',1500),
(18,18,8,'2025-11-18 11:30:00','CT Scan Review',3000),
(19,19,9,'2025-11-18 12:30:00','Chemotherapy',20000),
(20,20,10,'2025-11-18 13:30:00','Emergency Treatment',5000);

-- 1️⃣0️⃣ Prescriptions
INSERT INTO Prescriptions (PrescriptionID, PatientID, DoctorID, MedicineID, Dosage, Frequency, StartDate, EndDate)
VALUES
(1,1,1,1,'500mg','Twice a day','2025-11-16','2025-11-22'),
(2,2,2,2,'250mg','Thrice a day','2025-11-16','2025-11-23'),
(3,3,3,3,'200mg','Once a day','2025-11-16','2025-11-22'),
(4,4,4,4,'500mg','Twice a day','2025-11-16','2025-11-22'),
(5,5,5,5,'100mg','Once a day','2025-11-16','2025-11-23'),
(6,6,6,6,'250mg','Twice a day','2025-11-16','2025-11-22'),
(7,7,7,7,'100mg','Once a day','2025-11-16','2025-11-22'),
(8,8,8,8,'200mg','Twice a day','2025-11-16','2025-11-23'),
(9,9,9,9,'50mg','Once a day','2025-11-17','2025-11-24'),
(10,10,10,10,'500mg','Twice a day','2025-11-17','2025-11-23'),
(11,11,1,11,'100mg','Once a day','2025-11-17','2025-11-22'),
(12,12,2,12,'250mg','Twice a day','2025-11-17','2025-11-23'),
(13,13,3,13,'100mg','Once a day','2025-11-17','2025-11-22'),
(14,14,4,14,'50mg','Twice a day','2025-11-17','2025-11-23'),
(15,15,5,15,'200mg','Once a day','2025-11-17','2025-11-24'),
(16,16,6,16,'100mg','Twice a day','2025-11-17','2025-11-22'),
(17,17,7,17,'50mg','Once a day','2025-11-18','2025-11-25'),
(18,18,8,18,'200mg','Twice a day','2025-11-18','2025-11-24'),
(19,19,9,19,'100mg','Once a day','2025-11-18','2025-11-25'),
(20,20,10,20,'50mg','Twice a day','2025-11-18','2025-11-24');

USE HospitalManagementDB;

-- 11️⃣ LabTests
INSERT INTO LabTests (LabTestID, TestName, Description, Cost)
VALUES
(1,'Blood Test','Complete blood count',500),
(2,'X-Ray','Chest X-Ray',800),
(3,'MRI','Brain MRI',5000),
(4,'CT Scan','Abdominal CT Scan',4500),
(5,'ECG','Electrocardiogram',700),
(6,'Ultrasound','Abdominal Ultrasound',1000),
(7,'Urine Test','Routine urine examination',300),
(8,'Liver Function','LFT Panel',1200),
(9,'Kidney Function','KFT Panel',1200),
(10,'COVID-19 Test','PCR Test',1500),
(11,'Thyroid Test','TSH/T3/T4',1000),
(12,'Blood Sugar','Fasting/PP',400),
(13,'Lipid Profile','Cholesterol and fats',900),
(14,'Vitamin D','Vitamin D level',1200),
(15,'HIV Test','Screening Test',800),
(16,'Hepatitis B','HBsAg Test',1000),
(17,'Pregnancy Test','Urine Pregnancy Test',300),
(18,'Allergy Test','Allergy Panel',2500),
(19,'Bone Density','DEXA Scan',2000),
(20,'Eye Test','Vision and Eye Pressure',600);

-- 12️⃣ LabReports
INSERT INTO LabReports (ReportID, LabTestID, PatientID, DoctorID, ReportDate, Result)
VALUES
(1,1,1,1,'2025-11-16','Normal'),
(2,2,2,2,'2025-11-16','Normal'),
(3,3,3,3,'2025-11-16','Abnormal'),
(4,4,4,4,'2025-11-16','Normal'),
(5,5,5,5,'2025-11-16','Normal'),
(6,6,6,6,'2025-11-16','Normal'),
(7,7,7,7,'2025-11-16','Normal'),
(8,8,8,8,'2025-11-16','Slightly High'),
(9,9,9,9,'2025-11-17','Normal'),
(10,10,10,'2025-11-17','Negative'),
(11,11,11,1,'2025-11-17','Normal'),
(12,12,12,2,'2025-11-17','High'),
(13,13,13,3,'2025-11-17','Normal'),
(14,14,14,4,'2025-11-17','Deficient'),
(15,15,15,5,'2025-11-17','Negative'),
(16,16,16,6,'2025-11-17','Normal'),
(17,17,17,7,'2025-11-18','Positive'),
(18,18,18,8,'2025-11-18','Mild Allergy'),
(19,19,19,9,'2025-11-18','Normal'),
(20,20,20,10,'2025-11-18','Normal');

-- 13️⃣ Billings
INSERT INTO Billings (BillingID, PatientID, Amount, BillingDate, PaymentStatus)
VALUES
(1,1,5000,'2025-11-16','Pending'),
(2,2,8000,'2025-11-16','Pending'),
(3,3,3000,'2025-11-16','Pending'),
(4,4,1500,'2025-11-16','Pending'),
(5,5,10000,'2025-11-16','Pending'),
(6,6,2000,'2025-11-16','Pending'),
(7,7,2500,'2025-11-16','Pending'),
(8,8,1500,'2025-11-16','Pending'),
(9,9,12000,'2025-11-17','Pending'),
(10,10,5000,'2025-11-17','Pending'),
(11,11,4000,'2025-11-17','Pending'),
(12,12,2000,'2025-11-17','Pending'),
(13,13,15000,'2025-11-17','Pending'),
(14,14,1800,'2025-11-17','Pending'),
(15,15,7000,'2025-11-17','Pending'),
(16,16,2200,'2025-11-17','Pending'),
(17,17,1500,'2025-11-18','Pending'),
(18,18,3000,'2025-11-18','Pending'),
(19,19,20000,'2025-11-18','Pending'),
(20,20,5000,'2025-11-18','Pending');

-- 14️⃣ Payments
INSERT INTO Payments (PaymentID, BillingID, PaymentDate, AmountPaid, PaymentMode)
VALUES
(1,1,'2025-11-16',5000,'Cash'),
(2,2,'2025-11-16',8000,'Card'),
(3,3,'2025-11-16',3000,'UPI'),
(4,4,'2025-11-16',1500,'Cash'),
(5,5,'2025-11-16',10000,'Card'),
(6,6,'2025-11-16',2000,'UPI'),
(7,7,'2025-11-16',2500,'Cash'),
(8,8,'2025-11-16',1500,'Card'),
(9,9,'2025-11-17',12000,'Insurance'),
(10,10,'2025-11-17',5000,'Cash'),
(11,11,'2025-11-17',4000,'UPI'),
(12,12,'2025-11-17',2000,'Card'),
(13,13,'2025-11-17',15000,'Insurance'),
(14,14,'2025-11-17',1800,'Cash'),
(15,15,'2025-11-17',7000,'Card'),
(16,16,'2025-11-17',2200,'UPI'),
(17,17,'2025-11-18',1500,'Cash'),
(18,18,'2025-11-18',3000,'Card'),
(19,19,'2025-11-18',20000,'Insurance'),
(20,20,'2025-11-18',5000,'UPI');

-- 15️⃣ Insurance
INSERT INTO Insurance (InsuranceID, PatientID, ProviderName, PolicyNumber, CoverageAmount, ValidTill)
VALUES
(1,1,'Apollo','AP123456',50000,'2026-12-31'),
(2,2,'Star Health','SH123456',60000,'2026-11-30'),
(3,3,'Religare','RL123456',45000,'2026-06-30'),
(4,4,'Max Bupa','MB123456',70000,'2027-01-15'),
(5,5,'ICICI Lombard','IC123456',80000,'2025-09-20'),
(6,6,'HDFC Ergo','HD123456',50000,'2026-05-10'),
(7,7,'Tata AIG','TA123456',65000,'2027-02-28'),
(8,8,'Bharti AXA','BA123456',55000,'2026-03-31'),
(9,9,'Reliance General','RG123456',60000,'2025-12-31'),
(10,10,'Apollo','AP654321',70000,'2026-08-15'),
(11,11,'Star Health','SH654321',50000,'2027-01-31'),
(12,12,'Religare','RL654321',45000,'2026-04-30'),
(13,13,'Max Bupa','MB654321',60000,'2025-11-15'),
(14,14,'ICICI Lombard','IC654321',75000,'2027-05-31'),
(15,15,'HDFC Ergo','HD654321',80000,'2026-09-30'),
(16,16,'Tata AIG','TA654321',55000,'2027-02-28'),
(17,17,'Bharti AXA','BA654321',50000,'2026-06-15'),
(18,18,'Reliance General','RG654321',60000,'2025-12-20'),
(19,19,'Apollo','AP987654',70000,'2026-08-31'),
(20,20,'Star Health','SH987654',50000,'2027-03-31');

USE HospitalManagementDB;

-- 16️⃣ Shifts
INSERT INTO Shifts (ShiftID, NurseID, ShiftDate, StartTime, EndTime)
VALUES
(1,1,'2025-11-16','08:00:00','16:00:00'),
(2,2,'2025-11-16','08:00:00','16:00:00'),
(3,3,'2025-11-16','08:00:00','16:00:00'),
(4,4,'2025-11-16','16:00:00','00:00:00'),
(5,5,'2025-11-16','16:00:00','00:00:00'),
(6,6,'2025-11-17','08:00:00','16:00:00'),
(7,7,'2025-11-17','08:00:00','16:00:00'),
(8,8,'2025-11-17','16:00:00','00:00:00'),
(9,9,'2025-11-17','16:00:00','00:00:00'),
(10,10,'2025-11-18','08:00:00','16:00:00'),
(11,11,'2025-11-18','08:00:00','16:00:00'),
(12,12,'2025-11-18','16:00:00','00:00:00'),
(13,13,'2025-11-18','16:00:00','00:00:00'),
(14,14,'2025-11-19','08:00:00','16:00:00'),
(15,15,'2025-11-19','08:00:00','16:00:00'),
(16,16,'2025-11-19','16:00:00','00:00:00'),
(17,17,'2025-11-19','16:00:00','00:00:00'),
(18,18,'2025-11-20','08:00:00','16:00:00'),
(19,19,'2025-11-20','08:00:00','16:00:00'),
(20,20,'2025-11-20','16:00:00','00:00:00');

-- 17️⃣ Equipment
INSERT INTO Equipment (EquipmentID, EquipmentName, Quantity, MaintenanceDate)
VALUES
(1,'ECG Machine',5,'2025-12-31'),
(2,'X-Ray Machine',3,'2025-11-30'),
(3,'MRI Machine',2,'2026-01-15'),
(4,'CT Scanner',2,'2025-12-15'),
(5,'Ultrasound',4,'2025-11-20'),
(6,'Ventilator',10,'2025-12-10'),
(7,'Surgical Table',8,'2026-01-05'),
(8,'Defibrillator',6,'2025-12-25'),
(9,'Infusion Pump',15,'2025-11-28'),
(10,'Stethoscope',50,'2025-12-31'),
(11,'Oxygen Cylinder',40,'2025-11-30'),
(12,'Wheelchair',20,'2025-12-15'),
(13,'Blood Pressure Monitor',25,'2025-12-10'),
(14,'Glucose Meter',30,'2025-11-28'),
(15,'Thermometer',50,'2025-12-05'),
(16,'Syringe Pump',40,'2025-12-12'),
(17,'Nebulizer',10,'2025-11-30'),
(18,'Operating Light',8,'2025-12-20'),
(19,'Autoclave',5,'2025-12-25'),
(20,'Patient Monitor',15,'2025-12-31');

-- 18️⃣ Suppliers
INSERT INTO Suppliers (SupplierID, SupplierName, ContactPerson, Phone, Email, Address)
VALUES
(1,'MediSupply Co','Ramesh','9878000001','ramesh@medisupply.com','Mumbai'),
(2,'HealthTech','Anil','9878000002','anil@healthtech.com','Pune'),
(3,'PharmaCorp','Sonia','9878000003','sonia@pharmacorp.com','Delhi'),
(4,'Medico','Vikram','9878000004','vikram@medico.com','Bangalore'),
(5,'CareSupplies','Neha','9878000005','neha@caresupplies.com','Mumbai'),
(6,'GlobalMed','Raj','9878000006','raj@globalmed.com','Pune'),
(7,'LifeLine','Tanya','9878000007','tanya@lifeline.com','Delhi'),
(8,'MediPlus','Sahil','9878000008','sahil@mediplus.com','Mumbai'),
(9,'HealthLine','Ritu','9878000009','ritu@healthline.com','Pune'),
(10,'WellCare','Kavita','9878000010','kavita@wellcare.com','Bangalore'),
(11,'PharmaDirect','Aditya','9878000011','aditya@pharmadirect.com','Delhi'),
(12,'MediWorld','Pooja','9878000012','pooja@mediworld.com','Mumbai'),
(13,'LifeMed','Rohan','9878000013','rohan@lifemed.com','Pune'),
(14,'HealthAid','Sanya','9878000014','sanya@healthaid.com','Delhi'),
(15,'SupremeMed','Rina','9878000015','rina@suprememed.com','Bangalore'),
(16,'CarePlus','Manish','9878000016','manish@careplus.com','Mumbai'),
(17,'MediFirst','Tanya','9878000017','tanya@medifirst.com','Pune'),
(18,'HealthPro','Richa','9878000018','richa@healthpro.com','Delhi'),
(19,'WellPharma','Nikhil','9878000019','nikhil@wellpharma.com','Bangalore'),
(20,'MediSource','Shruti','9878000020','shruti@medisource.com','Mumbai');

-- 19️⃣ EquipmentSupplies
INSERT INTO EquipmentSupplies (SupplyID, EquipmentID, SupplierID, SupplyDate, QuantitySupplied)
VALUES
(1,1,1,'2025-10-10',2),
(2,2,2,'2025-10-12',1),
(3,3,3,'2025-10-15',1),
(4,4,4,'2025-10-18',1),
(5,5,5,'2025-10-20',3),
(6,6,6,'2025-10-22',5),
(7,7,7,'2025-10-25',2),
(8,8,8,'2025-10-28',2),
(9,9,9,'2025-11-01',4),
(10,10,10,'2025-11-03',10),
(11,11,11,'2025-11-05',8),
(12,12,12,'2025-11-07',5),
(13,13,13,'2025-11-10',6),
(14,14,14,'2025-11-12',8),
(15,15,15,'2025-11-15',12),
(16,16,16,'2025-11-17',7),
(17,17,17,'2025-11-19',4),
(18,18,18,'2025-11-20',2),
(19,19,19,'2025-11-21',1),
(20,20,20,'2025-11-22',5);

-- 20️⃣ Ambulances
INSERT INTO Ambulances (AmbulanceID, VehicleNumber, DriverName, Status)
VALUES
(1,'MH01AB1234','Ramesh','Available'),
(2,'MH02CD2345','Suresh','On Duty'),
(3,'MH03EF3456','Anil','Maintenance'),
(4,'MH04GH4567','Vikram','Available'),
(5,'MH05IJ5678','Neha','On Duty'),
(6,'MH06KL6789','Raj','Available'),
(7,'MH07MN7890','Tanya','Maintenance'),
(8,'MH08OP8901','Ritu','Available'),
(9,'MH09QR9012','Kavita','On Duty'),
(10,'MH10ST0123','Aditya','Available'),
(11,'MH11UV1234','Pooja','On Duty'),
(12,'MH12WX2345','Rohan','Available'),
(13,'MH13YZ3456','Sanya','Maintenance'),
(14,'MH14AB4567','Rina','Available'),
(15,'MH15CD5678','Manish','On Duty'),
(16,'MH16EF6789','Tanya','Available'),
(17,'MH17GH7890','Richa','Maintenance'),
(18,'MH18IJ8901','Nikhil','Available'),
(19,'MH19KL9012','Shruti','On Duty'),
(20,'MH20MN0123','Rahul','Available');

-- 21️⃣ AmbulanceRequests
INSERT INTO AmbulanceRequests (RequestID, PatientID, AmbulanceID, RequestDate, Status)
VALUES
(1,1,1,'2025-11-16 10:15:00','Completed'),
(2,2,2,'2025-11-16 11:20:00','Completed'),
(3,3,3,'2025-11-16 12:25:00','Pending'),
(4,4,4,'2025-11-16 13:30:00','Completed'),
(5,5,5,'2025-11-16 14:35:00','Pending'),
(6,6,6,'2025-11-16 15:40:00','Completed'),
(7,7,7,'2025-11-16 16:45:00','Pending'),
(8,8,8,'2025-11-16 17:50:00','Completed'),
(9,9,9,'2025-11-17 10:10:00','Completed'),
(10,10,10,'2025-11-17 11:15:00','Pending'),
(11,11,11,'2025-11-17 12:20:00','Completed'),
(12,12,12,'2025-11-17 13:25:00','Pending'),
(13,13,13,'2025-11-17 14:30:00','Completed'),
(14,14,14,'2025-11-17 15:35:00','Pending'),
(15,15,15,'2025-11-17 16:40:00','Completed'),
(16,16,16,'2025-11-17 17:45:00','Pending'),
(17,17,17,'2025-11-18 10:10:00','Completed'),
(18,18,18,'2025-11-18 11:15:00','Pending'),
(19,19,19,'2025-11-18 12:20:00','Completed'),
(20,20,20,'2025-11-18 13:25:00','Pending');

-- 22️⃣ DietPlans
INSERT INTO DietPlans (DietID, PatientID, PlanDate, Breakfast, Lunch, Dinner)
VALUES
(1,1,'2025-11-16','Oats','Grilled Chicken','Salad'),
(2,2,'2025-11-16','Eggs','Fish','Vegetables'),
(3,3,'2025-11-16','Poha','Rice & Dal','Soup'),
(4,4,'2025-11-16','Upma','Chapati & Curry','Salad'),
(5,5,'2025-11-16','Dalia','Paneer','Vegetables'),
(6,6,'2025-11-17','Idli','Rice & Sambar','Soup'),
(7,7,'2025-11-17','Paratha','Dal','Salad'),
(8,8,'2025-11-17','Bread','Chicken','Vegetables'),
(9,9,'2025-11-17','Oats','Rice & Veg','Soup'),
(10,10,'2025-11-17','Dosa','Chapati & Curry','Salad'),
(11,11,'2025-11-18','Upma','Paneer','Vegetables'),
(12,12,'2025-11-18','Poha','Dal','Soup'),
(13,13,'2025-11-18','Idli','Rice & Curry','Salad'),
(14,14,'2025-11-18','Dalia','Chicken','Vegetables'),
(15,15,'2025-11-18','Oats','Rice & Dal','Soup'),
(16,16,'2025-11-19','Paratha','Paneer','Vegetables'),
(17,17,'2025-11-19','Bread','Dal','Soup'),
(18,18,'2025-11-19','Dosa','Rice & Veg','Salad'),
(19,19,'2025-11-19','Upma','Chicken','Vegetables'),
(20,20,'2025-11-19','Poha','Chapati & Curry','Soup');

-- 23️⃣ Feedback
INSERT INTO Feedback (FeedbackID, PatientID, FeedbackDate, Comments, Rating)
VALUES
(1,1,'2025-11-16','Very satisfied',5),
(2,2,'2025-11-16','Good service',4),
(3,3,'2025-11-16','Average',3),
(4,4,'2025-11-16','Excellent',5),
(5,5,'2025-11-16','Poor service',2),
(6,6,'2025-11-17','Very satisfied',5),
(7,7,'2025-11-17','Good',4),
(8,8,'2025-11-17','Average',3),
(9,9,'2025-11-17','Excellent',5),
(10,10,'2025-11-17','Satisfactory',4),
(11,11,'2025-11-18','Very satisfied',5),
(12,12,'2025-11-18','Good service',4),
(13,13,'2025-11-18','Average',3),
(14,14,'2025-11-18','Excellent',5),
(15,15,'2025-11-18','Poor',2),
(16,16,'2025-11-19','Very satisfied',5),
(17,17,'2025-11-19','Good',4),
(18,18,'2025-11-19','Average',3),
(19,19,'2025-11-19','Excellent',5),
(20,20,'2025-11-19','Satisfactory',4);

-- 24️⃣ Staff
INSERT INTO Staff (StaffID, FirstName, LastName, Role, Phone, Email, HireDate)
VALUES
(1,'Ramesh','Patel','Receptionist','9879000001','ramesh.p@example.com','2020-01-10'),
(2,'Sonia','Shah','Lab Technician','9879000002','sonia.s@example.com','2019-05-15'),
(3,'Vikram','Gupta','Accountant','9879000003','vikram.g@example.com','2018-03-20'),
(4,'Neha','Verma','Housekeeping','9879000004','neha.v@example.com','2021-07-12'),
(5,'Anil','Joshi','Security','9879000005','anil.j@example.com','2020-11-01'),
(6,'Tanya','Kapoor','Pharmacist','9879000006','tanya.k@example.com','2019-09-10'),
(7,'Richa','Sharma','IT Support','9879000007','richa.s@example.com','2021-02-20'),
(8,'Manish','Verma','Receptionist','9879000008','manish.v@example.com','2020-08-25'),
(9,'Pooja','Rao','Lab Technician','9879000009','pooja.r@example.com','2019-12-15'),
(10,'Aditya','Shah','Accountant','9879000010','aditya.s@example.com','2018-11-10'),
(11,'Rina','Patel','Housekeeping','9879000011','rina.p@example.com','2021-01-05'),
(12,'Sahil','Kapoor','Security','9879000012','sahil.k@example.com','2020-03-12'),
(13,'Kavita','Joshi','Pharmacist','9879000013','kavita.j@example.com','2019-06-20'),
(14,'Rajat','Sharma','IT Support','9879000014','rajat.s@example.com','2021-09-18'),
(15,'Sanya','Verma','Receptionist','9879000015','sanya.v@example.com','2020-12-25'),
(16,'Nikhil','Rao','Lab Technician','9879000016','nikhil.r@example.com','2019-10-10'),
(17,'Shruti','Patel','Accountant','9879000017','shruti.p@example.com','2018-07-22'),
(18,'Rahul','Kapoor','Housekeeping','9879000018','rahul.k@example.com','2021-04-15'),
(19,'Meera','Joshi','Security','9879000019','meera.j@example.com','2020-09-05'),
(20,'Rohit','Sharma','Pharmacist','9879000020','rohit.s@example.com','2019-11-11');

-- 25️⃣ Visits
INSERT INTO Visits (VisitID, PatientID, DoctorID, VisitDate, Reason)
VALUES
(1,1,1,'2025-11-16 10:00:00','Chest Pain'),
(2,2,2,'2025-11-16 11:00:00','Headache'),
(3,3,3,'2025-11-16 12:00:00','Fever'),
(4,4,4,'2025-11-16 13:00:00','Cough'),
(5,5,5,'2025-11-16 14:00:00','Back Pain'),
(6,6,6,'2025-11-16 15:00:00','Ear Infection'),
(7,7,7,'2025-11-16 16:00:00','Skin Rash'),
(8,8,8,'2025-11-16 17:00:00','Routine Checkup'),
(9,9,9,'2025-11-17 10:00:00','Cancer Screening'),
(10,10,10,'2025-11-17 11:00:00','Emergency'),
(11,11,1,'2025-11-17 12:00:00','Heart Checkup'),
(12,12,2,'2025-11-17 13:00:00','Migraine'),
(13,13,3,'2025-11-17 14:00:00','Knee Surgery'),
(14,14,4,'2025-11-17 15:00:00','Child Fever'),
(15,15,5,'2025-11-17 16:00:00','Surgery Follow-up'),
(16,16,6,'2025-11-17 17:00:00','Sinus Care'),
(17,17,7,'2025-11-18 10:00:00','Acne'),
(18,18,8,'2025-11-18 11:00:00','CT Scan Review'),
(19,19,9,'2025-11-18 12:00:00','Chemotherapy'),
(20,20,10,'2025-11-18 13:00:00','Emergency Treatment');
