@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
for /r %%v in (*.json) do (
	call :process "%%v"
)
@echo SUCCESS checking Json files
goto :EOF
:process
set recfile=%1%
echo Checking Json: %recfile%
rem call %USERPROFILE%\AppData\Roaming\npm\jsonlint -C -M json5 %recfile%
call jsonlint -C -M cjson --trim-trailing-commas %recfile%
echo File checked: %recfile%
if !errorlevel! NEQ 0 (
	echo Errors occured while checking file %recfile%
	SETLOCAL DISABLEDELAYEDEXPANSION
	exit 9993
)
exit /B 0

:EOF
SETLOCAL DISABLEDELAYEDEXPANSION