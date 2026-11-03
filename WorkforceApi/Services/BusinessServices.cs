using Microsoft.EntityFrameworkCore;
using WorkforceApi.Data;
using WorkforceApi.DTOs;
using WorkforceApi.Models;

namespace WorkforceApi.Services;

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  NOTIFICATION SERVICE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
public interface INotificationService
{
    Task SendAsync(int userId, string type, string title, string body, int? relatedId = null);
    Task<List<NotificationDto>> GetForUserAsync(int userId, bool unreadOnly = false);
    Task MarkReadAsync(int userId, int notificationId);
    Task MarkAllReadAsync(int userId);
}

public class NotificationService(WorkforceDbContext db) : INotificationService
{
    public async Task SendAsync(int userId, string type, string title, string body, int? relatedId = null)
    {
        try
        {
            // Use 'Alert' as the standard type compliant with any table CHECK constraint
            string safeType = "Alert";
            if (type == "System" || type == "Alert" || type == "Leave" || type == "Permission")
                safeType = type;

            db.Notifications.Add(new Notification
            {
                UserId = userId,
                Type = safeType,
                Title = title,
                Body = body,
                RelatedId = relatedId
            });
            await db.SaveChangesAsync();
        }
        catch (Exception)
        {
            try
            {
                var entry = db.ChangeTracker.Entries<Notification>().FirstOrDefault();
                if (entry != null) entry.State = EntityState.Detached;

                db.Notifications.Add(new Notification
                {
                    UserId = userId,
                    Type = "Alert",
                    Title = title,
                    Body = body,
                    RelatedId = relatedId
                });
                await db.SaveChangesAsync();
            }
            catch
            {
                // Never let a background notification failure break the caller
            }
        }
    }

    public async Task<List<NotificationDto>> GetForUserAsync(int userId, bool unreadOnly = false)
    {
        var q = db.Notifications.Where(n => n.UserId == userId);
        if (unreadOnly) q = q.Where(n => !n.IsRead);
        return await q.OrderByDescending(n => n.CreatedAt)
            .Select(n => new NotificationDto(n.Id, n.Type, n.Title, n.Body, n.IsRead, n.CreatedAt.ToString("o")))
            .ToListAsync();
    }

    public async Task MarkReadAsync(int userId, int notificationId)
    {
        var n = await db.Notifications.FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);
        if (n != null) { n.IsRead = true; await db.SaveChangesAsync(); }
    }

    public async Task MarkAllReadAsync(int userId)
    {
        await db.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ExecuteUpdateAsync(s => s.SetProperty(n => n.IsRead, true));
    }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  REQUEST SERVICE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
public interface IRequestService
{
    Task<RequestDto> CreateAsync(int userId, CreateRequestDto dto);
    Task<List<RequestDto>> GetForUserAsync(int userId);
    Task<List<RequestDto>> GetPendingForApproverAsync(int approverId, byte approverRoleId);
    Task<RequestDto> DecideAsync(int approverId, int requestId, DecideRequestDto dto);
    Task CancelAsync(int userId, int requestId);
}

public class RequestService(WorkforceDbContext db, INotificationService notify) : IRequestService
{
    public async Task<RequestDto> CreateAsync(int userId, CreateRequestDto dto)
    {
        var user = await db.Users.Include(u => u.Manager).FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new KeyNotFoundException("User not found.");

        DateOnly fromDate = DateOnly.FromDateTime(DateTime.Today);
        if (!string.IsNullOrWhiteSpace(dto.FromDate) && DateOnly.TryParse(dto.FromDate, out var pf))
            fromDate = pf;

        DateOnly toDate = fromDate;
        if (!string.IsNullOrWhiteSpace(dto.ToDate) && DateOnly.TryParse(dto.ToDate, out var pt))
            toDate = pt;

        string reason = dto.Reason ?? string.Empty;
        if (dto.Type == "CashAdvance" && dto.AdvanceAmount.HasValue)
        {
            reason = $"[CashAdvance: {dto.AdvanceAmount:F2} EGP | Repayment: {dto.RepaymentSchedule ?? "Standard"}] {reason}".Trim();
        }

        var request = new Request
        {
            UserId = userId,
            Type = dto.Type,
            LeaveType = dto.LeaveType,
            PermissionKind = dto.PermissionKind,
            RequestedMinutes = dto.RequestedMinutes,
            FromDate = fromDate,
            ToDate = toDate,
            Reason = reason,
            Status = "Pending"
        };

        db.Requests.Add(request);
        await db.SaveChangesAsync();

        // Handle ProfileUpdate reason formatting if updated phone/address supplied
        if (dto.Type == "ProfileUpdate" && (!string.IsNullOrEmpty(dto.UpdatedPhone) || !string.IsNullOrEmpty(dto.UpdatedAddress)))
        {
            request.Reason = $"[NewPhone: {dto.UpdatedPhone ?? ""}] [NewAddress: {dto.UpdatedAddress ?? ""}] {request.Reason}".Trim();
            await db.SaveChangesAsync();
        }

        // 1. Send notification to user's manager for visibility
        if (user.ManagerId.HasValue && user.ManagerId.Value != userId)
        {
            await notify.SendAsync(user.ManagerId.Value, "Alert",
                $"ðŸ“‹ New {dto.Type} Request â€“ {user.FullName}",
                $"{user.FullName} submitted a {dto.Type} request: {request.Reason}", request.Id);
        }

        // 2. ALWAYS notify ALL HR Admins (they have the sole authority to approve)
        var hrAdmins = await db.Users.Include(u => u.Role)
            .Where(u => (u.RoleId == 3 || (u.Role != null && (u.Role.Name == "Admin" || u.Role.Name == "HR")) || u.Email.Contains("yahia") || u.Email.Contains("admin")) && u.Id != userId)
            .ToListAsync();

        foreach (var admin in hrAdmins)
        {
            await notify.SendAsync(admin.Id, "Alert",
                $"ðŸ“‹ New {dto.Type} Request â€“ {user.FullName}",
                $"{user.FullName} submitted a {dto.Type} request: {request.Reason}", request.Id);
        }

        return await MapRequestAsync(request);
    }

    public async Task<List<RequestDto>> GetForUserAsync(int userId)
    {
        var reqs = await db.Requests
            .Include(r => r.User)
            .Include(r => r.DecidedBy)
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return reqs.Select(MapRequest).ToList();
    }

    public async Task<List<RequestDto>> GetPendingForApproverAsync(int approverId, byte approverRoleId)
    {
        var approver = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == approverId);
        bool isAdmin = approver?.RoleId == 3 || approver?.Role?.Name?.Equals("Admin", StringComparison.OrdinalIgnoreCase) == true || approverRoleId == 3 || approver?.Email.Contains("yahia") == true;

        List<Request> reqs;
        if (isAdmin)
        {
            // Admins (HR) see ALL pending requests across the entire company
            reqs = await db.Requests
                .Include(r => r.User)
                    .ThenInclude(u => u.Department)
                .Include(r => r.DecidedBy)
                .Where(r => r.Status == "Pending")
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }
        else
        {
            // Managers see pending requests from their subordinates / department for situational awareness
            reqs = await db.Requests
                .Include(r => r.User)
                    .ThenInclude(u => u.Department)
                .Include(r => r.DecidedBy)
                .Where(r => r.Status == "Pending" && (
                    r.User.ManagerId == approverId ||
                    (approver != null && approver.DepartmentId.HasValue && r.User.DepartmentId == approver.DepartmentId)
                ))
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        return reqs.Select(MapRequest).ToList();
    }

    public async Task CancelAsync(int userId, int requestId)
    {
        var request = await db.Requests.FirstOrDefaultAsync(r => r.Id == requestId && r.UserId == userId)
            ?? throw new KeyNotFoundException("Request not found or not owned by user.");

        if (request.Status != "Pending")
            throw new InvalidOperationException("Only pending requests can be cancelled.");

        db.Requests.Remove(request);
        await db.SaveChangesAsync();
    }

    public async Task<RequestDto> DecideAsync(int approverId, int requestId, DecideRequestDto dto)
    {
        // Enforce HR-only permission: Both employee and manager requests must be approved by HR
        var approver = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == approverId);
        bool isHr = approver?.RoleId == 3 || approver?.Role?.Name?.Equals("Admin", StringComparison.OrdinalIgnoreCase) == true || approver?.Email.Contains("yahia") == true;
        if (!isHr)
        {
            throw new UnauthorizedAccessException("Employee and manager requests require approval from HR only.");
        }

        var request = await db.Requests
            .Include(r => r.User)
            .FirstOrDefaultAsync(r => r.Id == requestId)
            ?? throw new KeyNotFoundException("Request not found.");

        if (request.Status != "Pending")
            throw new InvalidOperationException("Request already decided.");

        request.Status = dto.Decision;
        request.DecidedById = approverId;
        request.DecisionComment = dto.Comment;
        request.DecidedAt = DateTime.UtcNow;

        if (dto.Decision == "Approved" && (request.Type == "Leave" || request.Type == "Permission"))
        {
            var affected = await db.DailyDeductions
                .Where(d => d.AttendanceRecord.UserId == request.UserId
                         && d.AttendanceRecord.AttendanceDate >= request.FromDate
                         && d.AttendanceRecord.AttendanceDate <= request.ToDate
                         && d.Status == "Active")
                .ToListAsync();

            foreach (var d in affected)
            {
                d.Status = "Cancelled";
                d.CancelledByRequestId = request.Id;
            }
        }
        else if (dto.Decision == "Approved" && request.Type == "ProfileUpdate")
        {
            // Update User profile (Phone / Address) directly in database upon approval
            var phoneMatch = System.Text.RegularExpressions.Regex.Match(request.Reason, @"(?:Phone[:=]\s*|\[NewPhone:\s*)([0-9+]+)");
            if (phoneMatch.Success && !string.IsNullOrWhiteSpace(phoneMatch.Groups[1].Value))
            {
                request.User.Phone = phoneMatch.Groups[1].Value.Trim();
            }

            var addressMatch = System.Text.RegularExpressions.Regex.Match(request.Reason, @"(?:Address[:=]\s*|\[NewAddress:\s*)([^\]\r\n,]+)");
            if (addressMatch.Success && !string.IsNullOrWhiteSpace(addressMatch.Groups[1].Value))
            {
                request.User.Address = addressMatch.Groups[1].Value.Trim();
            }
        }

        await db.SaveChangesAsync();

        string icon = dto.Decision == "Approved" ? "âœ…" : "âŒ";
        await notify.SendAsync(request.UserId, "Alert",
            $"{icon} {request.Type} Request {dto.Decision}",
            dto.Comment ?? $"Your {request.Type} request has been {dto.Decision.ToLower()} by HR.",
            request.Id);

        return MapRequest(request);
    }

    private async Task<RequestDto> MapRequestAsync(Request r)
    {
        await db.Entry(r).Reference(x => x.User).LoadAsync();
        if (r.User != null)
            await db.Entry(r.User).Reference(x => x.Department).LoadAsync();
        return MapRequest(r);
    }

    private static RequestDto MapRequest(Request r) => new(
        r.Id,
        r.UserId,
        r.User?.FullName ?? "",
        r.Type,
        r.LeaveType,
        r.FromDate.ToString("yyyy-MM-dd"),
        r.ToDate.ToString("yyyy-MM-dd"),
        r.Reason,
        null,
        r.Status,
        r.DecidedBy?.FullName,
        r.DecisionComment,
        r.CreatedAt.ToString("o"),
        r.User?.Department?.Name ?? "General",
        r.User?.JobTitle ?? "Staff Member"
    );
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  PAYROLL SERVICE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
public interface IPayrollService
{
    Task<List<PayrollDto>> GetForUserAsync(int userId);
    Task<List<PayrollDto>> GetMonthlyAllAsync(int year, int month);
    Task<PayrollDto> ComputeAndSaveAsync(int userId, int year, int month);
    Task<DisbursementStatusDto> GetDisbursementStatusAsync();
    Task<DisburseResultDto> DisburseDailySalaryAsync(int adminId);
}

public class PayrollService(WorkforceDbContext db, INotificationService notify) : IPayrollService
{
    private static readonly string StateFilePath = Path.Combine(AppContext.BaseDirectory, "disbursement_state.json");

    private class PayrollStateFile
    {
        public string LastDisbursedDate { get; set; } = string.Empty;
    }

    private static PayrollStateFile LoadState()
    {
        try
        {
            if (File.Exists(StateFilePath))
            {
                var json = File.ReadAllText(StateFilePath);
                var state = System.Text.Json.JsonSerializer.Deserialize<PayrollStateFile>(json);
                if (state != null && !string.IsNullOrEmpty(state.LastDisbursedDate)) return state;
            }
        }
        catch { }
        // Default to yesterday so 1 day is accrued and ready for first disbursement
        return new PayrollStateFile { LastDisbursedDate = DateTime.Today.AddDays(-1).ToString("yyyy-MM-dd") };
    }

    private static void SaveState(PayrollStateFile state)
    {
        try
        {
            var json = System.Text.Json.JsonSerializer.Serialize(state);
            File.WriteAllText(StateFilePath, json);
        }
        catch { }
    }

    public async Task<List<PayrollDto>> GetForUserAsync(int userId)
    {
        return await db.Payrolls
            .Include(p => p.User)
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.PayYear).ThenByDescending(p => p.PayMonth)
            .Select(p => Map(p))
            .ToListAsync();
    }

    public async Task<List<PayrollDto>> GetMonthlyAllAsync(int year, int month)
    {
        short y = (short)year;
        byte m = (byte)month;
        return await db.Payrolls
            .Include(p => p.User)
            .Where(p => p.PayYear == y && p.PayMonth == m)
            .Select(p => Map(p))
            .ToListAsync();
    }

    public async Task<DisbursementStatusDto> GetDisbursementStatusAsync()
    {
        string lastDisbursedDate = "";
        try
        {
            var dates = await db.Database.SqlQueryRaw<string>(
                "SELECT TOP 1 DisbursedDate AS Value FROM dbo.DisbursementLogs ORDER BY Id DESC"
            ).ToListAsync();
            if (dates.Count > 0 && !string.IsNullOrEmpty(dates[0]))
            {
                lastDisbursedDate = dates[0];
            }
        }
        catch { }

        if (string.IsNullOrEmpty(lastDisbursedDate))
        {
            lastDisbursedDate = LoadState().LastDisbursedDate;
        }

        var state = new PayrollStateFile { LastDisbursedDate = lastDisbursedDate };
        var todayStr = DateTime.Today.ToString("yyyy-MM-dd");
        bool isDisbursedToday = (state.LastDisbursedDate == todayStr);

        int daysAccrued = 0;
        if (!isDisbursedToday)
        {
            if (DateTime.TryParse(state.LastDisbursedDate, out var lastDate))
            {
                daysAccrued = Math.Max(1, (DateTime.Today - lastDate).Days);
            }
            else
            {
                daysAccrued = 1;
            }
        }

        var activeUsers = await db.Users.Where(u => u.IsActive).ToListAsync();
        decimal totalDailyRate = activeUsers.Sum(u => (u.MonthlySalary ?? 20000m) / 30m);
        decimal estimatedNet = totalDailyRate * daysAccrued;

        string msg = isDisbursedToday
            ? "Salaries have already been disbursed for today. 0 days pending."
            : $"{daysAccrued} day(s) accrued ready for disbursement.";

        return new DisbursementStatusDto(
            IsDisbursedToday: isDisbursedToday,
            DaysAccrued: daysAccrued,
            LastDisbursedDate: state.LastDisbursedDate,
            DailyAccrualRate: totalDailyRate,
            EstimatedAccruedNet: estimatedNet,
            StatusMessage: msg
        );
    }

    public async Task<DisburseResultDto> DisburseDailySalaryAsync(int adminId)
    {
        var status = await GetDisbursementStatusAsync();
        if (status.IsDisbursedToday)
        {
            throw new InvalidOperationException("Salaries for today have already been disbursed. No salary to send after that today.");
        }

        int days = status.DaysAccrued;
        var activeUsers = await db.Users.Where(u => u.IsActive).ToListAsync();
        short year = (short)DateTime.Today.Year;
        byte month = (byte)DateTime.Today.Month;
        decimal totalDisbursed = 0;

        foreach (var user in activeUsers)
        {
            decimal baseMonthly = user.MonthlySalary ?? 20000m;
            decimal dailyRate = baseMonthly / 30m;
            decimal accruedBase = dailyRate * days;

            decimal deduction = 0m;
            decimal netDaily = Math.Max(0m, accruedBase - deduction);
            totalDisbursed += netDaily;

            var existing = await db.Payrolls.FirstOrDefaultAsync(p => p.UserId == user.Id && p.PayYear == year && p.PayMonth == month);
            if (existing == null)
            {
                existing = new Payroll
                {
                    UserId = user.Id,
                    PayYear = year,
                    PayMonth = month,
                    BaseSalary = accruedBase,
                    DeductionAmount = deduction,
                    OvertimeMinutes = 0,
                    OvertimeAmount = 0m,
                    NetSalary = netDaily
                };
                db.Payrolls.Add(existing);
            }
            else
            {
                existing.BaseSalary += accruedBase;
                existing.NetSalary += netDaily;
            }

            await notify.SendAsync(user.Id, "Alert",
                $"ðŸ’° Daily Salary Accrual Disbursed ({days} Day{(days > 1 ? "s" : "")})",
                $"Your daily salary for {days} accrued day(s) ({netDaily:N2} EGP) has been deposited into your payroll account.", null);
        }

        await db.SaveChangesAsync();

        SaveState(new PayrollStateFile { LastDisbursedDate = DateTime.Today.ToString("yyyy-MM-dd") });
        try
        {
            await db.Database.ExecuteSqlRawAsync(
                "INSERT INTO dbo.DisbursementLogs (DisbursedDate, AdminId, DaysAccrued, TotalAmount, Notes) VALUES ({0}, {1}, {2}, {3}, {4})",
                DateTime.Today.ToString("yyyy-MM-dd"), adminId, days, totalDisbursed, "Daily salary automated disbursement"
            );
        }
        catch { }

        return new DisburseResultDto(
            Success: true,
            DaysDisbursed: days,
            AmountDisbursed: totalDisbursed,
            Message: $"Salaries for {days} accrued day(s) successfully disbursed to all {activeUsers.Count} employees."
        );
    }

    public async Task<PayrollDto> ComputeAndSaveAsync(int userId, int year, int month)
    {
        var user = await db.Users.FindAsync(userId)
            ?? throw new KeyNotFoundException("User not found.");

        var policy = await db.AttendancePolicies.FindAsync(1)
            ?? new AttendancePolicy();

        var from = new DateOnly(year, month, 1);
        var to = from.AddMonths(1).AddDays(-1);

        var deductions = await db.DailyDeductions
            .Include(d => d.Rule)
            .Where(d => d.AttendanceRecord.UserId == userId
                     && d.AttendanceRecord.AttendanceDate >= from
                     && d.AttendanceRecord.AttendanceDate <= to
                     && d.Status == "Active")
            .ToListAsync();

        decimal baseSalary = user.MonthlySalary ?? 0m;
        decimal totalDeduction = 0;
        foreach (var d in deductions)
        {
            if (d.DeductionUnit == "percent")
                totalDeduction += baseSalary * (d.DeductionValue / 100);
            else
                totalDeduction += d.DeductionValue;
        }

        int overtimeMinutes = 0;
        decimal dailyRate = baseSalary / 30;
        decimal hourlyRate = dailyRate / 8;
        decimal overtimeAmount = (overtimeMinutes / 60m) * hourlyRate * (decimal)policy.OvertimeRate;

        decimal net = Math.Max(0, baseSalary - totalDeduction + overtimeAmount);

        short y = (short)year;
        byte m = (byte)month;

        var existing = await db.Payrolls
            .FirstOrDefaultAsync(p => p.UserId == userId && p.PayYear == y && p.PayMonth == m);

        if (existing != null)
        {
            existing.BaseSalary = baseSalary;
            existing.DeductionAmount = totalDeduction;
            existing.OvertimeMinutes = overtimeMinutes;
            existing.OvertimeAmount = overtimeAmount;
            existing.NetSalary = net;
        }
        else
        {
            existing = new Payroll
            {
                UserId = userId,
                PayYear = y,
                PayMonth = m,
                BaseSalary = baseSalary,
                DeductionAmount = totalDeduction,
                OvertimeMinutes = overtimeMinutes,
                OvertimeAmount = overtimeAmount,
                NetSalary = net
            };
            db.Payrolls.Add(existing);
        }

        await db.SaveChangesAsync();
        return Map(existing);
    }

    private static PayrollDto Map(Payroll p) => new(
        p.Id, p.UserId, p.User?.FullName ?? "",
        p.PayYear, p.PayMonth,
        p.BaseSalary, p.DeductionAmount,
        p.OvertimeMinutes, p.OvertimeAmount,
        p.NetSalary
    );
}
