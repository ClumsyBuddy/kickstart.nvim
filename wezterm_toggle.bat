@echo off
setlocal

REM Path to wezterm-gui.exe
set "WEZTERM_PATH=C:\Users\trevor.winn\scoop\apps\wezterm\current\wezterm-gui.exe"

REM Check if wezterm.exe is running
tasklist /FI "IMAGENAME eq wezterm-gui.exe" | find /I "wezterm-gui.exe" >nul
if errorlevel 1 (
    REM Not running — start it
    start "" "%WEZTERM_PATH%"
    exit /b
) else (
    REM Already running — restore and focus silently
    powershell -NoProfile -WindowStyle Hidden -Command ^
        "$sig = '[DllImport(\"user32.dll\")]public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);[DllImport(\"user32.dll\")]public static extern bool SetForegroundWindow(IntPtr hWnd);';" ^
        "Add-Type -MemberDefinition $sig -Name Win32 -Namespace Native;" ^
        "$p = Get-Process wezterm-gui | Select-Object -First 1;" ^
        "if ($p.MainWindowHandle -ne 0) { [Native.Win32]::ShowWindowAsync($p.MainWindowHandle, 9) | Out-Null; [Native.Win32]::SetForegroundWindow($p.MainWindowHandle) | Out-Null }"
)

endlocal
