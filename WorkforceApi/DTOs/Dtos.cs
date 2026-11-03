namespace WorkforceApi.DTOs;

// ══════════════════════════════════════════════════════════════
//  AUTH DTOs
// ══════════════════════════════════════════════════════════════
public record LoginRequest(string Email, string Password, string? DeviceId = null);

public record LoginResponse(
    string Token,
    string TokenExpiry,
    UserProfileDto User
);

public record ChangePasswordRequest(string CurrentPassword, string NewPassword);

// ══════════════════════════════════════════════════════════════
//  USER / PROFILE DTOs
// ══════════════════════════════════════════════════════════════
public record UserProfileDto(
    int Id,
    string EmployeeCode,
    string FullName,
    string Email,
    string? Phone,
    string? JobTitle,
    string? Department,
    string? Branch,
    string? ShiftName,
    string? ShiftHours,
    string? ManagerName,
    byte RoleId,
    string RoleName,
    decimal MonthlySalary,
    string HireDate,
    bool MustChangePassword,
    bool IsActive,
    string? ProfilePhotoUrl = null,
    string? Address = null
);

public record CreateUserRequest(
    string FullName,
    string Email,
    string Password,
    string? Phone,
    string? JobTitle,
    decimal MonthlySalary,
    byte RoleId,
    int? DepartmentId,
    int? ManagerId,
    int? BranchId,
    int? ShiftId
);

public record UpdateUserRequest(
    string? FullName,
    string? Phone,
    string? JobTitle,
    string? Address,
    int? DepartmentId,
    int? ManagerId,
    int? BranchId,
    int? ShiftId,
    decimal? MonthlySalary
);

// ══════════════════════════════════════════════════════════════
//  ATTENDANCE DTOs
// ══════════════════════════════════════════════════════════════
public record CheckInRequest(
    double Latitude,
    double Longitude,
    bool? IsMockLocation = false,
    string? DeviceId = null
);

public record CheckOutRequest(
    double Latitude,
    double Longitude
);

public record AttendanceRecordDto(
    int Id,
    int UserId,
    string FullName,
    string AttendanceDate,
    string? CheckInTime,
    string? CheckOutTime,
    double? CheckInLat,
    double? CheckInLong,
    int LateMinutes,
    string Status,
    bool MissedCheckOut,
    string? Note,
    bool IsManualOverride = false,
    int? ManualOverrideById = null,
    string? ManualOverrideReason = null,
    string? VerifiedBssid = null,
    decimal? FaceLivenessScore = null
);

public record ManualCheckInDto(
    int UserId,
    string Reason,
    string? CheckInTime = null
);

public record TodayAttendanceDto(
    bool CheckedIn,
    string? CheckInTime,
    bool CheckedOut,
    string? CheckOutTime,
    int LateMinutes,
    string Status,
    bool IsInsideBranch
);

// ══════════════════════════════════════════════════════════════
//  REQUEST DTOs
// ══════════════════════════════════════════════════════════════
public record CreateRequestDto(
    string Type,           // Leave | Permission | Correction | CashAdvance | Early | ProfileUpdate
    string? LeaveType,     // annual | sick | emergency | unpaid
    string? PermissionKind,
    int? RequestedMinutes,
    string? FromDate,      // ISO date yyyy-MM-dd
    string? ToDate,
    string? Reason,
    decimal? AdvanceAmount,
    string? RepaymentSchedule,
    string? UpdatedPhone = null,
    string? UpdatedAddress = null
);

public record RequestDto(
    int Id,
    int UserId,
    string EmployeeName,
    string Type,
    string? LeaveType,
    string? FromDate,
    string? ToDate,
    string? Reason,
    decimal? AdvanceAmount,
    string Status,
    string? DecidedByName,
    string? DecisionComment,
    string CreatedAt,
    string? Department = null,
    string? EmployeeRole = null
);

public record DecideRequestDto(string Decision, string? Comment); // Decision = Approved | Rejected

// ══════════════════════════════════════════════════════════════
//  PAYROLL DTOs
// ══════════════════════════════════════════════════════════════
public record PayrollDto(
    int Id,
    int UserId,
    string FullName,
    int PayYear,
    int PayMonth,
    decimal BaseSalary,
    decimal DeductionAmount,
    int OvertimeMinutes,
    decimal OvertimeAmount,
    decimal NetSalary,
    string DepartmentName = ""
);

// ══════════════════════════════════════════════════════════════
//  NOTIFICATIONS DTOs
// ══════════════════════════════════════════════════════════════
public record NotificationDto(
    int Id,
    string Type,
    string Title,
    string Body,
    bool IsRead,
    string CreatedAt
);

// ══════════════════════════════════════════════════════════════
//  TEAM / MANAGER DTOs
// ══════════════════════════════════════════════════════════════
public record TeamMemberDto(
    int Id,
    string FullName,
    string EmployeeCode,
    string? JobTitle,
    string? Email,
    string TodayStatus,
    int LateMinutes,
    bool IsActive,
    string? ProfilePhotoUrl = null
);

public record IssueWarningDto(string Reason, int Level = 1);

public record AwardBonusDto(bool IsBonus, decimal Amount, string Reason);

// ══════════════════════════════════════════════════════════════
//  ADMIN / COMPANY DTOs
// ══════════════════════════════════════════════════════════════
public record DepartmentDto(int Id, string Name, bool IsActive);
public record BranchDto(int Id, string Name, string? Address, double Latitude, double Longitude, double RadiusMeters, string? RouterBssid = null);
public record ShiftDto(int Id, string Name, string StartTime, string EndTime);
public record DeductionRuleDto(int Id, string Type, int FromMinutes, int ToMinutes, decimal DeductionValue, string DeductionUnit, string? Label);

public record DeductionPolicyDto(
    string GracePeriod,
    string Tier1,
    string Tier2,
    string Tier3,
    string Tier4,
    string UnexcusedAbsence,
    string MissingCheckout,
    double GeofenceRadius,
    double OvertimeMultiplier
);

public record CreateDeductionRuleDto(
    string Type,
    int FromMinutes,
    int ToMinutes,
    decimal DeductionValue,
    string DeductionUnit,
    string? Label
);

public record SuspiciousCheckInDto(
    int Id,
    int UserId,
    string FullName,
    string Type,
    string? Details,
    string CreatedAt
);

public record WarningDto(
    int Id,
    int UserId,
    string EmployeeName,
    string IssuedByName,
    int Level,
    string Reason,
    bool IsAcknowledged,
    string CreatedAt
);

// ══════════════════════════════════════════════════════════════
//  PRESENCE CHECK DTO
// ══════════════════════════════════════════════════════════════
public record PresenceCheckDto(
    double Latitude,
    double Longitude,
    bool? IsMockLocation = false
);

// ══════════════════════════════════════════════════════════════
//  PAYROLL & BRANCH LOCATION DTOs
// ══════════════════════════════════════════════════════════════
public record DisbursementStatusDto(
    bool IsDisbursedToday,
    int DaysAccrued,
    string LastDisbursedDate,
    decimal DailyAccrualRate,
    decimal EstimatedAccruedNet,
    string StatusMessage
);

public record DisburseResultDto(
    bool Success,
    int DaysDisbursed,
    decimal AmountDisbursed,
    string Message
);

public record UpdateBranchLocationDto(
    double Latitude,
    double Longitude,
    double? RadiusMeters
);