@echo off

echo Checking System...

set report_file=device_report.txt

echo === Device Report ===>> %report_file%
echo.

echo Checking keyboard...
echo === Keyboard ===>> %report_file%
wmic path win32_keyboard get DeviceID, Name, NumberOfFunctionKeys, Status, StatusInfo, Description | more>> %report_file%
echo.>> %report_file%

echo Checking mouse...
echo === Mouse ===>> %report_file%
for /f "skip=1 tokens=2" %%a in ('wmic path win32_pointingdevice get status') do set "mouse_status=%%a"echo Mouse: %mouse_status%
echo Mouse: %mouse_status% >> %report_file%
echo.>> %report_file%

echo Checking Display Adapter...
echo === Display Adapter ===>> %report_file%
for /f "skip=1 tokens=1,2,3" %%a in ('wmic path win32_videocontroller get caption^,status^,adapterram /format:table') do (
  echo %%a  Status: %%b    Adapter RAM: %%c >> %report_file%
)
echo.>> %report_file%

echo Checking Disk Drive...
echo === Disk Drive ===>> %report_file%
wmic diskdrive get caption, size, status | more>> %report_file%

echo.>> %report_file%

echo Checking RAM...
echo === RAM ===>> %report_file%
wmic memorychip get devicelocator, manufacturer, partnumber, serialnumber, capacity, speed, memorytype, formfactor |more >> %report_file%
echo.>> %report_file%

echo Checking Network Adapters...
echo === Network Adapters ===>> %report_file%
wmic path Win32_NetworkAdapter get AdapterType, Name, NetConnectionId, NetEnabled, Status, StatusInfo, Manufacturer | more >> %report_file%
echo.>> %report_file%


echo Checking Sound Devices...
echo === Sound Device ===>> %report_file%
wmic path win32_sounddevice get caption, status | more >> %report_file%
echo.>> %report_file%

echo checking Battery
echo === Battery ===>> %report_file%
wmic path win32_battery get Availability,   BatteryStatus,   Caption,   Chemistry,   DeviceID,   EstimatedChargeRemaining,  MaxRechargeTime,   Name,   PNPDeviceID, Status,   StatusInfo | more>> %report_file%
echo.>> %report_file%



echo Checking Wireless Connections...
echo === Wireless Connections ===>> %report_file%
netsh wlan show interfaces >> %report_file%

echo.>> %report_file%
echo.>> %report_file%
echo.

echo Report generated at %date% %time% >> %report_file%
echo Done! Check %report_file% for the report.

notepad %report_file%
