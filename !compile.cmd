@echo off
if exist hwyenc.rom del hwyenc.rom
if exist hwyenc0.bin del hwyenc0.bin
if exist hwyenc0.exp del hwyenc0.exp
if exist hwyenc1.bin del hwyenc1.bin
if exist hwyenc1.txt del hwyenc1.txt
if exist hwyenctitle.lzsa del hwyenctitle.lzsa

rem Define ESCchar to use in ANSI escape sequences
rem https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESCchar=%%E"

@echo on
tools\lzsa.exe -f2 -r -c hwyenctitle.bin hwyenctitle.lzsa
@if errorlevel 1 goto Failed
@echo off
dir /-c hwyenctitle.lzsa|findstr /R /C:"hwyenctitle.lzsa"

call :FileSize hwyenctitle.lzsa
set lzsasizet=%fsize%

rem First pass on TASM, LZSA stream sizes are not known yet
@echo on
tools\tasm -85 -b hwyenc0.asm hwyenc0.bin -dLZSASIZET=%lzsasizet% -dLZSASIZE1=16000
@if errorlevel 1 goto Failed
@echo off

dir /-c hwyenc0.bin|findstr /R /C:"hwyenc0.bin"

REM powershell -Command "(gc hwyenc0.exp) -replace '.EQU', 'EQU' | Out-File -encoding ASCII hwyenc0.inc"
REM if exist hwyenc0.exp del hwyenc0.exp

@echo on
tools\tasm -85 -b -a4 hwyenc1.asm hwyenc1.bin hwyenc1.txt
@if errorlevel 1 goto Failed
@echo off

findstr /B "HwyEnc" hwyenc1.txt

dir /-c hwyenc1.bin|findstr /R /C:"hwyenc1.bin"

@echo on
tools\lzsa.exe -f2 -r -c hwyenc1.bin hwyenc1.lzsa
@if errorlevel 1 goto Failed
@echo off
dir /-c hwyenc1.lzsa|findstr /R /C:"hwyenc1.lzsa"

call :FileSize hwyenc1.lzsa
set lzsasize1=%fsize%

rem Second pass on TASM, now we know LZSA stream sizes
@echo on
tools\tasm -85 -b hwyenc0.asm hwyenc0.bin -dLZSASIZET=%lzsasizet% -dLZSASIZE1=%lzsasize1%
@if errorlevel 1 goto Failed
@echo off

copy /b hwyenc0.bin+hwyenctitle.lzsa+hwyenc1.lzsa hwyenc.rom >nul

dir /-c hwyenc.rom|findstr /R /C:"hwyenc.rom"

echo %ESCchar%[92mSUCCESS%ESCchar%[0m
exit

:Failed
@echo off
echo %ESCchar%[91mFAILED%ESCchar%[0m
exit /b

:FileSize
set fsize=%~z1
exit /b 0
