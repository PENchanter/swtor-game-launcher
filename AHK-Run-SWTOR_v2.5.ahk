#SingleInstance
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%

PlayerChoice := "PEN"

; ---------------------------------------------------------------- Fetch game's install path
FetchGamePath:
RegRead, v_gamepath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\BioWare\Star Wars-The Old Republic, Install Dir
Sleep 1500
v_gameexe = launcher.exe
v_gamesubtitle := "The Old Republic"

Loop, %v_gamepath%\*settings*%PlayerChoice%.zip, 0, 0
	v_archivepathandfile := A_LoopFileFullPath

If FileExist(v_archivepathandfile)
	{
	SplitPath, v_archivepathandfile, v_archivefile, v_archivefolder
	} Else {
	ShowError("Player data archive not found!")
	ExitApp
	}

	MsgBox, 4161, Status?, v_gamepath = %v_gamepath%`nv_gameexe = %v_gameexe%`nv_archivepathandfile = %v_archivepathandfile%
	IfMsgBox Ok, {
		Sleep 100	
	} Else IfMsgBox Cancel, {
		ExitApp
	}

; ---------------------------------------------------------------- Extract user's game data from archive
ExtractArchiveSW:
Run, "PowerShell.exe" -NoProfile -NoLogo -NoExit -Command Expand-Archive -LiteralPath '%v_archivepathandfile%' -DestinationPath '%v_gamepath%' -Force,, Hide
Sleep 3000

If !FileExist(v_gamepath "\launcher.settings")
	{
		ShowError("launcher.settings file not found!")
		MsgBox, 4132, UH-OH!!, launcher.settings file not found!
		ExitApp
	} Else {
		FileReadLine, v_ParseFileLine, %v_gamepath%\launcher.settings, 1
		Sleep 1500
		RegExMatch(v_ParseFileLine, "([^""]+)""$", v_login)
	}

	MsgBox, 4161, Status?, v_gamepath = %v_gamepath%`nv_gameexe = %v_gameexe%`nv_archivepathandfile = %v_archivepathandfile%`nv_login1 = %v_login1%
	IfMsgBox Ok, {
		Sleep 100	
	} Else IfMsgBox Cancel, {
		ExitApp
	}

; ---------------------------------------------------------------- Fetch user's game password
:FetchGamePass:
If FileExist(v_gamepath "\clippy.txt")
	{
		FileRead, v_usergamepass, %v_gamepath%\clippy.txt
		Sleep 1500
	}

	MsgBox, 4161, Status?, v_gamepath = %v_gamepath%`nv_gameexe = %v_gameexe%`nv_archivepathandfile = %v_archivepathandfile%`nv_login1 = %v_login1%`nv_usergamepass = %v_usergamepass%
	IfMsgBox Ok, {
		Sleep 100	
	} Else IfMsgBox Cancel, {
		ExitApp
	}

; ---------------------------------------------------------------- Run game's launcher
RunGameLauncher:
If FileExist(v_gamepath "\" v_gameexe)
	{
		Run, "%v_gamepath%\%v_gameexe%" %v_cmdlnargs%, %v_gamepath%,, v_gamePID
	} Else {
		ShowError("Game launcher not found where expected!")
	}

;
; NOTE: The %v_gamePID% variable from above contains a different process ID than what 'WinGet' retrieves below.
;

SetTitleMatchMode, 2
gameLOOPy:
If Not WinExist(v_gamesubtitle)
	Goto gameLOOPy
WinGet, v_gamePID, PID, ahk_exe %v_gameexe%

; ---------------------------------------------------------------- Send user's game password 
SendGamePass:
	MsgBox, 4161, Status?, v_gamepath = %v_gamepath%`nv_gameexe = %v_gameexe%`nv_archivepathandfile = %v_archivepathandfile%`nv_login1 = %v_login1%`nv_usergamepass = %v_usergamepass%`nv_gamePID = %v_gamePID%
	IfMsgBox Ok, {
		Sleep 100	
	} Else IfMsgBox Cancel, {
		ExitApp
	}

;
; NOTE: 'ControlClick', nor 'ControlSend' interact with the game launcher window at all. 
; I even tried using: WinMinimize, %v_gamesubtitle%
;

ControlClick, x200 y350, ahk_pid %v_gamePID%,,, 1, Pos
Sleep 1000
ControlSend,, %v_usergamepass%{TAB}, ahk_pid %v_gamePID%
