@echo off
REM This script collects system information and outputs it to a file named after the computer name with a ".txt" extension.

set outfile=%computername%.txt

REM Collect local date and time
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%

REM Write system information to file
echo Local date and time is [%ldt%] > %outfile%
echo Getting system details........
systeminfo >> %outfile%
nbtstat -c >> %outfile%
netstat -a -n -o >> %outfile%
netstat -rn >> %outfile%
ipconfig >> %outfile%
net user >> %outfile%
tasklist -v >> %outfile%
driverquery >> %outfile%
net share >> %outfile%
openfiles >> %outfile%

echo System information written to %outfile%