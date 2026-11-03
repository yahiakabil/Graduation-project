using Microsoft.EntityFrameworkCore;
using WorkforceApi.Models;

namespace WorkforceApi.Data;

public class WorkforceDbContext : DbContext
{
    public WorkforceDbContext(DbContextOptions<WorkforceDbContext> options) : base(options) { }

    // ── DbSets ────────────────────────────────────────────────────────────────
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<Shift> Shifts => Set<Shift>();
    public DbSet<User> Users => Set<User>();
    public DbSet<AttendanceRecord> AttendanceRecords => Set<AttendanceRecord>();
    public DbSet<AttendancePolicy> AttendancePolicies => Set<AttendancePolicy>();
    public DbSet<DeductionRule> DeductionRules => Set<DeductionRule>();
    public DbSet<DailyDeduction> DailyDeductions => Set<DailyDeduction>();
    public DbSet<Request> Requests => Set<Request>();
    public DbSet<PresenceCheck> PresenceChecks => Set<PresenceCheck>();
    public DbSet<Payroll> Payrolls => Set<Payroll>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<SuspiciousCheckIn> SuspiciousCheckIns => Set<SuspiciousCheckIn>();
    public DbSet<Warning> Warnings => Set<Warning>();
    public DbSet<Holiday> Holidays => Set<Holiday>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        base.OnModelCreating(mb);

        // ── User self-join (ManagerId → Id) ───────────────────────────────────
        mb.Entity<User>()
            .HasOne(u => u.Manager)
            .WithMany(u => u.Subordinates)
            .HasForeignKey(u => u.ManagerId)
            .OnDelete(DeleteBehavior.SetNull);

        mb.Entity<User>()
            .HasOne(u => u.Role)
            .WithMany(r => r.Users)
            .HasForeignKey(u => u.RoleId);

        mb.Entity<User>()
            .HasOne(u => u.Department)
            .WithMany(d => d.Users)
            .HasForeignKey(u => u.DepartmentId)
            .OnDelete(DeleteBehavior.SetNull);

        mb.Entity<User>()
            .HasOne(u => u.Branch)
            .WithMany(b => b.Users)
            .HasForeignKey(u => u.BranchId)
            .OnDelete(DeleteBehavior.SetNull);

        mb.Entity<User>()
            .HasOne(u => u.Shift)
            .WithMany(s => s.Users)
            .HasForeignKey(u => u.ShiftId)
            .OnDelete(DeleteBehavior.SetNull);

        // ── Unique Indexes ─────────────────────────────────────────────────────
        mb.Entity<User>().HasIndex(u => u.Email).IsUnique();
        mb.Entity<User>().HasIndex(u => u.EmployeeCode).IsUnique();

        mb.Entity<AttendanceRecord>()
            .HasIndex(a => new { a.UserId, a.AttendanceDate })
            .IsUnique();

        mb.Entity<DailyDeduction>()
            .HasIndex(d => new { d.AttendanceRecordId, d.RuleId })
            .IsUnique();

        mb.Entity<PresenceCheck>()
            .HasIndex(p => new { p.AttendanceRecordId, p.CheckedAt })
            .IsUnique();

        mb.Entity<Payroll>()
            .HasIndex(p => new { p.UserId, p.PayYear, p.PayMonth })
            .IsUnique();

        // ── AttendanceRecord ───────────────────────────────────────────────────
        mb.Entity<AttendanceRecord>()
            .HasOne(a => a.User)
            .WithMany(u => u.AttendanceRecords)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        mb.Entity<AttendanceRecord>()
            .HasOne(a => a.Shift)
            .WithMany(s => s.AttendanceRecords)
            .HasForeignKey(a => a.ShiftId)
            .OnDelete(DeleteBehavior.SetNull);

        mb.Entity<AttendanceRecord>()
            .HasOne(a => a.ManualOverrideBy)
            .WithMany()
            .HasForeignKey(a => a.ManualOverrideById)
            .OnDelete(DeleteBehavior.SetNull);

        // ── DailyDeduction ─────────────────────────────────────────────────────
        mb.Entity<DailyDeduction>()
            .HasOne(d => d.AttendanceRecord)
            .WithMany(a => a.DailyDeductions)
            .HasForeignKey(d => d.AttendanceRecordId)
            .OnDelete(DeleteBehavior.Cascade);

        mb.Entity<DailyDeduction>()
            .HasOne(d => d.Rule)
            .WithMany(r => r.DailyDeductions)
            .HasForeignKey(d => d.RuleId)
            .OnDelete(DeleteBehavior.Restrict);

        mb.Entity<DailyDeduction>()
            .HasOne(d => d.CancelledByRequest)
            .WithMany(r => r.CancelledDeductions)
            .HasForeignKey(d => d.CancelledByRequestId)
            .OnDelete(DeleteBehavior.SetNull);

        // ── Request ────────────────────────────────────────────────────────────
        mb.Entity<Request>()
            .HasOne(r => r.User)
            .WithMany(u => u.Requests)
            .HasForeignKey(r => r.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        mb.Entity<Request>()
            .HasOne(r => r.DecidedBy)
            .WithMany()
            .HasForeignKey(r => r.DecidedById)
            .OnDelete(DeleteBehavior.SetNull);

        // ── PresenceCheck ──────────────────────────────────────────────────────
        mb.Entity<PresenceCheck>()
            .HasOne(p => p.AttendanceRecord)
            .WithMany(a => a.PresenceChecks)
            .HasForeignKey(p => p.AttendanceRecordId)
            .OnDelete(DeleteBehavior.Cascade);

        // ── Notifications ──────────────────────────────────────────────────────
        mb.Entity<Notification>()
            .HasOne(n => n.User)
            .WithMany(u => u.Notifications)
            .HasForeignKey(n => n.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // ── SuspiciousCheckIn ──────────────────────────────────────────────────
        mb.Entity<SuspiciousCheckIn>()
            .HasOne(s => s.User)
            .WithMany(u => u.SuspiciousCheckIns)
            .HasForeignKey(s => s.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // ── Warnings ───────────────────────────────────────────────────────────
        mb.Entity<Warning>()
            .HasOne(w => w.User)
            .WithMany(u => u.Warnings)
            .HasForeignKey(w => w.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        mb.Entity<Warning>()
            .HasOne(w => w.IssuedBy)
            .WithMany()
            .HasForeignKey(w => w.IssuedById)
            .OnDelete(DeleteBehavior.Restrict);

        // ── Payroll ────────────────────────────────────────────────────────────
        mb.Entity<Payroll>()
            .HasOne(p => p.User)
            .WithMany(u => u.Payrolls)
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
