-- ============================================================
-- INTEGRATED WORKFORCE — DATABASE MIGRATION V2
-- Updates schema for:
-- 1. Employee Profile Photos (Face Biometrics & Visual Dossier)
-- 2. Hardware Router BSSID MAC binding (Anti-Spoofing Geofence)
-- 3. Offline / Signal Lost Auditing (Last Ping + Reconnect Time)
-- 4. Manager / HR Manual Attendance Override & Auditing
-- ============================================================

USE AttendanceDb;
GO

-- ────────────────────────────────────────────────────────────
-- 1. USERS: ProfilePhotoUrl
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('Users') AND name = 'ProfilePhotoUrl'
)
BEGIN
    ALTER TABLE Users ADD ProfilePhotoUrl NVARCHAR(500) NULL;
    PRINT 'Added ProfilePhotoUrl to Users table.';
END
GO

-- ────────────────────────────────────────────────────────────
-- 2. BRANCHES: RouterBssid
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('Branches') AND name = 'RouterBssid'
)
BEGIN
    ALTER TABLE Branches ADD RouterBssid NVARCHAR(50) NULL;
    PRINT 'Added RouterBssid to Branches table.';
END
GO

-- ────────────────────────────────────────────────────────────
-- 3. ATTENDANCE RECORDS: Manual Override & Biometric Telemetry
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AttendanceRecords') AND name = 'IsManualOverride'
)
BEGIN
    ALTER TABLE AttendanceRecords ADD IsManualOverride BIT NOT NULL DEFAULT 0;
    PRINT 'Added IsManualOverride to AttendanceRecords table.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AttendanceRecords') AND name = 'ManualOverrideById'
)
BEGIN
    ALTER TABLE AttendanceRecords ADD ManualOverrideById INT NULL;
    ALTER TABLE AttendanceRecords ADD CONSTRAINT FK_AttendanceRecords_Users_ManualOverrideById
        FOREIGN KEY (ManualOverrideById) REFERENCES Users(Id) ON DELETE NO ACTION;
    PRINT 'Added ManualOverrideById and Foreign Key constraint to AttendanceRecords table.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AttendanceRecords') AND name = 'ManualOverrideReason'
)
BEGIN
    ALTER TABLE AttendanceRecords ADD ManualOverrideReason NVARCHAR(250) NULL;
    PRINT 'Added ManualOverrideReason to AttendanceRecords table.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AttendanceRecords') AND name = 'VerifiedBssid'
)
BEGIN
    ALTER TABLE AttendanceRecords ADD VerifiedBssid NVARCHAR(50) NULL;
    PRINT 'Added VerifiedBssid to AttendanceRecords table.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AttendanceRecords') AND name = 'FaceLivenessScore'
)
BEGIN
    ALTER TABLE AttendanceRecords ADD FaceLivenessScore DECIMAL(5,2) NULL;
    PRINT 'Added FaceLivenessScore to AttendanceRecords table.';
END
GO

-- ────────────────────────────────────────────────────────────
-- 4. PRESENCE CHECKS: Offline Reconnect & Notes
-- ────────────────────────────────────────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('PresenceChecks') AND name = 'ReconnectTime'
)
BEGIN
    ALTER TABLE PresenceChecks ADD ReconnectTime DATETIME2 NULL;
    PRINT 'Added ReconnectTime to PresenceChecks table.';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('PresenceChecks') AND name = 'Notes'
)
BEGIN
    ALTER TABLE PresenceChecks ADD Notes NVARCHAR(250) NULL;
    PRINT 'Added Notes to PresenceChecks table.';
END
GO

-- ────────────────────────────────────────────────────────────
-- 5. SEED DATA REFRESH FOR NEW COLUMNS
-- ────────────────────────────────────────────────────────────
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- Set Router BSSIDs for corporate branches
UPDATE Branches 
SET RouterBssid = '74:83:C2:A1:09:4E' 
WHERE Id = 1 AND (RouterBssid IS NULL OR RouterBssid = '');

UPDATE Branches 
SET RouterBssid = '50:D4:F7:11:22:AA' 
WHERE Id = 2 AND (RouterBssid IS NULL OR RouterBssid = '');

-- Set realistic profile photos for demo employees & leadership
UPDATE Users
SET ProfilePhotoUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300'
WHERE Email = 'yahia@company.com';

UPDATE Users
SET ProfilePhotoUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300'
WHERE Email = 'mohamed@company.com';

UPDATE Users
SET ProfilePhotoUrl = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300'
WHERE Email = 'ahmed.kamal@company.com';

UPDATE Users
SET ProfilePhotoUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300'
WHERE Email = 'sara.sami@company.com';

UPDATE Users
SET ProfilePhotoUrl = 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300'
WHERE Email = 'omar@company.com';

UPDATE Users
SET ProfilePhotoUrl = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300'
WHERE Email = 'khaled@company.com';

PRINT 'Migration V2 script applied successfully.';
GO
