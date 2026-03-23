@echo off
title Kernel Flow OS — Startup
echo ============================================================
echo   Kernel Flow OS — Starting up...
echo ============================================================
echo.

REM ─── Step 1: Git Pull (get latest from Lovable) ───────────
echo [1/3] Syncing with GitHub...
cd /d "%~dp0"
git pull 2>nul
if %errorlevel% equ 0 (
    echo       OK — repo is up to date.
) else (
    echo       WARN — git pull failed (offline or no changes). Continuing...
)
echo.

REM ─── Step 2: Start Launcher Service ───────────────────────
echo [2/3] Starting Kernel Launcher Service on port 8421...
start /min "KernelLauncher" pythonw "%~dp0launcher\launcher_service.py"
timeout /t 2 /nobreak >nul
echo       OK — Launcher service started.
echo.

REM ─── Step 3: Open Kernel Flow OS in browser ───────────────
echo [3/3] Opening Kernel Flow OS...

REM Check if the Lovable dev server or production URL is available
REM For now, we try the Lovable preview URL. Update this once deployed.
REM If running locally (npm run dev), use localhost:8080 or :5173

REM Try to open the Lovable app URL (update this after first Lovable build)
start "" "http://localhost:8080"

echo.
echo ============================================================
echo   Kernel Flow OS is running!
echo   Launcher Service: http://localhost:8421
echo   Press any key to stop the launcher service...
echo ============================================================
pause >nul

REM Cleanup: kill the launcher service
taskkill /fi "WINDOWTITLE eq KernelLauncher" /f >nul 2>&1
echo Launcher service stopped. Goodbye.
