using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using WorkforceApi.Models;

namespace WorkforceApi.Data;

public static class DatabaseSeeder
{
    private static readonly string[] FirstNames =
    [
        "Ahmed", "Mohamed", "Mahmoud", "Mostafa", "Hassan", "Ali", "Youssef", "Omar", "Khaled", "Amr",
        "Tarek", "Karim", "Hany", "Ibrahim", "Ziad", "Sherif", "Ramy", "Wael", "Eslam", "Sameh",
        "Hana", "Sara", "Nour", "Mona", "Salma", "Dina", "Laila", "Nouran", "Reem", "Aya",
        "Fatma", "Mariam", "Yasmine", "Nada", "Habiba", "Farida", "Hager", "Mai", "Donia", "Esraa"
    ];

    private static readonly string[] LastNames =
    [
        "Kamal", "Mostafa", "Hussien", "Othman", "Elroby", "Selim", "Sami", "Mahmoud", "Adel", "Shaker",
        "Nader", "Farouk", "Diab", "Mansour", "Essam", "Tamer", "Magdy", "Helmy", "Fouad", "Gaber",
        "Nabil", "Sobhy", "Kandil", "Radwan", "Emam", "Badawy", "Ghoneim", "Zaki", "Reda", "Aly"
    ];

    private static readonly string[] RolesDeptTitles =
    [
        "Software Engineer", "Frontend Specialist", "Backend Developer", "Mobile Flutter Developer", "DevOps Engineer",
        "UI/UX Designer", "Product Designer", "QA Automation Tester", "Quality Control Specialist", "Cloud Architect",
        "Corporate Account Exec", "B2B Sales Representative", "Customer Success Lead", "Support Operations Agent", "Technical Support"
    ];

    public static async Task SeedAsync(WorkforceDbContext db, ILogger logger)
    {
        try
        {
            logger.LogInformation("Checking database schema and constraints...");

            // 1. Drop check constraints that block custom deduction types and notifications
            try
            {
                await db.Database.ExecuteSqlRawAsync(@"
                    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_DeductionRules_Type')
                        ALTER TABLE DeductionRules DROP CONSTRAINT CK_DeductionRules_Type;
                    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Notifications_Type')
                        ALTER TABLE Notifications DROP CONSTRAINT CK_Notifications_Type;
                    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_AttendanceRecords_Status')
                        ALTER TABLE AttendanceRecords DROP CONSTRAINT CK_AttendanceRecords_Status;
                    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DisbursementLogs')
                        CREATE TABLE dbo.DisbursementLogs (
                            Id INT IDENTITY(1,1) PRIMARY KEY,
                            DisbursedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
                            DisbursedDate VARCHAR(10) NOT NULL,
                            AdminId INT NOT NULL,
                            DaysAccrued INT NOT NULL,
                            TotalAmount DECIMAL(18,2) NOT NULL,
                            Notes NVARCHAR(200) NULL
                        );
                    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_AttendanceRecords_Times')
                        ALTER TABLE AttendanceRecords DROP CONSTRAINT CK_AttendanceRecords_Times;
                ");
            }
            catch (Exception ex)
            {
                logger.LogWarning("Constraint drop raw SQL ignored: {Message}", ex.Message);
            }

            // 2. Ensure Roles
            if (!await db.Roles.AnyAsync())
            {
                db.Roles.AddRange(
                    new Role { Id = 1, Name = "Employee", Description = "Standard workforce staff member" },
                    new Role { Id = 2, Name = "Manager", Description = "Department leader & team supervisor" },
                    new Role { Id = 3, Name = "Admin", Description = "HR Executive & system administrator" }
                );
                await db.SaveChangesAsync();
            }

            // 3. Ensure 6 Departments
            var deptNames = new[]
            {
                "Mobile & Web Engineering",
                "Product Design & UX",
                "Quality Assurance & Testing",
                "Cloud Infrastructure & DevOps",
                "Sales & Corporate Growth",
                "Operations & Customer Care"
            };

            var existingDepts = await db.Departments.ToListAsync();
            for (int i = 0; i < deptNames.Length; i++)
            {
                var name = deptNames[i];
                if (!existingDepts.Any(d => d.Name.Equals(name, StringComparison.OrdinalIgnoreCase)))
                {
                    db.Departments.Add(new Department { Name = name, IsActive = true });
                }
            }
            await db.SaveChangesAsync();
            var departments = await db.Departments.OrderBy(d => d.Id).Take(6).ToListAsync();

            // 4. Ensure Branch 1
            var branch = await db.Branches.FirstOrDefaultAsync();
            if (branch == null)
            {
                branch = new Branch
                {
                    Name = "Cairo Technology Park (HQ)",
                    Address = "Building B-12, Smart Village, KM 28 Cairo-Alex Desert Road",
                    Latitude = 30.071400m,
                    Longitude = 30.985600m,
                    RadiusMeters = 100,
                    RouterBssid = "00:1A:2B:3C:4D:5E",
                    IsActive = true
                };
                db.Branches.Add(branch);
                await db.SaveChangesAsync();
            }

            // 5. Ensure Shift 1
            var shift = await db.Shifts.FirstOrDefaultAsync();
            if (shift == null)
            {
                shift = new Shift
                {
                    Name = "Core Business Shift (09:00 AM - 05:00 PM)",
                    StartTime = new TimeOnly(9, 0),
                    EndTime = new TimeOnly(17, 0),
                    CheckInWindowBeforeMinutes = 60,
                    WorksSunday = true,
                    WorksMonday = true,
                    WorksTuesday = true,
                    WorksWednesday = true,
                    WorksThursday = true,
                    WorksFriday = false,
                    WorksSaturday = false,
                    IsActive = true
                };
                db.Shifts.Add(shift);
                await db.SaveChangesAsync();
            }

            // 6. Ensure AttendancePolicy & Standard Deduction Rules
            if (!await db.AttendancePolicies.AnyAsync())
            {
                db.AttendancePolicies.Add(new AttendancePolicy
                {
                    FlagDaysPerMonth = 3,
                    CorrectionWindowHours = 24,
                    OvertimeRate = 1.50m
                });
                await db.SaveChangesAsync();
            }

            if (!await db.DeductionRules.AnyAsync())
            {
                db.DeductionRules.AddRange(
                    new DeductionRule { Type = "Lateness", FromMinutes = 1, ToMinutes = 15, DeductionValue = 0m, DeductionUnit = "percent", Label = "Grace period only" },
                    new DeductionRule { Type = "Lateness", FromMinutes = 16, ToMinutes = 60, DeductionValue = 1.00m, DeductionUnit = "percent", Label = "1.0 Hour deduction" },
                    new DeductionRule { Type = "Lateness", FromMinutes = 61, ToMinutes = 120, DeductionValue = 2.00m, DeductionUnit = "percent", Label = "2.0 Hours deduction" },
                    new DeductionRule { Type = "Lateness", FromMinutes = 121, ToMinutes = 240, DeductionValue = 4.00m, DeductionUnit = "percent", Label = "Half Day deduction" },
                    new DeductionRule { Type = "Lateness", FromMinutes = 241, ToMinutes = 999, DeductionValue = 8.00m, DeductionUnit = "percent", Label = "Full Day deduction" },
                    new DeductionRule { Type = "Absence", FromMinutes = 1, ToMinutes = 1, DeductionValue = 16.00m, DeductionUnit = "percent", Label = "2.0 Days deduction" },
                    new DeductionRule { Type = "EarlyLeave", FromMinutes = 1, ToMinutes = 999, DeductionValue = 4.00m, DeductionUnit = "percent", Label = "Half Day deduction (if not fixed in 24h)" }
                );
                await db.SaveChangesAsync();
            }

            // 7. Seed 100 Employees
            int currentEmpCount = await db.Users.CountAsync();
            if (currentEmpCount < 100)
            {
                logger.LogInformation("Current user count is {Count}. Seeding up to 100 employees across 6 teams...", currentEmpCount);

                string defaultHash = BCrypt.Net.BCrypt.HashPassword("password123", workFactor: 11);

                // Ensure Yahia Elroby (Admin / HR)
                var yahia = await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == "yahia@company.com" || u.Email.ToLower() == "yahia.elroby@company.com");
                if (yahia == null)
                {
                    yahia = new User
                    {
                        EmployeeCode = "EMP-001",
                        FullName = "Yahia Elroby",
                        Email = "yahia@company.com",
                        Phone = "01011223344",
                        NationalId = "29801010101234",
                        JobTitle = "Chief Human Resources Officer & Admin",
                        MonthlySalary = 65000m,
                        RoleId = 3, // Admin / HR
                        DepartmentId = departments[0].Id,
                        BranchId = branch.Id,
                        ShiftId = shift.Id,
                        PasswordHash = defaultHash,
                        IsActive = true
                    };
                    db.Users.Add(yahia);
                    await db.SaveChangesAsync();
                }

                // Ensure Ahmed Kamal (Employee in Dept 1)
                var ahmed = await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == "ahmed.kamal@company.com");
                if (ahmed == null)
                {
                    ahmed = new User
                    {
                        EmployeeCode = "EMP-007",
                        FullName = "Ahmed Kamal",
                        Email = "ahmed.kamal@company.com",
                        Phone = "01099887766",
                        NationalId = "29805051234567",
                        JobTitle = "Senior Flutter & Mobile Engineer",
                        MonthlySalary = 32000m,
                        RoleId = 1, // Employee
                        DepartmentId = departments[0].Id,
                        BranchId = branch.Id,
                        ShiftId = shift.Id,
                        PasswordHash = defaultHash,
                        IsActive = true
                    };
                    db.Users.Add(ahmed);
                    await db.SaveChangesAsync();
                }

                // Ensure Hana Mostafa (Employee in Dept 2)
                var hana = await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == "hana.mostafa@company.com");
                if (hana == null)
                {
                    hana = new User
                    {
                        EmployeeCode = "EMP-008",
                        FullName = "Hana Mostafa",
                        Email = "hana.mostafa@company.com",
                        Phone = "01122334455",
                        NationalId = "29906061234567",
                        JobTitle = "Senior Product & UX Designer",
                        MonthlySalary = 28000m,
                        RoleId = 1, // Employee
                        DepartmentId = departments[1].Id,
                        BranchId = branch.Id,
                        ShiftId = shift.Id,
                        PasswordHash = defaultHash,
                        IsActive = true
                    };
                    db.Users.Add(hana);
                    await db.SaveChangesAsync();
                }

                // Ensure 5 Department Leaders (Role 2)
                var mgrEmails = new[]
                {
                    ("Mohamed Hussien", "mohamed@company.com", "Engineering Team Director", 0, "01200000002"),
                    ("Sara Sami", "sara.sami@company.com", "Head of Product & Design", 1, "01200000003"),
                    ("Khaled Selim", "khaled@company.com", "Lead QA & Security Tester", 2, "01200000004"),
                    ("Omar Othman", "omar@company.com", "Cloud Infrastructure Lead", 3, "01200000005"),
                    ("Tarek Mahmoud", "tarek.mahmoud@company.com", "VP of Sales & Growth", 4, "01200000006")
                };

                var createdMgrs = new List<User>();
                int mgrCode = 2;
                foreach (var (name, email, title, deptIdx, phone) in mgrEmails)
                {
                    var mgr = await db.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());
                    if (mgr == null)
                    {
                        mgr = new User
                        {
                            EmployeeCode = $"EMP-00{mgrCode}",
                            FullName = name,
                            Email = email,
                            Phone = phone,
                            NationalId = $"29501010{mgrCode}0123",
                            JobTitle = title,
                            MonthlySalary = 45000m,
                            RoleId = 2, // Manager
                            DepartmentId = departments[deptIdx].Id,
                            BranchId = branch.Id,
                            ShiftId = shift.Id,
                            PasswordHash = defaultHash,
                            IsActive = true
                        };
                        db.Users.Add(mgr);
                        await db.SaveChangesAsync();
                    }
                    createdMgrs.Add(mgr);
                    mgrCode++;
                }

                // Populate remaining employees up to 100
                var existingUsers = await db.Users.ToListAsync();
                var existingEmails = new HashSet<string>(existingUsers.Select(u => u.Email.ToLower()));
                int needed = 100 - existingUsers.Count;

                int added = 0;
                int nameIdx = 0;
                while (added < needed && nameIdx < 300)
                {
                    string fName = FirstNames[nameIdx % FirstNames.Length];
                    string lName = LastNames[(nameIdx / FirstNames.Length + nameIdx) % LastNames.Length];
                    string email = $"{fName.ToLower()}.{lName.ToLower()}{(nameIdx > 40 ? (nameIdx % 10).ToString() : "")}@company.com";

                    nameIdx++;
                    if (existingEmails.Contains(email)) continue;
                    existingEmails.Add(email);

                    int deptIdx = added % 6;
                    var assignedDept = departments[deptIdx];
                    var assignedMgr = createdMgrs.FirstOrDefault(m => m.DepartmentId == assignedDept.Id);

                    int empNum = existingUsers.Count + added + 1;
                    string code = $"EMP-{empNum:D3}";
                    string phone = $"01{(nameIdx % 3 == 0 ? "0" : nameIdx % 3 == 1 ? "1" : "2")}{10000000 + nameIdx:D8}";
                    decimal salary = 16000m + ((nameIdx * 750) % 24000);

                    var newUser = new User
                    {
                        EmployeeCode = code,
                        FullName = $"{fName} {lName}",
                        Email = email,
                        Phone = phone,
                        NationalId = $"2990{nameIdx % 12 + 1:D2}{nameIdx % 28 + 1:D2}{1000 + nameIdx}",
                        JobTitle = RolesDeptTitles[nameIdx % RolesDeptTitles.Length],
                        MonthlySalary = salary,
                        RoleId = 1, // Employee
                        DepartmentId = assignedDept.Id,
                        ManagerId = assignedMgr?.Id,
                        BranchId = branch.Id,
                        ShiftId = shift.Id,
                        PasswordHash = defaultHash,
                        IsActive = true
                    };
                    db.Users.Add(newUser);
                    added++;
                }
                await db.SaveChangesAsync();
                logger.LogInformation("Successfully ensured 100 employees in database.");
            }

            // 8. Seed Attendance and Payroll covering August, September, October 2026
            await Seed3MonthsDataAsync(db, logger);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error while seeding database: {Message}", ex.Message);
        }
    }

    private static async Task Seed3MonthsDataAsync(WorkforceDbContext db, ILogger logger)
    {
        var users = await db.Users.Take(100).ToListAsync();
        if (users.Count == 0) return;

        var sampleUser = users[0];
        bool hasAugustAtt = await db.AttendanceRecords.AnyAsync(a => a.UserId == sampleUser.Id && a.AttendanceDate >= new DateOnly(2026, 8, 1) && a.AttendanceDate <= new DateOnly(2026, 8, 31));
        bool hasOctoberAtt = await db.AttendanceRecords.AnyAsync(a => a.UserId == sampleUser.Id && a.AttendanceDate >= new DateOnly(2026, 10, 1) && a.AttendanceDate <= new DateOnly(2026, 10, 31));

        if (!hasAugustAtt || !hasOctoberAtt)
        {
            logger.LogInformation("Seeding attendance records for 100 employees covering August, September, and October 2026...");

            var rng = new Random(42);
            var attBatch = new List<AttendanceRecord>();

            // Generate dates for August, September, October 2026
            var months = new[] { (2026, 8, 31), (2026, 9, 30), (2026, 10, 31) };

            foreach (var (year, month, daysInMonth) in months)
            {
                for (int d = 1; d <= daysInMonth; d++)
                {
                    var date = new DateOnly(year, month, d);
                    var dt = date.ToDateTime(TimeOnly.MinValue);
                    // Workdays in Egypt: Sunday (0) to Thursday (4). Friday (5) & Saturday (6) are weekend.
                    if (dt.DayOfWeek == DayOfWeek.Friday || dt.DayOfWeek == DayOfWeek.Saturday)
                        continue;

                    foreach (var user in users)
                    {
                        int roll = rng.Next(100);
                        string status;
                        DateTime? checkIn = null;
                        DateTime? checkOut = null;
                        int lateMinutes = 0;

                        if (roll < 80) // 80% On time
                        {
                            status = "Present";
                            int minOffset = rng.Next(0, 15);
                            checkIn = dt.AddHours(8).AddMinutes(50 + minOffset); // 08:50 - 09:05
                            checkOut = dt.AddHours(17).AddMinutes(rng.Next(5, 30)); // 17:05 - 17:30
                        }
                        else if (roll < 92) // 12% Late
                        {
                            status = "Present";
                            lateMinutes = rng.Next(16, 75);
                            checkIn = dt.AddHours(9).AddMinutes(lateMinutes);
                            checkOut = dt.AddHours(17).AddMinutes(rng.Next(0, 20));
                        }
                        else if (roll < 97) // 5% Early Leave / Permission
                        {
                            status = "Present";
                            checkIn = dt.AddHours(8).AddMinutes(55);
                            checkOut = dt.AddHours(14).AddMinutes(30); // Left at 2:30 PM
                        }
                        else // 3% Absent
                        {
                            status = "Absent";
                        }

                        attBatch.Add(new AttendanceRecord
                        {
                            UserId = user.Id,
                            ShiftId = user.ShiftId ?? 1,
                            AttendanceDate = date,
                            CheckInTime = checkIn,
                            CheckOutTime = checkOut,
                            CheckInLatitude = checkIn != null ? 30.071400m : null,
                            CheckInLongitude = checkIn != null ? 30.985600m : null,
                            CheckOutLatitude = checkOut != null ? 30.071400m : null,
                            CheckOutLongitude = checkOut != null ? 30.985600m : null,
                            LateMinutes = lateMinutes,
                            Status = status,
                            FaceLivenessScore = checkIn != null ? 0.98m : null,
                            CreatedAt = checkIn ?? dt.AddHours(9)
                        });

                        if (attBatch.Count >= 2000)
                        {
                            try
                            {
                                db.AttendanceRecords.AddRange(attBatch);
                                await db.SaveChangesAsync();
                            }
                            catch { }
                            attBatch.Clear();
                        }
                    }
                }
            }

            if (attBatch.Count > 0)
            {
                try
                {
                    db.AttendanceRecords.AddRange(attBatch);
                    await db.SaveChangesAsync();
                }
                catch { }
            }
            db.ChangeTracker.Clear();
            logger.LogInformation("Completed attendance seeding for August, September, October 2026.");
        }

        db.ChangeTracker.Clear();
        // 9. Ensure Payrolls for August, September, October 2026
        bool hasAugPayroll = await db.Payrolls.AnyAsync(p => p.PayYear == 2026 && p.PayMonth == 8);
        if (!hasAugPayroll)
        {
            logger.LogInformation("Generating 3-month payroll ledger for 100 employees...");
            var payrollList = new List<Payroll>();
            var months = new byte[] { 8, 9, 10 };

            foreach (var m in months)
            {
                foreach (var user in users)
                {
                    decimal baseSal = user.MonthlySalary ?? 20000m;
                    decimal dailyRate = baseSal / 30m;
                    decimal deduction = (m == 10) ? dailyRate * 0.5m : dailyRate * 1.0m;
                    decimal overtime = (m == 8 || m == 9) ? dailyRate * 1.5m : 0m;
                    decimal net = Math.Max(0, baseSal - deduction + overtime);

                    payrollList.Add(new Payroll
                    {
                        UserId = user.Id,
                        PayYear = 2026,
                        PayMonth = m,
                        BaseSalary = baseSal,
                        DeductionAmount = deduction,
                        OvertimeMinutes = overtime > 0 ? 360 : 0,
                        OvertimeAmount = overtime,
                        NetSalary = net
                    });
                }
            }

            try
            {
                db.Payrolls.AddRange(payrollList);
                await db.SaveChangesAsync();
                logger.LogInformation("Payroll ledger for August, September, and October 2026 saved.");
            }
            catch (Exception ex)
            {
                logger.LogWarning("Payroll seeding notice: {Message}", ex.Message);
            }
        }
    }
}
