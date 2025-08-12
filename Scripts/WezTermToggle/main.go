package main

import (
	"strings"
	"time"
	"unsafe"

	"golang.org/x/sys/windows"
)

const (
	WEZTERM_EXE_NAME = "wezterm-gui.exe"
	WEZTERM_PATH     = `C:\Program Files\WezTerm\wezterm-gui.exe`

	TH32CS_SNAPPROCESS = 0x00000002
	SW_RESTORE         = 9
	SW_SHOW            = 5
	SW_SHOWNA          = 8
	SW_SHOWDEFAULT     = 10
)

var (
	user32                  = windows.NewLazySystemDLL("user32.dll")
	kernel32                = windows.NewLazySystemDLL("kernel32.dll")
	shell32                 = windows.NewLazySystemDLL("shell32.dll")

	procEnumWindows         = user32.NewProc("EnumWindows")
	procIsWindowVisible     = user32.NewProc("IsWindowVisible")
	procGetWindowThreadProc = user32.NewProc("GetWindowThreadProcessId")
	procShowWindowAsync     = user32.NewProc("ShowWindowAsync")
	procSetForegroundWindow = user32.NewProc("SetForegroundWindow")
	procGetForegroundWindow = user32.NewProc("GetForegroundWindow")
	procAttachThreadInput   = user32.NewProc("AttachThreadInput")
	procBringWindowToTop    = user32.NewProc("BringWindowToTop")
	procSetActiveWindow     = user32.NewProc("SetActiveWindow")

	procShellExecuteW       = shell32.NewProc("ShellExecuteW")

	procCreateSnapshot      = kernel32.NewProc("CreateToolhelp32Snapshot")
	procProcess32FirstW     = kernel32.NewProc("Process32FirstW")
	procProcess32NextW      = kernel32.NewProc("Process32NextW")
	procGetCurrentThreadId  = kernel32.NewProc("GetCurrentThreadId")
)

type PROCESSENTRY32 struct {
	Size              uint32
	CntUsage          uint32
	ProcessID         uint32
	DefaultHeapID     uintptr
	ModuleID          uint32
	CntThreads        uint32
	ParentProcessID   uint32
	PriClassBase      int32
	Flags             uint32
	ExeFile           [260]uint16
}

func widePtr(s string) *uint16 {
	p, _ := windows.UTF16PtrFromString(s)
	return p
}

func isWindowVisible(hwnd uintptr) bool {
	ret, _, _ := procIsWindowVisible.Call(hwnd)
	return ret != 0
}

func getWindowPID(hwnd uintptr) uint32 {
	var pid uint32
	procGetWindowThreadProc.Call(hwnd, uintptr(unsafe.Pointer(&pid)))
	return pid
}

func enumWindows(cb func(hwnd uintptr) bool) {
	cbRef := windows.NewCallback(func(hwnd uintptr, lparam uintptr) uintptr {
		if cb(hwnd) { return 1 }
		return 0
	})
	procEnumWindows.Call(cbRef, 0)
}

func findProcessIDByName(name string) (uint32, bool) {
	snap, _, _ := procCreateSnapshot.Call(TH32CS_SNAPPROCESS, 0)
	if snap == 0 || snap == ^uintptr(1) {
		return 0, false
	}
	defer windows.CloseHandle(windows.Handle(snap))

	var pe PROCESSENTRY32
	pe.Size = uint32(unsafe.Sizeof(pe))
	if r, _, _ := procProcess32FirstW.Call(snap, uintptr(unsafe.Pointer(&pe))); r == 0 {
		return 0, false
	}
	target := strings.ToLower(name)
	for {
		exe := windows.UTF16ToString(pe.ExeFile[:])
		if strings.ToLower(exe) == target {
			return pe.ProcessID, true
		}
		if r, _, _ := procProcess32NextW.Call(snap, uintptr(unsafe.Pointer(&pe))); r == 0 {
			break
		}
	}
	return 0, false
}

func findMainWindowForPID(pid uint32) (uintptr, bool) {
	var found uintptr
	enumWindows(func(hwnd uintptr) bool {
		if found != 0 { return false }
		if !isWindowVisible(hwnd) { return true }
		if getWindowPID(hwnd) == pid {
			found = hwnd
			return false
		}
		return true
	})
	return found, found != 0
}

func shellOpen(path string) {
	// Use ShellExecute to respect file associations and avoid console flashes.
	procShellExecuteW.Call(0,
		uintptr(unsafe.Pointer(widePtr("open"))),
		uintptr(unsafe.Pointer(widePtr(path))),
		0, 0, SW_SHOWDEFAULT)
}

func getForegroundWindow() uintptr {
	h, _, _ := procGetForegroundWindow.Call()
	return h
}

func getWindowThreadID(hwnd uintptr) uint32 {
	var pid uint32
	r, _, _ := procGetWindowThreadProc.Call(hwnd, uintptr(unsafe.Pointer(&pid)))
	return uint32(r)
}

func getCurrentThreadID() uint32 {
	r, _, _ := procGetCurrentThreadId.Call()
	return uint32(r)
}

func showWindowAsync(hwnd uintptr, cmd int) {
	procShowWindowAsync.Call(hwnd, uintptr(cmd))
}

func bringToFront(hwnd uintptr) {
	// Classic focus workaround: temporarily attach input to the foreground thread.
	fg := getForegroundWindow()
	if fg == 0 {
		// Fallback: just show & set foreground
		showWindowAsync(hwnd, SW_RESTORE)
		procSetForegroundWindow.Call(hwnd)
		return
	}
	fgTid := getWindowThreadID(fg)
	thisTid := getCurrentThreadID()

	// Attach threads
	procAttachThreadInput.Call(uintptr(thisTid), uintptr(fgTid), 1)
	showWindowAsync(hwnd, SW_RESTORE)
	procBringWindowToTop.Call(hwnd)
	procSetActiveWindow.Call(hwnd)
	procSetForegroundWindow.Call(hwnd)
	// Detach
	procAttachThreadInput.Call(uintptr(thisTid), uintptr(fgTid), 0)
}

func main() {
	pid, ok := findProcessIDByName(WEZTERM_EXE_NAME)
	if !ok {
		// Not running: launch
		shellOpen(WEZTERM_PATH)
		// Wait for window to appear
		deadline := time.Now().Add(4 * time.Second)
		for time.Now().Before(deadline) {
			if pid2, ok2 := findProcessIDByName(WEZTERM_EXE_NAME); ok2 {
				if hwnd, ok3 := findMainWindowForPID(pid2); ok3 {
					bringToFront(hwnd)
					return
				}
			}
			time.Sleep(120 * time.Millisecond)
		}
		return
	}

	// Already running: find window and focus; if none yet, try to spawn a new window via CLI then focus.
	if hwnd, ok := findMainWindowForPID(pid); ok {
		bringToFront(hwnd)
		return
	}

	// Optional: if no main window, spawn a new one (adjust path if wezterm.exe not on PATH)
	// windows.CreateProcess etc. would work too, but ShellExecute is fine:
	shellOpen(WEZTERM_PATH)
	deadline := time.Now().Add(3 * time.Second)
	for time.Now().Before(deadline) {
		if hwnd, ok := findMainWindowForPID(pid); ok {
			bringToFront(hwnd)
			return
		}
		time.Sleep(120 * time.Millisecond)
	}
}
