@echo off
setlocal

REM Ensure we're in the script directory
cd /d "%~dp0"

REM Initialize module if missing
if not exist go.mod (
  echo [+] Initializing Go module...
  go mod init wezterm_toggle
)

REM Ensure dependency exists
go get golang.org/x/sys/windows >nul 2>&1
go mod tidy

echo [+] Building WeztermToggle.exe ...
go build -ldflags "-H=windowsgui -s -w" -o WeztermToggle.exe .

if %errorlevel% neq 0 (
  echo [!] Build failed.
  pause
  exit /b %errorlevel%
)

echo [+] Build succeeded: %cd%\WeztermToggle.exe
endlocal
