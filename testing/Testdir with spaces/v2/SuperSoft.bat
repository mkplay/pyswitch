@echo off

set arg1=%1
set version=2.0

if "%arg1:~0,2%" == "-v" (
    echo %~n0 %version%
)
