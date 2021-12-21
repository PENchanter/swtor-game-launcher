#NoEnv
#SingleInstance, Force
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%

; File(S) referenced by this script:
;		C:\_PENsTools_\WinAuth_\WinAuth.exe
;		%v_gamepath%\*settings*%PlayerChoice%.zip
;		%v_gamepath%\launcher.settings
;

If Not (A_IsAdmin)
	Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"

PlayerChoice := "PEN"

; ---------------------------------------------------------------- Fetch game's install path
RegRead, v_gamepath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\BioWare\Star Wars-The Old Republic, Install Dir
Sleep, 1500
v_gameexe = launcher.exe
v_gamesubtitle := "The Old Republic"

Loop, %v_gamepath%\*settings*%PlayerChoice%.zip, 0, 0
	v_archivepathandfile := A_LoopFileFullPath

; ---------------------------------------------------------------- Extract user's game data from archive
ExtractArchiveSW:
Run, "PowerShell.exe" -NoProfile -NoLogo -NoExit -Command Expand-Archive -LiteralPath '%v_archivepathandfile%' -DestinationPath '%v_gamepath%' -Force,, Hide
Sleep, 3000

; ---------------------------------------------------------------- Fetch user's game password
:FetchGamePass:
If FileExist(v_gamepath "\clippy.txt")
	{
	FileRead, v_usergamepass, %v_gamepath%\clippy.txt
	Sleep, 1500
	}

ClipBoard = %v_usergamepass%

; ---------------------------------------------------------------- Run game's launcher
If FileExist(v_gamepath "\" v_gameexe)
	Run, "%v_gamepath%\%v_gameexe%" %v_cmdlnargs%, %v_gamepath%,, v_gamePID

; ---------------------------------------------------------------- Send user's game password 
ControlSend,, %v_usergamepass%, ahk_pid %v_gamePID%
Sleep 1500
ControlSend,, {TAB}, ahk_pid %v_gamePID%

TrayTip, PLEASE BE PATIENT !!!, Attempting to use WinAuto`nto generate your 2FA code...,, 17

v_authcode := ""
Clipboard := ""
Run, "C:\_PENsTools_\WinAuth_\WinAuth.exe",,,v_wauthPID
Sleep, 2500
ControlClick, x367 y155, ahk_pid %v_wauthPID%,,, 1, Pos	; 'ahk_pid' is used with "ControlClick" command
Sleep, 2500
Process, Close, %v_wauthPID%								; 'ahk_pid' NOT used with "Process" command
v_authcode = %Clipboard%									; WinAuth.exe configured to save 2FA code to Clipboard

TrayTip													; for FetchAuthCode subroutine above

; ---------------------------------------------------------------- send AUTH CODE and hit ENTER
; the following is set up this way because the "`{TAB}`" sent above seems to insert it into the 2FA edit field! :(
ControlSend,, {Control Down}a, ahk_pid %v_gamePID%
Sleep 1500
ControlSend,, {Control Up}{Delete}, ahk_pid %v_gamePID%
Sleep 1500
ControlSend,, %v_authcode%, ahk_pid %v_gamePID%
Sleep 1500
ControlSend,, {ENTER}, ahk_pid %v_gamePID%

ExitApp
