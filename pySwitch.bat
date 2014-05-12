@echo off

:: -- Prepare the Command Processor --
SETLOCAL EnableExtensions EnableDelayedExpansion
 
:: -- Check Permissions --
net session >nul 2>&1
if %errorLevel% == 0 (
    cls
) else (
    echo.
    echo   %~n0 needs elevated permissions
    echo   ...to be able to modify the global PATH variable ^(Windows Registry^)
    echo.
    echo   Please start with "Run as administrator"
    echo.
    GOTO:EndWithPause
)

:: -- Get Global Path --
set KEY_NAME=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
set VALUE_NAME=Path
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%"') DO (
    set globalPath=%%B
)

:: -- Read Config File --
set configFile=%~dp0config.txt
if exist "%configFile%" (
    set /A i=0
    for /f "usebackq tokens=1,2 delims==" %%a in ("%configFile%") do (
        set line=%%a
        for /f "tokens=* delims= " %%a in ("!line!") do set line=%%a
        if NOT "!line:~0,1!" == "#" (

            REM Trim key and value
            set key=%%a
            for /f "tokens=* delims= " %%s in ("!key!") do set key=%%s
            for /l %%s in (1,1,100) do if "!key:~-1!"==" " set key=!key:~0,-1!
            set val=%%b
            for /f "tokens=* delims= " %%s in ("!val!") do set val=%%s
            for /l %%s in (1,1,100) do if "!val:~-1!"==" " set val=!val:~0,-1!
                
            if NOT [!key!] == [] (         
                call set arr[%%i%%]=!key!=!val!
                set /A i+=1
            )
        ) 
    )
    set /A ubound=!i!-1
) else (
    echo.
    echo   The config file is missing^^!
    echo.
    echo   Please pick one from the "config_samples" directory,
    echo   copy it to the same directory as  %~n0
    echo   and rename it to "config.txt".
    echo.
    GOTO:EndWithPause
)

:: -- Cleanup Global Path --
for /l %%i in (0,1,!ubound!) do (
    for /f "tokens=2 delims==" %%r IN ("!arr[%%i]!") do (
        set globalPath=!globalPath:%%r;=!
        set globalPath=!globalPath:%%r=!
    )
)

:: -- BUILD MENU --
SET /A COUNT=1
ECHO.
for /F "tokens=2 delims==" %%s in ('set arr[') do (
    for /f "tokens=1 delims==" %%r IN ("%%s") do (
        ECHO    [!COUNT!] %%r
        SET cstr=!cstr!!COUNT!
        SET /A COUNT+=1
    )
)
ECHO.
CHOICE /C %cstr% /M "-> Make your choice:" /N

:: -- MAIN: ERRORLEVELS in decreasing order --
set KEY_NAME=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
set VALUE_TYPE=REG_EXPAND_SZ
set VALUE_NAME=Path
SET /A lvl=!ubound!+1
for /l %%n in (!ubound!,-1,0) do (
    for /f "tokens=1,2 delims==" %%r IN ("!arr[%%n]!") do (
        IF ERRORLEVEL !lvl! ( 
            set key=%%r
            set val=%%s
            if NOT [!val!] == [] (
                set add=!val!;
            ) else (
                set add=
            )
            REG ADD "%KEY_NAME%" /v "%VALUE_NAME%" /t %VALUE_TYPE% /d "!add!%globalPath%" /f >nul
            echo.
            echo    You now use "!key!". Have Fun^^!
            GOTO RefreshUserEnvironment
        )
        SET /A lvl-=1
    )
)

:: -- Jump Labels --
:RefreshUserEnvironment
set KEY_NAME=HKCU\Environment
set VALUE_NAME=Path
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%"') DO (
    set userPath=%%B
)
SetX %VALUE_NAME% "%userPath%" >nul
ping 1.1.1.1 -n 1 -w 2000 > nul
Goto End

:EndWithPause
pause >nul

:End
