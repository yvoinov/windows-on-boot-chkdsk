@echo off
setlocal enableextensions enabledelayedexpansion

rem === Log directory and file ===
set "LOGDIR=%SystemRoot%\Logs"
set "LOGFILE=%LOGDIR%\chkdsk_summary.log"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
if exist "%LOGFILE%" del "%LOGFILE%"

rem === Discover existing fixed drives with letters ===
set "DRIVES="
for /f "skip=1 tokens=1" %%A in ('wmic logicaldisk where "DriveType=3" get DeviceID') do (
    set "DRV=%%A"
    set "DRV=!DRV: =!"
    set "DRV=!DRV::=!"
    if defined DRV set "DRIVES=!DRIVES! !DRV!"
)

rem Remove leading spaces
for /f "tokens=* delims= " %%X in ("!DRIVES!") do set "DRIVES=%%X"

echo === CHKDSK pre-check started at %date% %time% === >> "%LOGFILE%"

set "NEEDREBOOT=0"
set "BADDRIVES="

for %%D in (!DRIVES!) do (
    echo --- Checking drive %%D --- >> "%LOGFILE%"
    chkdsk %%D: >nul 2>&1
    set "ERR=!ERRORLEVEL!"
    echo Drive %%D return code=!ERR! >> "%LOGFILE%"

    if !ERR! GEQ 2 (
        for /f "tokens=2 delims==" %%X in ('wmic volume where "DriveLetter='%%D:'" get DirtyBitSet /value ^| find "="') do set "DIRTY=%%X"
        if /i "!DIRTY!"=="TRUE" (
            echo Errors confirmed on %%D. Scheduling chkdsk /f /r. >> "%LOGFILE%"
            echo Y|chkdsk %%D: /f /r >nul 2>&1
            set "NEEDREBOOT=1"
            set "BADDRIVES=!BADDRIVES! %%D"
        ) else (
            echo Drive %%D reported code !ERR!, but WMI says clean. Ignoring. >> "%LOGFILE%"
        )
    ) else (
        echo Drive %%D OK. >> "%LOGFILE%"
    )
)

if !NEEDREBOOT! == 0 echo === CHKDSK pre-check finished at %date% %time% (no reboot required) === >> "%LOGFILE%"
if !NEEDREBOOT! == 1 echo === CHKDSK pre-check finished at %date% %time% (reboot required, bad drives:!BADDRIVES!) === >> "%LOGFILE%"

if !NEEDREBOOT! == 1 shutdown /r /t 120

endlocal
