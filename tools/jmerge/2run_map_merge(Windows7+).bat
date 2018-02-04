<# : launches a File... Open sort of file chooser and outputs choice(s) to the console
:: https://stackoverflow.com/a/15885133/1683264

@echo off
setlocal
cd ../../maps
for /f "delims=" %%I in ('powershell -noprofile "iex (${%~f0} | out-string)"') do (
	java -jar ../tools/jmerge/JMerge.jar -clean %%I.backup %%I %%I
)
pause
goto :EOF

: end Batch portion / begin PowerShell hybrid chimera #>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "Map Files (*.dmm)|*.dmm|All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }