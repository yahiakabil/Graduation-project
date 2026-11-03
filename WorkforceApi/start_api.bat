@echo off
title Workforce API Server
echo ===================================================
echo   Starting Integrated Workforce API on Port 5050...
echo   Connecting to SQL Server AttendanceDb...
echo ===================================================
cd /d "C:\Users\Compumarts\.gemini\antigravity\scratch\WorkforceApi"
dotnet run
pause
