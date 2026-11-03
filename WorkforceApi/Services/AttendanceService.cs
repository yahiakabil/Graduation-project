using Microsoft.EntityFrameworkCore;
using WorkforceApi.Data;
using WorkforceApi.DTOs;
using WorkforceApi.Models;

namespace WorkforceApi.Services;

public interface IAttendanceService
{
    Task<TodayAttendanceDto> GetTodayAsync(int userId);
    Task<AttendanceRecordDto> CheckInAsync(int userId, CheckInRequest req, string ipAddress);
    Task<AttendanceRecordDto> CheckOutAsync(int userId, CheckOutRequest req);
    Task<List<AttendanceRecordDto>> GetHistoryAsync(int userId, int days = 30);
    Task<List<AttendanceRecordDto>> GetTeamTodayAsync(int managerId);
    Task RecordPresenceCheckAsync(int userId, PresenceCheckDto dto);
    Task<AttendanceRecordDto> ManualCheckInAsync(int adminId, ManualCheckInDto dto);
}

public class AttendanceService(WorkforceDbContext db, ILocationService loc, INotificationService notify) : IAttendanceService
{
    public async Task<TodayAttendanceDto> GetTodayAsync(int userId)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);
        var rec = await db.AttendanceRecords
            .FirstOrDefaultAsync(a => a.UserId == userId && a.AttendanceDate == today);

        return new TodayAttendanceDto(
            CheckedIn: rec?.CheckInTime != null,
            CheckInTime: rec?.CheckInTime?.ToString("hh:mm tt"),
            CheckedOut: rec?.CheckOutTime != null,
            CheckOutTime: rec?.CheckOutTime?.ToString("hh:mm tt"),
            LateMinutes: rec?.LateMinutes ?? 0,
            Status: rec?.Status ?? "NotStarted",
            IsInsideBranch: false
        );
    }

    public async Task<AttendanceRecordDto> CheckInAsync(int userId, CheckInRequest req, string ipAddress)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);
        var existing = await db.AttendanceRecords
            .FirstOrDefaultAsync(a => a.UserId == userId && a.AttendanceDate == today);

        if (existing?.CheckInTime != null)
            throw new InvalidOperationException("Already checked in today.");

        // Fake location detection
        if (req.IsMockLocation == true)
        {
            await HandleFakeLocation(userId, "MockLocation", "Device mock location flag was active during check-in.", ipAddress);
            throw new InvalidOperationException("Fake/mock location detected. Check-in denied.");
        }

        var user = await db.Users
            .Include(u => u.Branch)
            .Include(u => u.Shift)
            .FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new KeyNotFoundException("User not found.");

        // Distance check
        if (user.Branch != null)
        {
            double dist = loc.CalculateDistance(req.Latitude, req.Longitude, (double)user.Branch.Latitude, (double)user.Branch.Longitude);
            if (dist > user.Branch.RadiusMeters)
            {
                await HandleFakeLocation(userId, "OutsideBranch",
                    $"Check-in from {dist:F0}m away from branch (allowed: {user.Branch.RadiusMeters}m). Lat:{req.Latitude},Lon:{req.Longitude}", ipAddress);
                throw new InvalidOperationException($"You are {dist:F0}m away from your branch. Check-in denied.");
            }
        }

        // Calculate lateness
        int lateMinutes = 0;
        string status = "Present";
        string? recordNote = null;
        if (user.Shift != null)
        {
            var shiftStart = user.Shift.StartTime;
            var now = TimeOnly.FromDateTime(DateTime.Now);
            var windowStart = shiftStart.AddMinutes(-user.Shift.CheckInWindowBeforeMinutes);

            if (now < windowStart)
                throw new InvalidOperationException($"Check-in not allowed before {windowStart:hh\\:mm}.");

            // Shift has ended (e.g. after 17:00)
            if (now > user.Shift.EndTime)
            {
                // Can only check in if explicitly flagged or handled for overtime/bonus
                status = "BonusShift";
                recordNote = $"After-Shift Check-In at {now:hh\\:mm tt} (Overtime/Bonus logged for Admin review)";
                
                if (user.ManagerId.HasValue)
                {
                    await notify.SendAsync(user.ManagerId.Value, "BonusShiftCheckIn",
                        $"⭐ {user.FullName} – After-Hours Check-In",
                        $"{user.FullName} checked in after shift end ({user.Shift.EndTime:hh\\:mm}) for bonus/overtime.");
                }
            }
            else if (now > shiftStart)
            {
                lateMinutes = (int)(now - shiftStart).TotalMinutes;
                status = "Late";
            }
        }

        var record = existing ?? new AttendanceRecord { UserId = userId, AttendanceDate = today };
        record.CheckInTime = DateTime.UtcNow;
        record.CheckInLatitude = (decimal)req.Latitude;
        record.CheckInLongitude = (decimal)req.Longitude;
        record.LateMinutes = lateMinutes;
        record.Status = status;
        record.ShiftId = user.ShiftId ?? 1;
        if (recordNote != null) record.Note = recordNote;

        if (existing == null) db.AttendanceRecords.Add(record);

        // Apply deduction rules if late
        if (lateMinutes > 0)
            await ApplyLatenessDeductionAsync(record, lateMinutes);

        // Notify manager if late
        if (lateMinutes > 0 && user.ManagerId.HasValue)
        {
            await notify.SendAsync(user.ManagerId.Value, "LateCheckIn",
                $"⏰ {user.FullName} is late",
                $"{user.FullName} checked in {lateMinutes} minutes late.");
        }

        await db.SaveChangesAsync();
        return MapRecord(record, user.FullName);
    }

    public async Task<AttendanceRecordDto> CheckOutAsync(int userId, CheckOutRequest req)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);
        var record = await db.AttendanceRecords
            .FirstOrDefaultAsync(a => a.UserId == userId && a.AttendanceDate == today)
            ?? throw new InvalidOperationException("No check-in found for today.");

        if (record.CheckInTime == null)
            throw new InvalidOperationException("Not checked in yet.");

        if (record.CheckOutTime != null)
            throw new InvalidOperationException("Already checked out.");

        record.CheckOutTime = DateTime.UtcNow;
        record.CheckOutLatitude = (decimal)req.Latitude;
        record.CheckOutLongitude = (decimal)req.Longitude;

        await db.SaveChangesAsync();

        var user = await db.Users.FindAsync(userId);
        return MapRecord(record, user?.FullName ?? "Unknown");
    }

    public async Task<List<AttendanceRecordDto>> GetHistoryAsync(int userId, int days = 30)
    {
        var from = DateOnly.FromDateTime(DateTime.Today.AddDays(-days));
        var records = await db.AttendanceRecords
            .Where(a => a.UserId == userId && a.AttendanceDate >= from)
            .OrderByDescending(a => a.AttendanceDate)
            .ToListAsync();

        var user = await db.Users.FindAsync(userId);
        return records.Select(r => MapRecord(r, user?.FullName ?? "")).ToList();
    }

    public async Task<List<AttendanceRecordDto>> GetTeamTodayAsync(int managerId)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);
        return await db.AttendanceRecords
            .Include(a => a.User)
            .Where(a => a.User.ManagerId == managerId && a.AttendanceDate == today)
            .Select(a => MapRecord(a, a.User.FullName))
            .ToListAsync();
    }

    public async Task RecordPresenceCheckAsync(int userId, PresenceCheckDto dto)
    {
        var today = DateOnly.FromDateTime(DateTime.Today);
        var record = await db.AttendanceRecords
            .FirstOrDefaultAsync(a => a.UserId == userId && a.AttendanceDate == today);

        if (record == null) return;

        // Detect fake location
        if (dto.IsMockLocation == true)
        {
            await HandleFakeLocation(userId, "MockLocation", "Mock location detected during presence check.");
        }

        var user = await db.Users.Include(u => u.Branch).FirstOrDefaultAsync(u => u.Id == userId);
        string checkStatus = "inside";

        if (user?.Branch != null)
        {
            double dist = loc.CalculateDistance(dto.Latitude, dto.Longitude, (double)user.Branch.Latitude, (double)user.Branch.Longitude);
            if (dist > user.Branch.RadiusMeters)
            {
                checkStatus = "outside";
                if (user.ManagerId.HasValue)
                {
                    await notify.SendAsync(user.ManagerId.Value, "OutsideBranch",
                        $"📍 {user.FullName} left branch",
                        $"{user.FullName} is {dist:F0}m outside branch radius.");
                }
            }
        }

        db.PresenceChecks.Add(new PresenceCheck
        {
            AttendanceRecordId = record.Id,
            CheckedAt = DateTime.UtcNow,
            Status = checkStatus
        });
        await db.SaveChangesAsync();
    }

    private async Task ApplyLatenessDeductionAsync(AttendanceRecord record, int lateMinutes)
    {
        var rule = await db.DeductionRules
            .Where(r => r.Type == "Lateness" && r.FromMinutes <= lateMinutes && r.ToMinutes >= lateMinutes)
            .FirstOrDefaultAsync();

        if (rule == null) return;

        db.DailyDeductions.Add(new DailyDeduction
        {
            AttendanceRecordId = record.Id,
            RuleId = rule.Id,
            DeductionValue = rule.DeductionValue,
            DeductionUnit = rule.DeductionUnit,
            Status = "Active"
        });
    }

    private async Task HandleFakeLocation(int userId, string type, string details, string? ipAddress = null)
    {
        db.SuspiciousCheckIns.Add(new SuspiciousCheckIn
        {
            UserId = userId,
            Type = type,
            Details = details
        });

        var user = await db.Users.FindAsync(userId);

        var admins = await db.Users.Where(u => u.RoleId == 3).ToListAsync();
        foreach (var admin in admins)
        {
            await notify.SendAsync(admin.Id, "FakeLocation",
                $"🚨 Fake Location Alert",
                $"{user?.FullName} attempted check-in with {type}. IP: {ipAddress ?? "unknown"}");
        }

        if (user?.ManagerId.HasValue == true)
        {
            await notify.SendAsync(user.ManagerId.Value, "FakeLocation",
                $"🚨 {user.FullName} – Fake Location",
                $"Employee attempted check-in with fake/spoofed location: {type}");
        }
    }

    public async Task<AttendanceRecordDto> ManualCheckInAsync(int adminId, ManualCheckInDto dto)
    {
        var user = await db.Users.FindAsync(dto.UserId);
        if (user == null)
            throw new InvalidOperationException("User not found.");

        var today = DateOnly.FromDateTime(DateTime.Today);
        var existing = await db.AttendanceRecords
            .FirstOrDefaultAsync(a => a.UserId == dto.UserId && a.AttendanceDate == today);

        var nowTime = DateTime.UtcNow;

        if (existing == null)
        {
            existing = new AttendanceRecord
            {
                UserId = dto.UserId,
                ShiftId = user.ShiftId ?? 1,
                AttendanceDate = today,
                CheckInTime = nowTime,
                Status = "OnTime",
                LateMinutes = 0,
                IsManualOverride = true,
                ManualOverrideById = adminId,
                ManualOverrideReason = dto.Reason,
                Note = $"Manual Check-In: {dto.Reason}",
            };
            db.AttendanceRecords.Add(existing);
        }
        else
        {
            existing.CheckInTime = nowTime;
            existing.Status = "OnTime";
            existing.LateMinutes = 0;
            existing.IsManualOverride = true;
            existing.ManualOverrideById = adminId;
            existing.ManualOverrideReason = dto.Reason;
            existing.Note = $"Manual Check-In: {dto.Reason}";
        }

        await db.SaveChangesAsync();
        return MapRecord(existing, user.FullName);
    }

    private static AttendanceRecordDto MapRecord(AttendanceRecord r, string fullName) => new(
        r.Id, r.UserId, fullName,
        r.AttendanceDate.ToString("yyyy-MM-dd"),
        r.CheckInTime?.ToString("hh:mm tt"),
        r.CheckOutTime?.ToString("hh:mm tt"),
        r.CheckInLatitude.HasValue ? (double)r.CheckInLatitude.Value : null,
        r.CheckInLongitude.HasValue ? (double)r.CheckInLongitude.Value : null,
        r.LateMinutes, r.Status,
        r.MissedCheckOut, r.Note
    );
}

public interface ILocationService
{
    double CalculateDistance(double lat1, double lon1, double lat2, double lon2);
}

public class LocationService : ILocationService
{
    public double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371000;
        double dLat = ToRad(lat2 - lat1);
        double dLon = ToRad(lon2 - lon1);
        double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
                 + Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2))
                 * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c;
    }

    private static double ToRad(double deg) => deg * Math.PI / 180.0;
}
