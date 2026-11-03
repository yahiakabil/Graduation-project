using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WorkforceApi.Models;

// ─── Roles ───────────────────────────────────────────────────────────────────
public class Role
{
    [Key]
    public byte Id { get; set; }

    [Required, MaxLength(20)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(200)]
    public string Description { get; set; } = string.Empty;

    public ICollection<User> Users { get; set; } = [];
}

// ─── Departments ─────────────────────────────────────────────────────────────
public class Department
{
    [Key]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public ICollection<User> Users { get; set; } = [];
}

// ─── Branches ────────────────────────────────────────────────────────────────
public class Branch
{
    [Key]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(300)]
    public string? Address { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal Latitude { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal Longitude { get; set; }

    public int RadiusMeters { get; set; } = 50;

    [MaxLength(50)]
    public string? RouterBssid { get; set; }

    public bool IsActive { get; set; } = true;

    public ICollection<User> Users { get; set; } = [];
}

// ─── Shifts ──────────────────────────────────────────────────────────────────
public class Shift
{
    [Key]
    public int Id { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public int CheckInWindowBeforeMinutes { get; set; } = 30;

    public bool WorksSunday { get; set; }
    public bool WorksMonday { get; set; } = true;
    public bool WorksTuesday { get; set; } = true;
    public bool WorksWednesday { get; set; } = true;
    public bool WorksThursday { get; set; } = true;
    public bool WorksFriday { get; set; }
    public bool WorksSaturday { get; set; }

    public bool IsActive { get; set; } = true;

    public ICollection<User> Users { get; set; } = [];
    public ICollection<AttendanceRecord> AttendanceRecords { get; set; } = [];
}

// ─── Users ───────────────────────────────────────────────────────────────────
public class User
{
    [Key]
    public int Id { get; set; }

    [Required, MaxLength(20)]
    public string EmployeeCode { get; set; } = string.Empty;

    [Required, MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [Required, MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [MaxLength(20)]
    public string? Phone { get; set; }

    public DateOnly? DateOfBirth { get; set; }

    [MaxLength(10)]
    public string? Gender { get; set; }

    [MaxLength(14)]
    public string? NationalId { get; set; }

    [MaxLength(250)]
    public string? Address { get; set; }

    public DateOnly? HireDate { get; set; }

    [MaxLength(100)]
    public string? JobTitle { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal? MonthlySalary { get; set; }

    [Required, MaxLength(255)]
    public string PasswordHash { get; set; } = string.Empty;

    public byte RoleId { get; set; }
    public int? DepartmentId { get; set; }
    public int? ManagerId { get; set; }
    public int? BranchId { get; set; }
    public int? ShiftId { get; set; }

    [MaxLength(200)]
    public string? DeviceIdentifier { get; set; }

    [MaxLength(500)]
    public string? ProfilePhotoUrl { get; set; }

    [MaxLength(10)]
    public string Language { get; set; } = "ar";

    public bool MustChangePassword { get; set; } = false;
    public bool IsActive { get; set; } = true;

    public int FailedLoginCount { get; set; } = 0;
    public DateTime? LockoutUntil { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public Role Role { get; set; } = null!;
    public Department? Department { get; set; }
    public Branch? Branch { get; set; }
    public Shift? Shift { get; set; }
    public User? Manager { get; set; }

    public ICollection<User> Subordinates { get; set; } = [];
    public ICollection<AttendanceRecord> AttendanceRecords { get; set; } = [];
    public ICollection<Request> Requests { get; set; } = [];
    public ICollection<Notification> Notifications { get; set; } = [];
    public ICollection<Warning> Warnings { get; set; } = [];
    public ICollection<SuspiciousCheckIn> SuspiciousCheckIns { get; set; } = [];
    public ICollection<Payroll> Payrolls { get; set; } = [];
}

// ─── AttendanceRecords ───────────────────────────────────────────────────────
public class AttendanceRecord
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }
    public int? ShiftId { get; set; }

    public DateOnly AttendanceDate { get; set; }
    public DateTime? CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal? CheckInLatitude { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal? CheckInLongitude { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal? CheckOutLatitude { get; set; }

    [Column(TypeName = "decimal(9,6)")]
    public decimal? CheckOutLongitude { get; set; }

    public int LateMinutes { get; set; } = 0;

    [MaxLength(10)]
    public string Status { get; set; } = "Present";

    public bool MissedCheckOut { get; set; } = false;

    [MaxLength(500)]
    public string? Note { get; set; }

    public bool IsManualOverride { get; set; } = false;
    public int? ManualOverrideById { get; set; }

    [MaxLength(250)]
    public string? ManualOverrideReason { get; set; }

    [MaxLength(50)]
    public string? VerifiedBssid { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal? FaceLivenessScore { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public User? ManualOverrideBy { get; set; }
    public Shift? Shift { get; set; }
    public ICollection<DailyDeduction> DailyDeductions { get; set; } = [];
    public ICollection<PresenceCheck> PresenceChecks { get; set; } = [];
}

// ─── AttendancePolicy (singleton) ────────────────────────────────────────────
[Table("AttendancePolicy")]
public class AttendancePolicy
{
    [Key]
    public int Id { get; set; } = 1;
    public int FlagDaysPerMonth { get; set; } = 3;
    public int CorrectionWindowHours { get; set; } = 24;

    [Column(TypeName = "decimal(5,2)")]
    public decimal OvertimeRate { get; set; } = 1.50m;
}

// ─── DeductionRules ───────────────────────────────────────────────────────────
public class DeductionRule
{
    [Key]
    public int Id { get; set; }

    [Required, MaxLength(15)]
    public string Type { get; set; } = string.Empty;

    public int? FromMinutes { get; set; }
    public int? ToMinutes { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal DeductionValue { get; set; }

    [MaxLength(10)]
    public string DeductionUnit { get; set; } = "percent";

    [MaxLength(100)]
    public string Label { get; set; } = string.Empty;

    public ICollection<DailyDeduction> DailyDeductions { get; set; } = [];
}

// ─── DailyDeductions ─────────────────────────────────────────────────────────
public class DailyDeduction
{
    [Key]
    public int Id { get; set; }

    public int AttendanceRecordId { get; set; }
    public int RuleId { get; set; }

    [Column(TypeName = "decimal(6,2)")]
    public decimal DeductionValue { get; set; }

    [MaxLength(10)]
    public string DeductionUnit { get; set; } = "percent";

    [MaxLength(10)]
    public string Status { get; set; } = "Active";

    public int? CancelledByRequestId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public AttendanceRecord AttendanceRecord { get; set; } = null!;
    public DeductionRule Rule { get; set; } = null!;
    public Request? CancelledByRequest { get; set; }
}

// ─── Requests ────────────────────────────────────────────────────────────────
public class Request
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }

    [Required, MaxLength(15)]
    public string Type { get; set; } = string.Empty;

    [MaxLength(10)]
    public string? LeaveType { get; set; }

    [MaxLength(15)]
    public string? PermissionKind { get; set; }

    public int? RequestedMinutes { get; set; }
    public DateTime? RequestedCheckOutTime { get; set; }

    public DateOnly FromDate { get; set; }
    public DateOnly ToDate { get; set; }

    [MaxLength(500)]
    public string Reason { get; set; } = string.Empty;

    [MaxLength(10)]
    public string Status { get; set; } = "Pending";

    public int? DecidedById { get; set; }

    [MaxLength(500)]
    public string? DecisionComment { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DecidedAt { get; set; }

    // Helpers for CashAdvance parsed from Reason
    [NotMapped]
    public decimal? AdvanceAmount { get; set; }

    [NotMapped]
    public string? RepaymentSchedule { get; set; }

    public User User { get; set; } = null!;
    public User? DecidedBy { get; set; }
    public ICollection<DailyDeduction> CancelledDeductions { get; set; } = [];
}

// ─── PresenceChecks ───────────────────────────────────────────────────────────
public class PresenceCheck
{
    [Key]
    public int Id { get; set; }

    public int AttendanceRecordId { get; set; }
    public DateTime CheckedAt { get; set; }
    public DateTime? ReconnectTime { get; set; }

    [MaxLength(20)]
    public string Status { get; set; } = "inside";

    [MaxLength(250)]
    public string? Notes { get; set; }

    public AttendanceRecord AttendanceRecord { get; set; } = null!;
}

// ─── Payroll ─────────────────────────────────────────────────────────────────
[Table("Payroll")]
public class Payroll
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }
    public short PayYear { get; set; }
    public byte PayMonth { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal BaseSalary { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal DeductionAmount { get; set; }

    public int OvertimeMinutes { get; set; } = 0;

    [Column(TypeName = "decimal(10,2)")]
    public decimal OvertimeAmount { get; set; } = 0;

    [Column(TypeName = "decimal(10,2)")]
    public decimal NetSalary { get; set; }

    public User User { get; set; } = null!;
}

// ─── Notifications ────────────────────────────────────────────────────────────
public class Notification
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }

    [MaxLength(20)]
    public string Type { get; set; } = string.Empty;

    [MaxLength(100)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(500)]
    public string Body { get; set; } = string.Empty;

    public bool IsRead { get; set; } = false;
    public int? RelatedId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
}

// ─── SuspiciousCheckIns ───────────────────────────────────────────────────────
public class SuspiciousCheckIn
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }

    [MaxLength(20)]
    public string Type { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Details { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
}

// ─── Warnings ────────────────────────────────────────────────────────────────
public class Warning
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }
    public int IssuedById { get; set; }

    public DateOnly ForMonth { get; set; } = DateOnly.FromDateTime(DateTime.Today);
    public int DaysCounted { get; set; } = 1;

    [MaxLength(500)]
    public string Reason { get; set; } = string.Empty;

    public byte Level { get; set; } = 1;

    public bool IsAcknowledged { get; set; } = false;
    public DateTime? AcknowledgedAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public User User { get; set; } = null!;
    public User IssuedBy { get; set; } = null!;
}

// ─── Holidays ────────────────────────────────────────────────────────────────
public class Holiday
{
    [Key]
    public int Id { get; set; }

    public DateOnly HolidayDate { get; set; }

    [Required, MaxLength(100)]
    public string Name { get; set; } = string.Empty;
}

// ─── AuditLogs ────────────────────────────────────────────────────────────────
public class AuditLog
{
    [Key]
    public long Id { get; set; }

    public int ActorId { get; set; }

    [MaxLength(50)]
    public string Action { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Entity { get; set; } = string.Empty;

    public int? EntityId { get; set; }

    [MaxLength(100)]
    public string? FieldName { get; set; }

    [MaxLength(500)]
    public string? OldValue { get; set; }

    [MaxLength(500)]
    public string? NewValue { get; set; }

    [MaxLength(45)]
    public string? IpAddress { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
