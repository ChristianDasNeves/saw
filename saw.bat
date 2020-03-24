@echo off
rem Batch template by https://stackoverflow.com/a/45070967
goto :init

:header
    echo %__NAME% v%__VERSION%
    echo.
    echo SAW is a batch utility that tries to decrease the chance of Windows Script Host abuse.
    echo This script can modify some registry keys and also disable both wscript.exe and cscript.exe.
    echo Please use at your own risk.
    echo.
    goto :eof

:usage
    echo USAGE:
    echo   %__BAT_NAME% [flags] 
    echo.
    echo.  -?, --help               shows this help
    echo.  -v, --version            shows the version
    echo.  -d, --disable-wscript    disable Windows Script Host
    echo.  -e, --enable-wscript     enable Windows script Host
    echo.  -nb, --no-backup         does not create a backup
    echo.  -b DIR, --backup-dir     define backup directory
    echo.                           (default is "bkp" in script directory)
    echo.  -r DIR, --restore-dir    define folder where backup is located
    echo.                           (default is "bkp" in script direcotry)
    echo.  -i DIR, --icon-dir       define folder where icons are located
    echo.                           (default is "ICO" in script directory)
    goto :eof

:new_icon  
    echo.
    echo. To see changes reboot or type this command 
    echo. Win7:     ie4uinit.exe -ClearIconCache
    echo. Win10:    ie4uinit.exe -show
    goto :eof
:version
    if "%~1"=="full" call :header & goto :eof
    echo %__VERSION%
    goto :eof

:missing_argument
    call :header
    call :usage
    echo.
    echo ****                                   ****
    echo ****    MISSING "REQUIRED ARGUMENT"    ****
    echo ****                                   ****
    echo.
    goto :eof

:init
    set "__NAME=SAW stop abusing wscript"
    set "__VERSION=1.0"
    set "__YEAR=2020"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"
    
    set "BackupDir=%__BAT_PATH%bkp"
    set "RestoreDir=%__BAT_PATH%bkp"
    set "IconDir=%__BAT_PATH%ICO"     
    set "NoBackup="


:parse
    if "%~1"=="" goto :main

    if /i "%~1"=="/?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="-?"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="-h"         call :header & call :usage "%~2" & goto :end
    if /i "%~1"=="--help"     call :header & call :usage "%~2" & goto :end

    if /i "%~1"=="/v"         call :version      & goto :end
    if /i "%~1"=="-v"         call :version      & goto :end
    if /i "%~1"=="--version"  call :version full & goto :end

    rem Disable wscript params
    if /i "%~1"=="/d"         call :wscript_disable      & goto :end
    if /i "%~1"=="-d"         call :wscript_disable      & goto :end
    if /i "%~1"=="--disable-wscript"  call :wscript_disable & goto :end

    rem Enable wscript params
    if /i "%~1"=="/e"         call :wscript_enable      & goto :end
    if /i "%~1"=="-e"         call :wscript_enable      & goto :end
    if /i "%~1"=="--enable-wscript"  call :wscript_enable & goto :end

    rem No backup params
    if /i "%~1"=="/nb"         set "NoBackup=yes"  & shift & goto :parse
    if /i "%~1"=="-nb"         set "NoBackup=yes"  & shift & goto :parse
    if /i "%~1"=="--no-backup"  set "NoBackup=yes"  & shift & goto :parse

    rem Backup params
    if /i "%~1"=="/b"         set "BackupDir=%~2"  & shift & goto :parse
    if /i "%~1"=="-b"         set "BackupDir=%~2"  & shift & goto :parse
    if /i "%~1"=="--backup-dir"  set "BackupDir=%~2"  & shift & goto :parse
    
    rem Icon params
    if /i "%~1"=="/i"         set "IconDir=%~2"  & shift & goto :parse
    if /i "%~1"=="-i"         set "IconDir=%~2"  & shift & goto :parse
    if /i "%~1"=="--icon-dir"  set "IconDir=%~2"  & shift & goto :parse

    rem Restore params 
    if /i "%~1"=="/r" (
     if /i not "%~2"=="" (
            set "RestoreDir=%~2"  & goto :reg_restore
        ) else (
            goto :reg_restore
        )
    )

    if /i "%~1"=="-r" (
        if /i not "%~2"=="" (
            set "RestoreDir=%~2"  & goto :reg_restore
        ) else (
            goto :reg_restore
        )
    )
    if /i "%~1"=="--restore-dir" (
        if /i not "%~2"=="" (
                set "RestoreDir=%~2"  & goto :reg_restore
            ) else (
                goto :reg_restore
            )
    )
    
    shift
    goto :parse

:main
    call :header
    if not defined NoBackup (
        echo Current backup directory: "%BackupDir%"
        if not exist "%BackupDir%" (
            mkdir "%BackupDir%"
            call :reg_backup & goto :end
        )
    ) else (
        echo Backup was not created
    )
    call :icon_swaper & goto :end

:wscript_disable
    reg add "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /t REG_DWORD /v Enabled /d 0 /f > nul 2>&1
    goto :eof

:wscript_enable
    reg add "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /t REG_DWORD /v Enabled /d 1 /f > nul 2>&1
    goto :eof

:reg_restore
    echo Backup directory used: "%RestoreDir%"
    reg import "%RestoreDir%"\js_bkp.reg > nul 2>&1
    reg import "%RestoreDir%"\jse_bkp.reg > nul 2>&1 
    reg import "%RestoreDir%"\vbe_bkp.reg > nul 2>&1
    reg import "%RestoreDir%"\vbs_bkp.reg > nul 2>&1
    reg import "%RestoreDir%"\wsf_bkp.reg > nul 2>&1
    reg import "%RestoreDir%"\wsh_bkp.reg > nul 2>&1
    call :new_icon
    goto :end

:reg_backup
    reg export HKCR\JSFile\DefaultIcon "%BackupDir%"\js_bkp.reg /y > nul 2>&1
    reg export HKCR\JSEFile\DefaultIcon "%BackupDir%"\jse_bkp.reg /y > nul 2>&1
    reg export HKCR\VBEFile\DefaultIcon "%BackupDir%"\vbe_bkp.reg /y > nul 2>&1
    reg export HKCR\VBSFile\DefaultIcon "%BackupDir%"\vbs_bkp.reg /y > nul 2>&1
    reg export HKCR\WSFFile\DefaultIcon "%BackupDir%"\wsf_bkp.reg /y > nul 2>&1
    reg export HKCR\WSHFile\DefaultIcon "%BackupDir%"\wsh_bkp.reg /y > nul 2>&1

:icon_swaper
    echo Replace current icons with icons on folder: "%IconDir%"

    if exist "%IconDir%"\js.ico (
        reg add HKCR\JSFile\DefaultIcon /t REG_SZ /d "%IconDir%"\js.ico,0 /f > nul 2>&1
        echo [+] JS icon successfully changed
    ) else (
        echo [-] js.ico not found
    )
    
    if exist "%IconDir%"\jse.ico (
        reg add HKCR\JSEFile\DefaultIcon /t REG_SZ /d "%IconDir%"\jse.ico,0 /f > nul 2>&1
        echo [+] JSE icon successfully changed
    ) else (
        echo [-] jse.ico not found
    )

    if exist "%IconDir%"\vbe.ico (
        reg add HKCR\VBEFile\DefaultIcon /t REG_SZ /d "%IconDir%"\vbe.ico,0 /f > nul 2>&1
        echo [+] VBE icon successfully changed
    ) else (
        echo [-] vbe.ico not found
    )

    if exist "%IconDir%"\vbs.ico (
        reg add HKCR\VBSFile\DefaultIcon /t REG_SZ /d "%IconDir%"\vbs.ico,0 /f > nul 2>&1
        echo [+] VBS icon successfully changed
    ) else (
        echo [-] vbs.ico not found
    )

    if exist "%IconDir%"\wsf.ico (
        reg add HKCR\WSFile\DefaultIcon /t REG_SZ /d "%IconDir%"\wsf.ico,0 /f > nul 2>&1
        echo [+] WSF icon successfully changed
    ) else (
        echo [-] wsf.ico not found
    )
    if exist "%IconDir%"\wsh.ico (
        reg add HKCR\WSHile\DefaultIcon /t REG_SZ /d "%IconDir%"\wsh.ico,0 /f > nul 2>&1
        echo [+] WSH icon successfully changed
    ) else (
        echo [-] wsh.ico not found
    )

    call :new_icon 

:end
    call :cleanup
    exit /B

:cleanup
    REM The cleanup function is only really necessary if you
    REM are _not_ using SETLOCAL.
    set "__NAME="
    set "__VERSION="
    set "__YEAR="

    set "__BAT_FILE="
    set "__BAT_PATH="
    set "__BAT_NAME="

    set "BackupDir="
    set "RestoreDir="
    set "IconDir="     
    set "NoBackup="

    goto :eof