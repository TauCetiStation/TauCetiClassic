@echo off
cd ../../maps

for /R %%f in (*.backup) do (
  del "%%f"
)

echo All backups removed.
pause
