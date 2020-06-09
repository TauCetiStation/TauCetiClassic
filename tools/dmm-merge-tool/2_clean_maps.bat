@echo off
java -jar ../.groovy-shell/groovy-shell.jar scripts/clean.groovy

if %ERRORLEVEL% equ 0 (
	echo Finished.
) else (
	echo Aborted.
)

pause