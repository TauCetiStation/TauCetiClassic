<# : // launches a File... Open sort of file chooser and outputs choice(s) to the console
:: // https://stackoverflow.com/a/36156326/1683264

@echo off
setlocal enabledelayedexpansion

rem // Does powershell.exe exist within %PATH%?

for %%I in ("powershell.exe") do if "%%~$PATH:I" neq "" (
    set chooser=powershell -noprofile "iex (${%~f0} | out-string)"
) else (

    rem // If not, compose and link C# application to open file browser dialog

    set "chooser=%temp%\chooser.exe"

    >"%temp%\c.cs" (
        echo using System;
        echo using System.Windows.Forms;
        echo class dummy {
        echo    public static void Main^(^) {
        echo        OpenFileDialog f = new OpenFileDialog^(^);
        echo        f.InitialDirectory = Environment.CurrentDirectory;
        echo        f.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*";
        echo        f.ShowHelp = true;
        echo        f.Multiselect = true;
        echo        f.ShowDialog^(^);
        echo        foreach ^(String filename in f.FileNames^) {
        echo            Console.WriteLine^(filename^);
        echo        }
        echo    }
        echo }
    )
    for /f "delims=" %%I in ('dir /b /s "%windir%\microsoft.net\*csc.exe"') do (
        if not exist "!chooser!" "%%I" /nologo /out:"!chooser!" "%temp%\c.cs" 2>NUL
    )
    del "%temp%\c.cs"
    if not exist "!chooser!" (
        echo Error: Please install .NET 2.0 or newer, or install PowerShell.
        goto :EOF
    )
)

rem // Do something with the chosen file(s)
for /f "delims=" %%I in ('%chooser%') do (
    java -jar ./JMerge.jar -clean %%I.backup %%I %%I
)

rem // comment this out to keep chooser.exe in %temp% for faster subsequent runs
del "%temp%\chooser.exe" >NUL 2>NUL
pause
goto :EOF
:: // end Batch portion / begin PowerShell hybrid chimera #>

Add-Type -AssemblyName System.Windows.Forms
$f = new-object Windows.Forms.OpenFileDialog
$f.InitialDirectory = pwd
$f.Filter = "Map Files (*.dmm)|*.dmm|All Files (*.*)|*.*"
$f.ShowHelp = $true
$f.Multiselect = $true
[void]$f.ShowDialog()
if ($f.Multiselect) { $f.FileNames } else { $f.FileName }