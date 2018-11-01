@echo off
echo Running Map Merger...

set command="java -jar ./tools/dmm-merge-tool/JTGMerge.jar"

start "Map Merger" /wait "%command%" merge %1 %2 %3

if %ERRORLEVEL% neq 0 (
    echo Unable to automatically resolve map conflicts, please merge manually.
    exit 1
)

cmd /c %command% clean %1 %2

echo Map Merger successfully finished.
exit 0
