using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WorkforceApi.Data;
using WorkforceApi.DTOs;
using WorkforceApi.Models;
using WorkforceApi.Services;

namespace WorkforceApi.Controllers;

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Users / HR Controller  â†’  /api/users
//  Admin can manage all. Manager can manage their own team.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
[ApiController]
[Route("api/users")]
[Authorize(Roles = "Manager,Admin")]
public class UsersController(WorkforceDbContext db, INotificationService notify) : ControllerBase
{
    private int CallerId => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    private byte CallerRole => byte.Parse(User.FindFirst("roleId")!.Value);

    /// <summary>GET /api/users â€” List users. Manager sees only their team. Admin sees all.</summary>
    [HttpGet]
    public async Task<ActionResult<List<UserProfileDto>>> GetAll()
    {
        IQueryable<User> q = db.Users.Include(u => u.Role)
            .Include(u => u.Department).Include(u => u.Branch)
            .Include(u => u.Shift).Include(u => u.Manager);

        if (CallerRole == 2) // Manager
            q = q.Where(u => u.ManagerId == CallerId);

        var users = await q.ToListAsync();
        return Ok(users.Select(AuthService.MapToProfile));
    }

    /// <summary>GET /api/users/{id}</summary>
    [HttpGet("{id:int}")]
    public async Task<ActionResult<UserProfileDto>> GetById(int id)
    {
        var user = await db.Users.Include(u => u.Role)
            .Include(u => u.Department).Include(u => u.Branch)
            .Include(u => u.Shift).Include(u => u.Manager)
            .FirstOrDefaultAsync(u => u.Id == id);

        if (user == null) return NotFound();
        if (CallerRole == 2 && user.ManagerId != CallerId) return Forbid();

        return Ok(AuthService.MapToProfile(user));
    }

    /// <summary>POST /api/users â€” HR/Admin creates new user</summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<UserProfileDto>> Create([FromBody] CreateUserRequest req)
    {
        if (await db.Users.AnyAsync(u => u.Email == req.Email))
            return BadRequest(new { message = "Email already registered." });

        // Auto-generate employee code
        int count = await db.Users.CountAsync();
        string code = $"EMP-{(count + 1001):D4}";

        var user = new User
        {
            FullName = req.FullName,
            Email = req.Email.ToLower().Trim(),
            Phone = req.Phone,
            JobTitle = req.JobTitle,
            MonthlySalary = req.MonthlySalary,
            RoleId = req.RoleId,
            DepartmentId = req.DepartmentId,
            ManagerId = req.ManagerId,
            BranchId = req.BranchId,
            ShiftId = req.ShiftId,
            EmployeeCode = code,
            HireDate = DateOnly.FromDateTime(DateTime.Today),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Welcome@123", workFactor: 11),
            MustChangePassword = true,
            Language = "ar"
        };

        db.Users.Add(user);
        await db.SaveChangesAsync();

        // Notify new user
        await notify.SendAsync(user.Id, "Welcome",
            "ðŸŽ‰ Welcome to Integrated Workforce!",
            $"Hi {user.FullName}, your account has been created. Please change your default password after first login.");

        db.AuditLogs.Add(new AuditLog
        {
            ActorId = CallerId,
            Action = "CreateUser",
            Entity = "User",
            EntityId = user.Id,
            NewValue = user.Email
        });
        await db.SaveChangesAsync();

        await db.Entry(user).Reference(u => u.Role).LoadAsync();
        return Created($"/api/users/{user.Id}", AuthService.MapToProfile(user));
    }

    /// <summary>PATCH /api/users/{id} â€” Update user details</summary>
    [HttpPatch("{id:int}")]
    public async Task<ActionResult<UserProfileDto>> Update(int id, [FromBody] UpdateUserRequest req)
    {
        var user = await db.Users.FindAsync(id);
        if (user == null) return NotFound();
        if (CallerRole == 2 && user.ManagerId != CallerId) return Forbid();

        if (req.FullName != null) user.FullName = req.FullName;
        if (req.Phone != null) user.Phone = req.Phone;
        if (req.JobTitle != null) user.JobTitle = req.JobTitle;
        if (req.Address != null) user.Address = req.Address;
        if (req.DepartmentId.HasValue) user.DepartmentId = req.DepartmentId;
        if (req.ManagerId.HasValue) user.ManagerId = req.ManagerId;
        if (req.BranchId.HasValue) user.BranchId = req.BranchId;
        if (req.ShiftId.HasValue) user.ShiftId = req.ShiftId;
        if (req.MonthlySalary.HasValue && CallerRole == 3) user.MonthlySalary = req.MonthlySalary.Value;

        await db.SaveChangesAsync();
        await db.Entry(user).Reference(u => u.Role).LoadAsync();
        await db.Entry(user).Reference(u => u.Department!).LoadAsync();
        await db.Entry(user).Reference(u => u.Branch!).LoadAsync();
        await db.Entry(user).Reference(u => u.Shift!).LoadAsync();
        await db.Entry(user).Reference(u => u.Manager!).LoadAsync();

        return Ok(AuthService.MapToProfile(user));
    }

    /// <summary>PUT /api/users/{id}/deactivate â€” Suspend/close account</summary>
    [HttpPut("{id:int}/deactivate")]
    public async Task<IActionResult> Deactivate(int id)
    {
        var user = await db.Users.FindAsync(id);
        if (user == null) return NotFound();
        if (CallerRole == 2 && user.ManagerId != CallerId) return Forbid();

        user.IsActive = false;
        db.AuditLogs.Add(new AuditLog
        {
            ActorId = CallerId,
            Action = "DeactivateUser",
            Entity = "User",
            EntityId = id
        });
        await db.SaveChangesAsync();
        return Ok(new { message = $"Account for {user.FullName} deactivated." });
    }

    /// <summary>PUT /api/users/{id}/activate</summary>
    [HttpPut("{id:int}/activate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Activate(int id)
    {
        var user = await db.Users.FindAsync(id);
        if (user == null) return NotFound();
        user.IsActive = true;
        await db.SaveChangesAsync();
        return Ok(new { message = $"Account for {user.FullName} activated." });
    }

    /// <summary>POST /api/users/{id}/warning â€” Issue a warning</summary>
    [HttpPost("{id:int}/warning")]
    public async Task<IActionResult> IssueWarning(int id, [FromBody] IssueWarningDto dto)
    {
        var target = await db.Users.FindAsync(id);
        if (target == null) return NotFound();
        if (CallerRole == 2 && target.ManagerId != CallerId) return Forbid();

        db.Warnings.Add(new Warning
        {
            UserId = id,
            IssuedById = CallerId,
            ForMonth = DateOnly.FromDateTime(DateTime.Today),
            DaysCounted = 1,
            Level = (byte)dto.Level,
            Reason = dto.Reason
        });

        await notify.SendAsync(id, "Warning",
            $"âš ï¸ Warning Issued (Level {dto.Level})",
            dto.Reason);

        await db.SaveChangesAsync();
        return Ok(new { message = "Warning issued." });
    }

    /// <summary>POST /api/users/{id}/bonus â€” Award bonus or deduction</summary>
    [HttpPost("{id:int}/bonus")]
    public async Task<IActionResult> AwardBonus(int id, [FromBody] AwardBonusDto dto)
    {
        var target = await db.Users.FindAsync(id);
        if (target == null) return NotFound();
        if (CallerRole == 2 && target.ManagerId != CallerId) return Forbid();

        string icon = dto.IsBonus ? "ðŸŽ" : "ðŸ’¸";
        string type = dto.IsBonus ? "Bonus" : "Deduction";

        await notify.SendAsync(id, type,
            $"{icon} {type} of {dto.Amount:C}",
            $"Reason: {dto.Reason}");

        db.AuditLogs.Add(new AuditLog
        {
            ActorId = CallerId,
            Action = type,
            Entity = "User",
            EntityId = id,
            NewValue = $"{(dto.IsBonus ? "+" : "-")}{dto.Amount:F2} â€“ {dto.Reason}"
        });

        await db.SaveChangesAsync();
        return Ok(new { message = $"{type} of {dto.Amount:C} sent to {target.FullName}." });
    }

    /// <summary>GET /api/users/suspicious â€” Admin: all suspicious check-ins</summary>
    [HttpGet("suspicious")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<SuspiciousCheckInDto>>> GetSuspicious()
    {
        return await db.SuspiciousCheckIns
            .Include(s => s.User)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new SuspiciousCheckInDto(
                s.Id, s.UserId, s.User.FullName,
                s.Type, s.Details, s.CreatedAt.ToString("o")))
            .ToListAsync();
    }

    /// <summary>GET /api/users/{id}/warnings â€” Warnings for an employee</summary>
    [HttpGet("{id:int}/warnings")]
    public async Task<ActionResult<List<WarningDto>>> GetWarnings(int id)
    {
        return await db.Warnings
            .Include(w => w.User)
            .Include(w => w.IssuedBy)
            .Where(w => w.UserId == id)
            .OrderByDescending(w => w.CreatedAt)
            .Select(w => new WarningDto(
                w.Id, w.UserId, w.User.FullName, w.IssuedBy.FullName,
                w.Level, w.Reason, w.IsAcknowledged, w.CreatedAt.ToString("o")))
            .ToListAsync();
    }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Admin Config Controller  â†’  /api/admin
//  Deduction rules, departments, branches, shifts
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public class AdminController(WorkforceDbContext db) : ControllerBase
{
    // â”€â”€ Deduction Rules â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    [HttpGet("rules")]
    public async Task<ActionResult<List<DeductionRuleDto>>> GetRules()
        => Ok(await db.DeductionRules.Select(r => Map(r)).ToListAsync());

    [HttpGet("rules/policy")]
    public async Task<ActionResult<DeductionPolicyDto>> GetDeductionPolicy()
    {
        var rules = await db.DeductionRules.ToListAsync();
        var branch = await db.Branches.FirstOrDefaultAsync();
        var policy = await db.AttendancePolicies.FirstOrDefaultAsync();

        var grace = rules.FirstOrDefault(r => r.Type == "Lateness" && r.FromMinutes <= 15);
        var tier1 = rules.FirstOrDefault(r => r.Type == "Lateness" && r.FromMinutes >= 16 && r.ToMinutes <= 60);
        var tier2 = rules.FirstOrDefault(r => r.Type == "Lateness" && r.FromMinutes >= 61 && r.ToMinutes <= 120);
        var tier3 = rules.FirstOrDefault(r => r.Type == "Lateness" && r.FromMinutes >= 121 && r.ToMinutes <= 240);
        var tier4 = rules.FirstOrDefault(r => r.Type == "Lateness" && r.FromMinutes >= 241);
        var unexcused = rules.FirstOrDefault(r => r.Type == "Absence");
        var missingCheckout = rules.FirstOrDefault(r => r.Type == "EarlyLeave" || r.Type == "MissingCheckout");

        return Ok(new DeductionPolicyDto(
            GracePeriod: grace?.Label ?? "0 min deduction",
            Tier1: tier1?.Label ?? "1.0 Hour deduction",
            Tier2: tier2?.Label ?? "2.0 Hours deduction",
            Tier3: tier3?.Label ?? "Half Day deduction",
            Tier4: tier4?.Label ?? "Full Day deduction",
            UnexcusedAbsence: unexcused?.Label ?? "2.0 Days deduction",
            MissingCheckout: missingCheckout?.Label ?? "Half Day deduction (if not fixed in 24h)",
            GeofenceRadius: branch != null ? (double)branch.RadiusMeters : 50.0,
            OvertimeMultiplier: policy != null ? (double)policy.OvertimeRate : 1.5
        ));
    }

    [HttpPost("rules/policy")]
    [HttpPut("rules/policy")]
    public async Task<IActionResult> SaveDeductionPolicy([FromBody] DeductionPolicyDto dto)
    {
        if (dto.GeofenceRadius > 0)
        {
            var branches = await db.Branches.ToListAsync();
            foreach (var b in branches)
            {
                b.RadiusMeters = (int)dto.GeofenceRadius;
            }
        }

        var policy = await db.AttendancePolicies.FirstOrDefaultAsync();
        if (policy == null)
        {
            policy = new AttendancePolicy { OvertimeRate = (decimal)dto.OvertimeMultiplier };
            db.AttendancePolicies.Add(policy);
        }
        else
        {
            policy.OvertimeRate = (decimal)dto.OvertimeMultiplier;
        }

        var existingRules = await db.DeductionRules.ToListAsync();

        void UpsertRule(string type, int fromMin, int toMin, decimal val, string unit, string label)
        {
            var r = existingRules.FirstOrDefault(x => x.Type == type && x.FromMinutes == fromMin && x.ToMinutes == toMin);
            if (r == null)
            {
                db.DeductionRules.Add(new DeductionRule
                {
                    Type = type,
                    FromMinutes = fromMin,
                    ToMinutes = toMin,
                    DeductionValue = val,
                    DeductionUnit = unit,
                    Label = label
                });
            }
            else
            {
                r.DeductionValue = val;
                r.DeductionUnit = unit;
                r.Label = label;
            }
        }

        decimal ParseDeductionValue(string label, decimal fallback)
        {
            var match = System.Text.RegularExpressions.Regex.Match(label, @"([0-9]+(\.[0-9]+)?)");
            if (match.Success && decimal.TryParse(match.Value, out var parsed))
            {
                return parsed;
            }
            return fallback;
        }

        UpsertRule("Lateness", 1, 15, 0.00m, "percent", dto.GracePeriod);
        UpsertRule("Lateness", 16, 60, ParseDeductionValue(dto.Tier1, 0.50m), "percent", dto.Tier1);
        UpsertRule("Lateness", 61, 120, ParseDeductionValue(dto.Tier2, 1.00m), "percent", dto.Tier2);
        UpsertRule("Lateness", 121, 240, ParseDeductionValue(dto.Tier3, 2.00m), "percent", dto.Tier3);
        UpsertRule("Lateness", 241, 999, ParseDeductionValue(dto.Tier4, 4.00m), "percent", dto.Tier4);
        UpsertRule("Absence", 1, 1, ParseDeductionValue(dto.UnexcusedAbsence, 3.50m), "percent", dto.UnexcusedAbsence);
        UpsertRule("EarlyLeave", 1, 999, ParseDeductionValue(dto.MissingCheckout, 2.00m), "percent", dto.MissingCheckout);

        try
        {
            await db.Database.ExecuteSqlRawAsync(@"
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_DeductionRules_Type')
                    ALTER TABLE DeductionRules DROP CONSTRAINT CK_DeductionRules_Type;");
        }
        catch { }

        try
        {
            await db.SaveChangesAsync();
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException?.Message.Contains("CK_DeductionRules_Type") == true)
        {
            // If constraint is active and cannot be unchecked on SQL Server instance,
            // map MissingCheckout to EarlyLeave (the valid constraint value for checkout/leaving rules)
            var mc = db.DeductionRules.Local.FirstOrDefault(x => x.Type == "MissingCheckout");
            if (mc != null) mc.Type = "EarlyLeave";
            await db.SaveChangesAsync();
        }

        return Ok(new { message = "Deduction rules and policies saved to database successfully." });
    }

    [HttpPost("rules")]
    public async Task<ActionResult<DeductionRuleDto>> CreateRule([FromBody] CreateDeductionRuleDto dto)
    {
        var rule = new DeductionRule
        {
            Type = dto.Type,
            FromMinutes = dto.FromMinutes,
            ToMinutes = dto.ToMinutes,
            DeductionValue = dto.DeductionValue,
            DeductionUnit = dto.DeductionUnit,
            Label = dto.Label
        };
        db.DeductionRules.Add(rule);
        await db.SaveChangesAsync();
        return Created($"/api/admin/rules/{rule.Id}", Map(rule));
    }

    [HttpPut("rules/{id:int}")]
    public async Task<ActionResult<DeductionRuleDto>> UpdateRule(int id, [FromBody] CreateDeductionRuleDto dto)
    {
        var rule = await db.DeductionRules.FindAsync(id);
        if (rule == null) return NotFound();
        rule.Type = dto.Type; rule.FromMinutes = dto.FromMinutes; rule.ToMinutes = dto.ToMinutes;
        rule.DeductionValue = dto.DeductionValue; rule.DeductionUnit = dto.DeductionUnit; rule.Label = dto.Label;
        await db.SaveChangesAsync();
        return Ok(Map(rule));
    }

    [HttpDelete("rules/{id:int}")]
    public async Task<IActionResult> DeleteRule(int id)
    {
        var rule = await db.DeductionRules.FindAsync(id);
        if (rule == null) return NotFound();
        db.DeductionRules.Remove(rule);
        await db.SaveChangesAsync();
        return NoContent();
    }

    // â”€â”€ Departments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    [HttpGet("departments")]
    public async Task<ActionResult<List<DepartmentDto>>> GetDepts()
        => Ok(await db.Departments.Select(d => new DepartmentDto(d.Id, d.Name, d.IsActive)).ToListAsync());

    [HttpPost("departments")]
    public async Task<ActionResult<DepartmentDto>> CreateDept([FromBody] string name)
    {
        var d = new Department { Name = name };
        db.Departments.Add(d);
        await db.SaveChangesAsync();
        return Created($"/api/admin/departments/{d.Id}", new DepartmentDto(d.Id, d.Name, d.IsActive));
    }

    // â”€â”€ Branches â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    [HttpGet("branches")]
    public async Task<ActionResult<List<BranchDto>>> GetBranches()
        => Ok(await db.Branches.Select(b => new BranchDto(
            b.Id, b.Name, b.Address, (double)b.Latitude, (double)b.Longitude, (double)b.RadiusMeters, b.RouterBssid)).ToListAsync());

    [HttpPost("branches")]
    public async Task<ActionResult<BranchDto>> CreateBranch([FromBody] BranchDto dto)
    {
        var b = new Branch
        {
            Name = dto.Name, Address = dto.Address,
            Latitude = (decimal)dto.Latitude, Longitude = (decimal)dto.Longitude,
            RadiusMeters = (int)dto.RadiusMeters,
            RouterBssid = dto.RouterBssid
        };
        db.Branches.Add(b);
        await db.SaveChangesAsync();
        return Created($"/api/admin/branches/{b.Id}", new BranchDto(b.Id, b.Name, b.Address, (double)b.Latitude, (double)b.Longitude, (double)b.RadiusMeters, b.RouterBssid));
    }

    [HttpGet("branches/current")]
    [AllowAnonymous]
    public async Task<ActionResult<BranchDto>> GetCurrentBranch()
    {
        var b = await db.Branches.FirstOrDefaultAsync();
        if (b == null) return NotFound();
        return Ok(new BranchDto(b.Id, b.Name, b.Address, (double)b.Latitude, (double)b.Longitude, (double)b.RadiusMeters, b.RouterBssid));
    }

    [HttpPost("branches/set-current-gps")]
    [HttpPut("branches/set-current-gps")]
    [AllowAnonymous]
    public async Task<IActionResult> SetCurrentBranchLocation([FromBody] UpdateBranchLocationDto dto)
    {
        var b = await db.Branches.FirstOrDefaultAsync();
        if (b == null)
        {
            b = new Branch
            {
                Name = "Main Office",
                Latitude = (decimal)dto.Latitude,
                Longitude = (decimal)dto.Longitude,
                RadiusMeters = dto.RadiusMeters.HasValue ? (int)dto.RadiusMeters.Value : 500,
                Address = "Active Office GPS Geofence"
            };
            db.Branches.Add(b);
        }
        else
        {
            b.Latitude = (decimal)dto.Latitude;
            b.Longitude = (decimal)dto.Longitude;
            if (dto.RadiusMeters.HasValue) b.RadiusMeters = (int)dto.RadiusMeters.Value;
        }
        await db.SaveChangesAsync();
        return Ok(new
        {
            message = "Branch office GPS coordinates updated successfully.",
            latitude = (double)b.Latitude,
            longitude = (double)b.Longitude,
            radiusMeters = b.RadiusMeters
        });
    }

    // â”€â”€ Shifts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    [HttpGet("shifts")]
    public async Task<ActionResult<List<ShiftDto>>> GetShifts()
        => Ok(await db.Shifts.Select(s => new ShiftDto(
            s.Id, s.Name, s.StartTime.ToString(), s.EndTime.ToString())).ToListAsync());

    // â”€â”€ Attendance Policy â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    [HttpGet("policy")]
    public async Task<ActionResult<AttendancePolicy>> GetPolicy()
    {
        var p = await db.AttendancePolicies.FindAsync(1);
        return p == null ? NotFound() : Ok(p);
    }

    [HttpPut("policy")]
    public async Task<IActionResult> UpdatePolicy([FromBody] AttendancePolicy dto)
    {
        var p = await db.AttendancePolicies.FindAsync(1);
        if (p == null) { db.AttendancePolicies.Add(dto); }
        else { p.FlagDaysPerMonth = dto.FlagDaysPerMonth; p.CorrectionWindowHours = dto.CorrectionWindowHours; p.OvertimeRate = dto.OvertimeRate; }
        await db.SaveChangesAsync();
        return Ok();
    }

    // â”€â”€ Audit Logs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    [HttpGet("audit")]
    public async Task<IActionResult> GetAuditLogs([FromQuery] int page = 1, [FromQuery] int size = 50)
    {
        var logs = await db.AuditLogs
            .OrderByDescending(l => l.CreatedAt)
            .Skip((page - 1) * size)
            .Take(size)
            .ToListAsync();
        return Ok(logs);
    }

    private static DeductionRuleDto Map(DeductionRule r) => new(
        r.Id, r.Type, r.FromMinutes ?? 0, r.ToMinutes ?? 0, r.DeductionValue, r.DeductionUnit, r.Label);
}
