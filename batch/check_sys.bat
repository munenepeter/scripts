@echo off

:: Define report file
set report_file=device_report.txt

echo Checking System...
echo === Device Report === > %report_file%
echo. >> %report_file%

:: Checking keyboard
echo Checking keyboard...
echo === Keyboard === >> %report_file%
powershell -command "Get-CimInstance Win32_Keyboard | Format-Table DeviceID, Name, NumberOfFunctionKeys, Status, Description -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking mouse
echo Checking mouse...
echo === Mouse === >> %report_file%
powershell -command "$mouse_status = (Get-CimInstance Win32_PointingDevice).Status; echo Mouse: $mouse_status" >> %report_file%
echo. >> %report_file%

:: Checking Display Adapter
echo Checking Display Adapter...
echo === Display Adapter === >> %report_file%
powershell -command "Get-CimInstance Win32_VideoController | Format-Table Caption, Status, AdapterRAM -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking Disk Drive
echo Checking Disk Drive...
echo === Disk Drive === >> %report_file%
powershell -command "Get-CimInstance Win32_DiskDrive | Format-Table Caption, Size, Status -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking RAM
echo Checking RAM...
echo === RAM === >> %report_file%
powershell -command "Get-CimInstance Win32_PhysicalMemory | Format-Table DeviceLocator, Manufacturer, PartNumber, SerialNumber, Capacity, Speed, MemoryType, FormFactor -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking Network Adapters
echo Checking Network Adapters...
echo === Network Adapters === >> %report_file%
powershell -command "Get-CimInstance Win32_NetworkAdapter | Format-Table AdapterType, Name, NetConnectionID, NetEnabled, Status, Manufacturer -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking Sound Devices
echo Checking Sound Devices...
echo === Sound Device === >> %report_file%
powershell -command "Get-CimInstance Win32_SoundDevice | Format-Table Caption, Status -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking Battery
echo Checking Battery...
echo === Battery === >> %report_file%
powershell -command "Get-CimInstance Win32_Battery | Format-Table Availability, BatteryStatus, Caption, Chemistry, DeviceID, EstimatedChargeRemaining, Name, PNPDeviceID, Status -AutoSize" >> %report_file%
echo. >> %report_file%

:: Checking Wireless Connections
echo Checking Wireless Connections...
echo === Wireless Connections === >> %report_file%
powershell -command "netsh wlan show interfaces" >> %report_file%
echo. >> %report_file%

echo Report generated at %date% %time% >> %report_file%
echo Done! Check %report_file% for the report.

notepad %report_file%
