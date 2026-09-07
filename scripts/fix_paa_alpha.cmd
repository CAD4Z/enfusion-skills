@echo off
setlocal

if /I "%~1"=="/?" goto usage
if /I "%~1"=="--help" goto usage
if not "%~2"=="" goto usage_error

set "PAA_FIX_INPUT=%~1"

rem PowerShell 5.1 ships with Windows. Keeping the implementation here makes this a single-file tool.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $inputPath=[Environment]::GetEnvironmentVariable('PAA_FIX_INPUT'); if ([string]::IsNullOrWhiteSpace($inputPath)) { $files=@(Get-ChildItem -LiteralPath (Get-Location).Path -Filter '*.paa' -File); if ($files.Count -eq 0) { throw 'No .paa file was found in the current folder.' }; if ($files.Count -gt 1) { throw 'More than one .paa file was found. Pass one file to fix_paa_alpha.cmd.' }; $file=$files[0] } else { $file=Get-Item -LiteralPath $inputPath; if ($file.PSIsContainer -or $file.Extension -ine '.paa') { throw 'The argument must name a .paa file.' } }; $patched=$false; $stream=[IO.File]::Open($file.FullName,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::Read); try { $marker=[Text.Encoding]::ASCII.GetBytes('GGATGALF'); $markerKey=[Convert]::ToBase64String($marker); $flag=[byte[]](4,0,0,0,1,0,0,0); $buffer=New-Object byte[] 8; for ($offset=2; $offset -le 34; $offset+=8) { $stream.Position=$offset; if ($stream.Read($buffer,0,$buffer.Length) -ne $buffer.Length) { break }; if ([Convert]::ToBase64String($buffer) -eq $markerKey) { if ($stream.Length -lt ($stream.Position+$flag.Length)) { throw 'The PAA header ends before the AlphaFlag value.' }; $stream.Write($flag,0,$flag.Length); $stream.Flush(); $patched=$true; break } } } finally { $stream.Dispose() }; if (-not $patched) { throw 'The AlphaFlag marker was not found in the PAA header.' }; [Console]::WriteLine(('Patched AlphaFlag in {0}' -f $file.FullName)); exit 0 } catch { [Console]::Error.WriteLine(('fix_paa_alpha: {0}' -f $_.Exception.Message)); exit 1 }"
exit /b %ERRORLEVEL%

:usage_error
echo fix_paa_alpha: pass no more than one file. 1>&2

:usage
echo Usage: %~nx0 [texture.paa]
echo.
echo With no argument, the current folder must contain exactly one .paa file.
exit /b 2
