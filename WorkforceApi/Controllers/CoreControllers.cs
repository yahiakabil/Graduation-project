using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WorkforceApi.DTOs;
using WorkforceApi.Services;

namespace WorkforceApi.Controllers;

// ══════════════════════════════════════════════════════════════
//  Auth Controller  →  /api/auth
// ══════════════════════════════════════════════════════════════
[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService auth) : ControllerBase
{
    /// <summary>POST /api/auth/login — Returns JWT + user profile</summary>
    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest req)
    {
        try
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var result = await auth.LoginAsync(req, ip);
            return Ok(result);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new { message = ex.Message });
        }
    }

    /// <summary>POST /api/auth/change-password</summary>
    [Authorize]
    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest req)
    {
        try
        {
            int userId = GetUserId();
            await auth.ChangePasswordAsync(userId, req);
            return Ok(new { message = "Password updated successfully." });
        }
        catch (UnauthorizedAccessException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>GET /api/auth/me — Returns current user profile from token</summary>
    [Authorize]
    [HttpGet("me")]
    public IActionResult Me()
    {
        return Ok(new
        {
            id = GetUserId(),
            email = User.FindFirst(ClaimTypes.Email)?.Value,
            name = User.FindFirst(ClaimTypes.Name)?.Value,
            role = User.FindFirst(ClaimTypes.Role)?.Value,
        });
    }

    private int GetUserId() => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
}

// ══════════════════════════════════════════════════════════════
//  Attendance Controller  →  /api/attendance
// ══════════════════════════════════════════════════════════════
[ApiController]
[Route("api/attendance")]
[Authorize]
public class AttendanceController(IAttendanceService attendance) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    private byte RoleId => byte.Parse(User.FindFirst("roleId")!.Value);

    /// <summary>GET /api/attendance/today — Today's status for current user</summary>
    [HttpGet("today")]
    public async Task<ActionResult<TodayAttendanceDto>> Today()
        => Ok(await attendance.GetTodayAsync(UserId));

    /// <summary>POST /api/attendance/checkin</summary>
    [HttpPost("checkin")]
    public async Task<ActionResult<AttendanceRecordDto>> CheckIn([FromBody] CheckInRequest req)
    {
        try
        {
            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var result = await attendance.CheckInAsync(UserId, req, ip);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>POST /api/attendance/checkout</summary>
    [HttpPost("checkout")]
    public async Task<ActionResult<AttendanceRecordDto>> CheckOut([FromBody] CheckOutRequest req)
    {
        try
        {
            var result = await attendance.CheckOutAsync(UserId, req);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>GET /api/attendance/history?days=30</summary>
    [HttpGet("history")]
    public async Task<ActionResult<List<AttendanceRecordDto>>> History([FromQuery] int days = 30)
        => Ok(await attendance.GetHistoryAsync(UserId, days));

    /// <summary>GET /api/attendance/team/today — Manager: see team's today attendance</summary>
    [HttpGet("team/today")]
    [Authorize(Roles = "Manager,Admin,manager,admin")]
    public async Task<ActionResult<List<AttendanceRecordDto>>> TeamToday()
        => Ok(await attendance.GetTeamTodayAsync(UserId));

    /// <summary>POST /api/attendance/presence — Periodic GPS presence ping (called from app every 30 min)</summary>
    [HttpPost("presence")]
    public async Task<IActionResult> Presence([FromBody] PresenceCheckDto dto)
    {
        await attendance.RecordPresenceCheckAsync(UserId, dto);
        return Ok(new { message = "Presence recorded." });
    }

    /// <summary>POST /api/attendance/manual-checkin — Admin manual override</summary>
    [HttpPost("manual-checkin")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<AttendanceRecordDto>> ManualCheckIn([FromBody] ManualCheckInDto dto)
    {
        try
        {
            var result = await attendance.ManualCheckInAsync(UserId, dto);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}

// ══════════════════════════════════════════════════════════════
//  Requests Controller  →  /api/requests
// ══════════════════════════════════════════════════════════════
[ApiController]
[Route("api/requests")]
[Authorize]
public class RequestsController(IRequestService requests) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    private byte RoleId => byte.Parse(User.FindFirst("roleId")!.Value);

    /// <summary>POST /api/requests — Submit new request (Leave, Permission, CashAdvance...)</summary>
    [HttpPost]
    public async Task<ActionResult<RequestDto>> Create([FromBody] CreateRequestDto dto)
    {
        var result = await requests.CreateAsync(UserId, dto);
        return Created($"/api/requests/{result.Id}", result);
    }

    /// <summary>GET /api/requests/mine — My requests history</summary>
    [HttpGet("mine")]
    public async Task<ActionResult<List<RequestDto>>> Mine()
        => Ok(await requests.GetForUserAsync(UserId));

    /// <summary>GET /api/requests/pending — Pending requests for current approver (manager or admin)</summary>
    [HttpGet("pending")]
    [Authorize(Roles = "Manager,Admin,manager,admin")]
    public async Task<ActionResult<List<RequestDto>>> Pending()
        => Ok(await requests.GetPendingForApproverAsync(UserId, RoleId));

    /// <summary>PUT /api/requests/{id}/decide — Approve or Reject</summary>
    [HttpPut("{id:int}/decide")]
    [Authorize(Roles = "Manager,Admin,manager,admin")]
    public async Task<ActionResult<RequestDto>> Decide(int id, [FromBody] DecideRequestDto dto)
    {
        try
        {
            var result = await requests.DecideAsync(UserId, id, dto);
            return Ok(result);
        }
        catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    /// <summary>DELETE /api/requests/{id} — Cancel / delete request</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Cancel(int id)
    {
        try
        {
            await requests.CancelAsync(UserId, id);
            return NoContent();
        }
        catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
        catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }
}

// ══════════════════════════════════════════════════════════════
//  Payroll Controller  →  /api/payroll
// ══════════════════════════════════════════════════════════════
[ApiController]
[Route("api/payroll")]
[Authorize]
public class PayrollController(IPayrollService payroll) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

    /// <summary>GET /api/payroll/mine — My payroll history</summary>
    [HttpGet("mine")]
    public async Task<ActionResult<List<PayrollDto>>> Mine()
        => Ok(await payroll.GetForUserAsync(UserId));

    /// <summary>GET /api/payroll/all?year=2024&amp;month=10 — Admin: all employees payroll for month</summary>
    [HttpGet("all")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<List<PayrollDto>>> All([FromQuery] int year, [FromQuery] int month)
        => Ok(await payroll.GetMonthlyAllAsync(year, month));

    /// <summary>GET /api/payroll/disbursement-status — Admin: Current accrual status and whether today has been disbursed</summary>
    [HttpGet("disbursement-status")]
    public async Task<ActionResult<DisbursementStatusDto>> GetDisbursementStatus()
        => Ok(await payroll.GetDisbursementStatusAsync());

    /// <summary>POST /api/payroll/disburse — Admin: disburse daily accrued salaries</summary>
    [HttpPost("disburse")]
    public async Task<ActionResult<DisburseResultDto>> DisburseDaily()
    {
        try
        {
            var result = await payroll.DisburseDailySalaryAsync(UserId);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>POST /api/payroll/compute?userId=5&amp;year=2024&amp;month=10 — Admin: compute/refresh payroll</summary>
    [HttpPost("compute")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<PayrollDto>> Compute([FromQuery] int userId, [FromQuery] int year, [FromQuery] int month)
    {
        var result = await payroll.ComputeAndSaveAsync(userId, year, month);
        return Ok(result);
    }
}

// ══════════════════════════════════════════════════════════════
//  Notifications Controller  →  /api/notifications
// ══════════════════════════════════════════════════════════════
[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController(INotificationService notify) : ControllerBase
{
    private int UserId => int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

    [HttpGet]
    public async Task<ActionResult<List<NotificationDto>>> GetAll([FromQuery] bool unreadOnly = false)
        => Ok(await notify.GetForUserAsync(UserId, unreadOnly));

    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        await notify.MarkReadAsync(UserId, id);
        return Ok();
    }

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        await notify.MarkAllReadAsync(UserId);
        return Ok();
    }
}
