@echo off
cd ../../maps

FOR /R %%f IN (*.dmm) DO (
  copy "%%f" "%%f.backup" >nul
)

echo All maps prepared.
pause
