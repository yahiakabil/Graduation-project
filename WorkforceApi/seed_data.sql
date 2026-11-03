-- ============================================================
--  INTEGRATED WORKFORCE — SEED DATA
--  Database: AttendanceDb
--  Run this AFTER running EF Core migrations
--  (dotnet ef migrations add Init && dotnet ef database update)
-- ============================================================

USE AttendanceDb;
GO

-- ────────────────────────────────────────────────────────────
--  1. ROLES
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Roles)
BEGIN
    INSERT INTO Roles (Id, Name, Description) VALUES
        (1, 'Employee', 'Regular employee — check-in/out, requests, view payslip'),
        (2, 'Manager',  'Team manager — approve requests, view team attendance, issue warnings'),
        (3, 'Admin',    'HR Administrator — full system access, payroll, rules management');
END
GO

-- ────────────────────────────────────────────────────────────
--  2. DEPARTMENTS
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Departments)
BEGIN
    INSERT INTO Departments (Name, IsActive) VALUES
        ('Mobile Engineering',    1),   -- Id 1
        ('Product & QA',          1),   -- Id 2
        ('Cloud & DevOps',        1),   -- Id 3
        ('Mediterranean Sales',   1),   -- Id 4
        ('Executive Administration', 1); -- Id 5
END
GO

-- ────────────────────────────────────────────────────────────
--  3. BRANCHES
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Branches)
BEGIN
    INSERT INTO Branches (Name, Address, Latitude, Longitude, RadiusMeters, IsActive) VALUES
        ('Main HQ – Smart Village', 'Smart Village, 6th of October, Giza', 30.0714, 30.9856, 50.0, 1),  -- Id 1
        ('Alexandria Regional Branch', 'Roushdy, Alexandria, Egypt',        31.2188, 29.9571, 50.0, 1); -- Id 2
END
GO

-- ────────────────────────────────────────────────────────────
--  4. SHIFTS
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Shifts)
BEGIN
    INSERT INTO Shifts (Name, StartTime, EndTime, CheckInWindowBeforeMinutes,
                        WorksSunday, WorksMonday, WorksTuesday, WorksWednesday,
                        WorksThursday, WorksFriday, WorksSaturday, IsActive)
    VALUES
        -- Morning Core Shift (Sun-Thu 09-17)
        ('Morning Core Shift', '09:00:00', '17:00:00', 30,
         1, 1, 1, 1, 1, 0, 0, 1),  -- Id 1

        -- Sales Shift (Sun-Thu 10-18)
        ('Sales Shift', '10:00:00', '18:00:00', 30,
         1, 1, 1, 1, 1, 0, 0, 1),  -- Id 2

        -- Infrastructure Shift (Mon-Fri 09-17)
        ('Infrastructure Shift', '09:00:00', '17:00:00', 30,
         0, 1, 1, 1, 1, 1, 0, 1);  -- Id 3
END
GO

-- ────────────────────────────────────────────────────────────
--  5. ATTENDANCE POLICY (singleton, Id must = 1)
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM AttendancePolicy WHERE Id = 1)
BEGIN
    INSERT INTO AttendancePolicy (Id, FlagDaysPerMonth, CorrectionWindowHours, OvertimeRate)
    VALUES (1, 3, 24, 1.50);
END
GO

-- ────────────────────────────────────────────────────────────
--  6. DEDUCTION RULES  (Lateness ladder)
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM DeductionRules)
BEGIN
    INSERT INTO DeductionRules (Type, FromMinutes, ToMinutes, DeductionValue, DeductionUnit, Label) VALUES
        -- Lateness ladder
        ('Lateness',  1,  30,  0.00, 'percent', 'Warning only — 1 to 30 min late'),
        ('Lateness', 31,  60,  0.50, 'percent', '31-60 min late → 0.5% daily deduction'),
        ('Lateness', 61, 120,  1.00, 'percent', '61-120 min late → 1% deduction'),
        ('Lateness',121, 240,  2.00, 'percent', '2-4 hrs late → 2% deduction'),
        ('Lateness',241, 999,  4.00, 'percent', '>4 hrs late → half-day deduction'),

        -- Absence
        ('Absence',  1, 1,  3.50, 'percent', 'Unexcused absence → full day deduction'),

        -- Leaving early
        ('EarlyLeave', 1, 60, 0.50, 'percent', 'Left early < 1 hr → 0.5% deduction'),
        ('EarlyLeave',61,999, 1.50, 'percent', 'Left early > 1 hr → 1.5% deduction');
END
GO

-- ────────────────────────────────────────────────────────────
--  7. USERS
--  Passwords are BCrypt hashed from "password123" (cost=11)
--  Hash generated offline — safe to store directly
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Users)
BEGIN
    -- Admin: Yahia
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'ADM-0001', 'Yahia', 'yahia@company.com', '01011112222',
        '2020-01-01', 'HR Director & System Admin', 25000.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',  -- password123
        3, 5, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Manager: Mohamed (Mobile Engineering)
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'MGR-1001', 'Mohamed', 'mohamed@company.com', '01022223333',
        '2021-08-10', 'Mobile Engineering Lead', 18000.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        2, 1, 1, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Manager: Khaled (Product & QA)
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'MGR-1002', 'Khaled', 'khaled@company.com', '01033334444',
        '2022-03-15', 'Product & QA Lead', 17000.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        2, 2, 1, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Manager: Omar (Alexandria Sales)
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'MGR-1003', 'Omar', 'omar@company.com', '01044445555',
        '2023-02-01', 'Regional Sales Manager', 17500.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        2, 4, 1, 2, 2, 'ar', 0, 1, GETUTCDATE()
    );

    -- Manager: Yousef (Cloud & DevOps)
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'MGR-1004', 'Yousef', 'yousef@company.com', '01055556666',
        '2023-07-20', 'Cloud & Infrastructure Lead', 18500.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        2, 3, 1, 1, 3, 'ar', 0, 1, GETUTCDATE()
    );

    -- Get Manager IDs for ManagerId references
    DECLARE @MohamedId INT = (SELECT Id FROM Users WHERE Email = 'mohamed@company.com');
    DECLARE @KhaledId  INT = (SELECT Id FROM Users WHERE Email = 'khaled@company.com');
    DECLARE @OmarId    INT = (SELECT Id FROM Users WHERE Email = 'omar@company.com');

    -- Employee: Ahmed Kamal → under Mohamed
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'EMP-4092', 'Ahmed Kamal', 'ahmed.kamal@company.com', '01012345678',
        '2024-01-15', 'Senior Flutter Developer', 12000.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        1, 1, @MohamedId, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Employee: Sara Sami → under Mohamed
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'EMP-4095', 'Sara Sami', 'sara.sami@company.com', '01099887766',
        '2024-02-01', 'Lead UI/UX Designer', 11000.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        1, 1, @MohamedId, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Employee: Kareem Adel → under Khaled
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'EMP-5012', 'Kareem Adel', 'kareem.adel@company.com', '01233445566',
        '2024-03-10', 'QA Automation Engineer', 10500.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        1, 2, @KhaledId, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Employee: Mahmoud Reda → under Khaled
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'EMP-5020', 'Mahmoud Reda', 'mahmoud.reda@company.com', '01155667788',
        '2024-04-01', 'Software Quality Analyst', 10000.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        1, 2, @KhaledId, 1, 1, 'ar', 0, 1, GETUTCDATE()
    );

    -- Employee: Nouran Aly → under Omar (Alexandria)
    INSERT INTO Users (EmployeeCode, FullName, Email, Phone, HireDate, JobTitle,
                       MonthlySalary, PasswordHash, RoleId, DepartmentId, ManagerId, BranchId, ShiftId,
                       Language, MustChangePassword, IsActive, CreatedAt)
    VALUES (
        'EMP-6001', 'Nouran Aly', 'nouran.aly@company.com', '01277889900',
        '2024-05-15', 'Sales Representative', 9500.00,
        '$2a$11$KiH8w5EaHi/PThxl6.ghP.5UajZyqzAA6u/o1cBfOxmOO0MxUxFLq',
        1, 4, @OmarId, 2, 2, 'ar', 0, 1, GETUTCDATE()
    );
END
GO

-- ────────────────────────────────────────────────────────────
--  8. HOLIDAYS (Egyptian national holidays 2025)
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM Holidays)
BEGIN
    INSERT INTO Holidays (HolidayDate, Name) VALUES
        ('2025-01-07', 'Coptic Christmas'),
        ('2025-01-25', 'Police Day / Revolution Day'),
        ('2025-04-25', 'Sinai Liberation Day'),
        ('2025-05-01', 'Labour Day'),
        ('2025-06-30', 'June 30 Revolution'),
        ('2025-07-23', 'Revolution Day'),
        ('2025-10-06', 'Armed Forces Day');
END
GO

-- ────────────────────────────────────────────────────────────
--  VERIFY
-- ────────────────────────────────────────────────────────────
SELECT 'Roles'           AS [Table], COUNT(*) AS [Count] FROM Roles
UNION ALL
SELECT 'Departments',    COUNT(*) FROM Departments
UNION ALL
SELECT 'Branches',       COUNT(*) FROM Branches
UNION ALL
SELECT 'Shifts',         COUNT(*) FROM Shifts
UNION ALL
SELECT 'Users',          COUNT(*) FROM Users
UNION ALL
SELECT 'DeductionRules', COUNT(*) FROM DeductionRules
UNION ALL
SELECT 'Holidays',       COUNT(*) FROM Holidays;
GO
