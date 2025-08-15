 
# Function to generate a detailed report
function Generate-PCHealthReport {
    Write-Host "--- Comprehensive PC Health Report ---"
    Write-Host "Generating report on $(Get-Date -Format 'F')..."
 
    # OS and BIOS Information
    Write-Host "`n--- System Information ---"
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Host "Operating System: $($OS.Caption)"
    Write-Host "System Manufacturer: $(Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer"
    Write-Host "System Model: $(Get-CimInstance -ClassName Win32_ComputerSystem).Model"
    $BIOS = Get-CimInstance -ClassName Win32_BIOS
    Write-Host "BIOS Manufacturer: $($BIOS.Manufacturer)"
    Write-Host "BIOS Release Date: $($BIOS.ReleaseDate)"
 
    # CPU and RAM
    Write-Host "`n--- Hardware Details ---"
    $Processor = Get-CimInstance -ClassName Win32_Processor
    Write-Host "Processor: $($Processor.Name)"
 
    $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory
    $TotalMemoryGB = [math]::Round(($Memory | Measure-Object -Property Capacity -Sum).Sum / 1GB)
    Write-Host "Total RAM: $TotalMemoryGB GB"
 
    foreach ($mem in $Memory) {
        Write-Host "  - Manufacturer: $($mem.Manufacturer), Part Number: $($mem.PartNumber), Capacity: $([math]::Round($mem.Capacity / 1GB)) GB"
    }
 
    # Storage Check
    Write-Host "`n--- Storage Check ---"
    $Disks = Get-CimInstance -ClassName Win32_DiskDrive
    foreach ($disk in $Disks) {
        Write-Host "  - Model: $($disk.Model), Size: $([math]::Round($disk.Size / 1GB)) GB, MediaType: $($disk.MediaType)"
    }
    # Run a quick disk health check using WMIC 
    Write-Host "Running a quick S.M.A.R.T. status check..."
    $diskStatus = wmic diskdrive get status
    Write-Host "$diskStatus"
    
    if ($diskStatus -notlike "*OK*") {
        Write-Host "  [!] WARNING: Disk status indicates a potential issue. A more detailed check is recommended." -ForegroundColor Yellow
    }
 
    # Battery Report (for laptops)
    Write-Host "`n--- Battery Health Report ---"
    if (Get-WmiObject -Class Win32_Battery) {
        $batteryReportPath = "C:\Users\$env:USERNAME\Desktop\battery-report.html"
        powercfg /batteryreport /output "$batteryReportPath"
        Write-Host "  [OK]: Battery report generated. See '$batteryReportPath' for details." -ForegroundColor Green
        Invoke-Item $batteryReportPath
    } else {
        Write-Host "  [i]: No battery detected (likely a desktop PC)." -ForegroundColor Cyan
    }
}

function Get-CompletePCInventory {
    param(
        [string]$OutputPath = "$env:USERPROFILE\Desktop\PC_Inventory_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt",
        [switch]$ShowProgress,
        [switch]$IncludeDetailed
    )
    
    Write-Host "=== Complete PC Inventory Tool ===" -ForegroundColor Magenta
    Write-Host "Collecting comprehensive system information..." -ForegroundColor Yellow
    Write-Host "Output will be saved to: $OutputPath" -ForegroundColor Cyan
    
    $report = @()
    $report += "=" * 80
    $report += "COMPLETE PC HARDWARE & SOFTWARE INVENTORY"
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += "Computer: $env:COMPUTERNAME"
    $report += "User: $env:USERNAME"
    $report += "=" * 80
    $report += ""
    
    # Progress tracking
    $totalSteps = 15
    $currentStep = 0
    
    function Update-Progress {
        param([string]$Activity)
        $script:currentStep++
        if ($ShowProgress) {
            $percent = [math]::Round(($script:currentStep / $totalSteps) * 100)
            Write-Progress -Activity "Collecting PC Inventory" -Status $Activity -PercentComplete $percent
        }
        Write-Host "[$script:currentStep/$totalSteps] $Activity" -ForegroundColor Green
    }
    
    try {
        # === SYSTEM OVERVIEW ===
        Update-Progress "System Overview"
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        
        $report += "SYSTEM OVERVIEW"
        $report += "-" * 40
        $report += "Manufacturer: $($computerSystem.Manufacturer)"
        $report += "Model: $($computerSystem.Model)"
        $report += "System Type: $($computerSystem.SystemType)"
        $report += "Domain/Workgroup: $($computerSystem.Domain)"
        $report += "Total Physical Memory: $([math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)) GB"
        $report += "Operating System: $($os.Caption) $($os.Version)"
        $report += "OS Architecture: $($os.OSArchitecture)"
        $report += "Install Date: $($os.InstallDate)"
        $report += "Last Boot: $($os.LastBootUpTime)"
        $report += "System Uptime: $((Get-Date) - $os.LastBootUpTime)"
        $report += ""
        
        # === PROCESSOR INFORMATION ===
        Update-Progress "Processor Information"
        $processors = Get-CimInstance -ClassName Win32_Processor
        
        $report += "PROCESSOR INFORMATION"
        $report += "-" * 40
        foreach ($cpu in $processors) {
            $report += "CPU Name: $($cpu.Name)"
            $report += "Manufacturer: $($cpu.Manufacturer)"
            $report += "Architecture: $($cpu.Architecture)"
            $report += "Family: $($cpu.Family)"
            $report += "Model: $($cpu.Model)"
            $report += "Stepping: $($cpu.Stepping)"
            $report += "Max Clock Speed: $($cpu.MaxClockSpeed) MHz"
            $report += "Current Clock Speed: $($cpu.CurrentClockSpeed) MHz"
            $report += "Number of Cores: $($cpu.NumberOfCores)"
            $report += "Number of Logical Processors: $($cpu.NumberOfLogicalProcessors)"
            $report += "L2 Cache Size: $($cpu.L2CacheSize) KB"
            $report += "L3 Cache Size: $($cpu.L3CacheSize) KB"
            $report += "Socket Designation: $($cpu.SocketDesignation)"
            $report += "Virtualization: $($cpu.VirtualizationFirmwareEnabled)"
            
            # CPU Features
            $cpuFeatures = @()
            if ($cpu.DataWidth -eq 64) { $cpuFeatures += "64-bit" }
            if ($cpu.AddressWidth -eq 64) { $cpuFeatures += "64-bit Addressing" }
            $report += "CPU Features: $($cpuFeatures -join ', ')"
            $report += ""
        }
        
        # === VIRTUALIZATION CAPABILITIES ===
        Update-Progress "Virtualization Capabilities"
        $report += "VIRTUALIZATION CAPABILITIES"
        $report += "-" * 40
        
        # Check Hyper-V capability
        try {
            $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
            $report += "Hyper-V Available: $($hyperv.State -eq 'Enabled')"
        } catch {
            $report += "Hyper-V Available: Unable to determine"
        }
        
        # Check BIOS virtualization
        $report += "Hardware Virtualization: $($processors[0].VirtualizationFirmwareEnabled)"
        
        # Check for other virtualization indicators
        $vmFeatures = @()
        if (Get-Service -Name "vmms" -ErrorAction SilentlyContinue) { $vmFeatures += "Hyper-V Management" }
        if (Get-Service -Name "VBoxService" -ErrorAction SilentlyContinue) { $vmFeatures += "VirtualBox" }
        if (Get-Process -Name "vmware*" -ErrorAction SilentlyContinue) { $vmFeatures += "VMware" }
        $report += "Virtualization Software Detected: $($vmFeatures -join ', ')"
        $report += ""
        
        # === BIOS/UEFI INFORMATION ===
        Update-Progress "BIOS/UEFI Information"
        $bios = Get-CimInstance -ClassName Win32_BIOS
        
        $report += "BIOS/UEFI INFORMATION"
        $report += "-" * 40
        $report += "Manufacturer: $($bios.Manufacturer)"
        $report += "Version: $($bios.SMBIOSBIOSVersion)"
        $report += "Release Date: $($bios.ReleaseDate)"
        $report += "SMBIOS Version: $($bios.SMBIOSMajorVersion).$($bios.SMBIOSMinorVersion)"
        $report += "Serial Number: $($bios.SerialNumber)"
        
        # Check if UEFI
        try {
            $firmwareType = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control" -Name "PEFirmwareType" -ErrorAction SilentlyContinue).PEFirmwareType
            $firmwareTypeText = switch ($firmwareType) {
                1 { "BIOS" }
                2 { "UEFI" }
                default { "Unknown" }
            }
            $report += "Firmware Type: $firmwareTypeText"
        } catch {
            $report += "Firmware Type: Unable to determine"
        }
        $report += ""
        
        # === MEMORY INFORMATION ===
        Update-Progress "Memory Information"
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory
        
        $report += "MEMORY INFORMATION"
        $report += "-" * 40
        $report += "Total Slots: $($memory.Count)"
        $totalMemory = 0
        
        for ($i = 0; $i -lt $memory.Count; $i++) {
            $mem = $memory[$i]
            $sizeGB = [math]::Round($mem.Capacity / 1GB, 2)
            $totalMemory += $sizeGB
            
            $report += "Slot $($i + 1):"
            $report += "  Capacity: $sizeGB GB"
            $report += "  Speed: $($mem.Speed) MHz"
            $report += "  Type: $($mem.MemoryType)"
            $report += "  Form Factor: $($mem.FormFactor)"
            $report += "  Manufacturer: $($mem.Manufacturer)"
            $report += "  Part Number: $($mem.PartNumber)"
            $report += "  Serial Number: $($mem.SerialNumber)"
            $report += "  Location: $($mem.DeviceLocator)"
        }
        $report += "Total Memory: $totalMemory GB"
        $report += ""
        
        # === STORAGE INFORMATION ===
        Update-Progress "Storage Information"
        $drives = Get-CimInstance -ClassName Win32_DiskDrive
        
        $report += "STORAGE INFORMATION"
        $report += "-" * 40
        foreach ($drive in $drives) {
            $sizeGB = [math]::Round($drive.Size / 1GB, 2)
            $report += "Drive: $($drive.Model)"
            $report += "  Size: $sizeGB GB"
            $report += "  Interface: $($drive.InterfaceType)"
            $report += "  Media Type: $($drive.MediaType)"
            $report += "  Serial Number: $($drive.SerialNumber)"
            $report += "  Partitions: $($drive.Partitions)"
            
            # Get partition info
            $partitions = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
            foreach ($partition in $partitions) {
                $freeGB = [math]::Round($partition.FreeSpace / 1GB, 2)
                $totalGB = [math]::Round($partition.Size / 1GB, 2)
                $usedPercent = [math]::Round((($totalGB - $freeGB) / $totalGB) * 100, 1)
                $report += "  Volume $($partition.DeviceID) $($partition.FileSystem) - $totalGB GB ($usedPercent% used)"
            }
            $report += ""
        }
        
        # === GRAPHICS INFORMATION ===
        Update-Progress "Graphics Information"
        $graphics = Get-CimInstance -ClassName Win32_VideoController
        
        $report += "GRAPHICS INFORMATION"
        $report += "-" * 40
        foreach ($gpu in $graphics) {
            $report += "GPU: $($gpu.Name)"
            $report += "  Adapter RAM: $([math]::Round($gpu.AdapterRAM / 1GB, 2)) GB"
            $report += "  Driver Version: $($gpu.DriverVersion)"
            $report += "  Driver Date: $($gpu.DriverDate)"
            $report += "  Video Processor: $($gpu.VideoProcessor)"
            $report += "  Current Resolution: $($gpu.CurrentHorizontalResolution) x $($gpu.CurrentVerticalResolution)"
            $report += "  Current Refresh Rate: $($gpu.CurrentRefreshRate) Hz"
            $report += "  Status: $($gpu.Status)"
            $report += ""
        }
        
        # === DISPLAY INFORMATION ===
        Update-Progress "Display Information"
        $monitors = Get-CimInstance -ClassName Win32_DesktopMonitor
        
        $report += "DISPLAY INFORMATION"
        $report += "-" * 40
        foreach ($monitor in $monitors) {
            $report += "Monitor: $($monitor.Name)"
            $report += "  Manufacturer: $($monitor.ManufacturerName)"
            $report += "  Screen Width: $($monitor.ScreenWidth)"
            $report += "  Screen Height: $($monitor.ScreenHeight)"
            $report += "  Pixels Per X Logical Inch: $($monitor.PixelsPerXLogicalInch)"
            $report += "  Pixels Per Y Logical Inch: $($monitor.PixelsPerYLogicalInch)"
            $report += ""
        }
        
        # === NETWORK ADAPTERS ===
        Update-Progress "Network Adapters"
        $networkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.NetConnectionStatus -ne $null }
        
        $report += "NETWORK ADAPTERS"
        $report += "-" * 40
        foreach ($adapter in $networkAdapters) {
            $report += "Adapter: $($adapter.Name)"
            $report += "  Manufacturer: $($adapter.Manufacturer)"
            $report += "  MAC Address: $($adapter.MACAddress)"
            $report += "  Speed: $($adapter.Speed)"
            $report += "  Connection Status: $($adapter.NetConnectionStatus)"
            $report += "  Adapter Type: $($adapter.AdapterType)"
            $report += ""
        }
        
        # === AUDIO DEVICES ===
        Update-Progress "Audio Devices"
        $audioDevices = Get-CimInstance -ClassName Win32_SoundDevice
        
        $report += "AUDIO DEVICES"
        $report += "-" * 40
        foreach ($audio in $audioDevices) {
            $report += "Device: $($audio.Name)"
            $report += "  Manufacturer: $($audio.Manufacturer)"
            $report += "  Status: $($audio.Status)"
            $report += ""
        }
        
        # === USB DEVICES ===
        Update-Progress "USB Devices"
        $usbDevices = Get-CimInstance -ClassName Win32_USBHub
        
        $report += "USB DEVICES"
        $report += "-" * 40
        foreach ($usb in $usbDevices) {
            $report += "Device: $($usb.Name)"
            $report += "  Device ID: $($usb.DeviceID)"
            $report += "  Status: $($usb.Status)"
        }
        $report += ""
        
        # === MOTHERBOARD INFORMATION ===
        Update-Progress "Motherboard Information"
        $motherboard = Get-CimInstance -ClassName Win32_BaseBoard
        
        $report += "MOTHERBOARD INFORMATION"
        $report += "-" * 40
        $report += "Manufacturer: $($motherboard.Manufacturer)"
        $report += "Product: $($motherboard.Product)"
        $report += "Version: $($motherboard.Version)"
        $report += "Serial Number: $($motherboard.SerialNumber)"
        $report += ""
        
        # === INSTALLED SOFTWARE (if detailed) ===
        if ($IncludeDetailed) {
            Update-Progress "Installed Software"
            $software = Get-CimInstance -ClassName Win32_Product | Sort-Object Name
            
            $report += "INSTALLED SOFTWARE"
            $report += "-" * 40
            foreach ($app in $software) {
                $report += "$($app.Name) - Version: $($app.Version)"
            }
            $report += ""
        }
        
        # === SERVICES ===
        Update-Progress "Critical Services"
        $services = Get-Service | Where-Object { $_.Status -eq 'Running' -and $_.StartType -eq 'Automatic' } | Sort-Object Name
        
        $report += "CRITICAL RUNNING SERVICES"
        $report += "-" * 40
        foreach ($service in $services | Select-Object -First 20) {
            $report += "$($service.Name) - $($service.DisplayName)"
        }
        $report += "... and $($services.Count - 20) more services"
        $report += ""
        
        # === ENVIRONMENT VARIABLES ===
        Update-Progress "Environment Information"
        $report += "ENVIRONMENT INFORMATION"
        $report += "-" * 40
        $report += "Processor Architecture: $env:PROCESSOR_ARCHITECTURE"
        $report += "Number of Processors: $env:NUMBER_OF_PROCESSORS"
        $report += "Processor Identifier: $env:PROCESSOR_IDENTIFIER"
        $report += "Windows Directory: $env:WINDIR"
        $report += "System Root: $env:SYSTEMROOT"
        $report += "Program Files: $env:PROGRAMFILES"
        $report += "Program Files (x86): $env:PROGRAMFILES(x86)"
        $report += "User Profile: $env:USERPROFILE"
        $report += ""
        
        # === POWER SETTINGS ===
        Update-Progress "Power Management"
        $powerPlan = Get-CimInstance -ClassName Win32_PowerPlan -Namespace root/cimv2/power | Where-Object { $_.IsActive -eq $true }
        
        $report += "POWER MANAGEMENT"
        $report += "-" * 40
        $report += "Active Power Plan: $($powerPlan.ElementName)"
        $report += "Power Plan GUID: $($powerPlan.InstanceID)"
        
        # Battery info (if laptop)
        $battery = Get-CimInstance -ClassName Win32_Battery
        if ($battery) {
            $report += "Battery Present: Yes"
            $report += "Battery Status: $($battery.Status)"
            $report += "Battery Chemistry: $($battery.Chemistry)"
            $report += "Design Capacity: $($battery.DesignCapacity)"
        } else {
            $report += "Battery Present: No (Desktop/No Battery)"
        }
        $report += ""
        
        # === FINAL SUMMARY ===
        $report += "=" * 80
        $report += "INVENTORY COMPLETE"
        $report += "Total Items Cataloged: $($report.Count) entries"
        $report += "Report Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $report += "=" * 80
        
        # Write to file
        $report | Out-File -FilePath $OutputPath -Encoding UTF8
        
        Write-Progress -Activity "Collecting PC Inventory" -Completed
        Write-Host "`n Inventory completed successfully!" -ForegroundColor Green
        Write-Host "Report saved to: $OutputPath" -ForegroundColor Cyan
        Write-Host "Total entries: $($report.Count)" -ForegroundColor White
        
        # Offer to open the file
        $openFile = Read-Host "`nWould you like to open the inventory report now? (Y/N)"
        if ($openFile -eq 'Y' -or $openFile -eq 'y') {
            Start-Process notepad.exe $OutputPath
        }
        
    } catch {
        Write-Host "Error during inventory collection: $($_.Exception.Message)" -ForegroundColor Red
        $report += "ERROR: $($_.Exception.Message)"
        $report | Out-File -FilePath $OutputPath -Encoding UTF8
    }
}
 
function Get-MemoryInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1024 / 1024, 2) # KB → GB
    $freeRAM  = [math]::Round($os.FreePhysicalMemory     / 1024 / 1024, 2) # KB → GB
    $usedRAM  = [math]::Round($totalRAM - $freeRAM, 2)
    $usagePercent = if ($totalRAM -ne 0) {
        [math]::Round(($usedRAM / $totalRAM) * 100, 1)
    } else { 0 }
    
    return @{
        Total        = $totalRAM
        Used         = $usedRAM
        Free         = $freeRAM
        UsagePercent = $usagePercent
    }
}

function Show-MemoryUsage {
    param([string]$Phase = "Current")
    
    $mem = Get-MemoryInfo
    $color = if ($mem.UsagePercent -gt 85) { "Red" } elseif ($mem.UsagePercent -gt 70) { "Yellow" } else { "Green" }
    
    Write-Host "`n[$Phase Memory Usage]" -ForegroundColor Cyan
    Write-Host "  Total RAM: $($mem.Total) GB" -ForegroundColor White
    Write-Host "  Used RAM:  $($mem.Used) GB ($($mem.UsagePercent)%)" -ForegroundColor $color
    Write-Host "  Free RAM:  $($mem.Free) GB" -ForegroundColor White
}

function Run-DynamicStressTest {
    param(
        [int]$CPUDurationSeconds = 45,
        [int]$MemoryPercentTarget = 90,
        [switch]$ShowRealTimeUsage
    )
    
    Write-Host "`n=== Dynamic System Stress Test ===" -ForegroundColor Magenta
    Write-Host "This test will dynamically consume system resources based on availability." -ForegroundColor Yellow
    
    # Get initial system info
    $initialMem = Get-MemoryInfo
    Show-MemoryUsage "Initial"
    
    $cpuCount = (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfLogicalProcessors
    Write-Host "`nCPU Cores: $cpuCount" -ForegroundColor White
    Write-Host "Target Memory Usage: $MemoryPercentTarget%" -ForegroundColor White
    
    Read-Host "`nPress Enter to start the stress test or Ctrl+C to cancel"
    
    # === CPU STRESS TEST ===
    Write-Host "`n--- CPU Stress Test ---" -ForegroundColor Green
    Write-Host "Starting CPU stress test for $CPUDurationSeconds seconds using all $cpuCount cores..."
    
    $jobs = @()
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Create background jobs for each CPU core
    1..$cpuCount | ForEach-Object {
        $jobs += Start-Job -ScriptBlock {
            param($duration)
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            while ($sw.Elapsed.TotalSeconds -lt $duration) {
                1..1000 | ForEach-Object { [math]::Sqrt([math]::Pow($_, 2)) } | Out-Null
            }
        } -ArgumentList $CPUDurationSeconds
    }
    
    # Monitor CPU test progress
    while ($stopwatch.Elapsed.TotalSeconds -lt $CPUDurationSeconds) {
        if ($ShowRealTimeUsage) {
            Show-MemoryUsage "During CPU Test"
        }
        $remaining = $CPUDurationSeconds - [int]$stopwatch.Elapsed.TotalSeconds
        Write-Host "`rCPU stress remaining: $remaining seconds" -NoNewline -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
    
    # Clean up CPU jobs
    $jobs | Remove-Job -Force
    $stopwatch.Stop()
    Write-Host "`nCPU stress test complete." -ForegroundColor Green
    
    # === MEMORY STRESS TEST ===
    Write-Host "`n--- Dynamic Memory Stress Test ---" -ForegroundColor Green
    
    $currentMem = Get-MemoryInfo
    $targetMemoryGB = ($currentMem.Total * $MemoryPercentTarget / 100) - $currentMem.Used
    $targetMemoryMB = [math]::Max([int]($targetMemoryGB * 1024), 100)  # Minimum 100MB
    
    Write-Host "Available RAM: $($currentMem.Free) GB"
    Write-Host "Target allocation: $([math]::Round($targetMemoryGB, 2)) GB ($targetMemoryMB MB)"
    
    if ($targetMemoryGB -le 0.1) {
        Write-Host "  [!] WARNING: Less than 100MB available for stress test!" -ForegroundColor Red
        return
    }
    
    Write-Host "Starting memory allocation..."
    
    try {
        $memoryBlocks = @()
        $allocated = 0
        $blockSize = 50  # MB per block
        
        while ($allocated -lt $targetMemoryMB) {
            $currentBlock = [math]::Min($blockSize, ($targetMemoryMB - $allocated))
            $memoryBlocks += ("X" * ($currentBlock * 1MB))
            $allocated += $currentBlock
            
            if ($ShowRealTimeUsage -and ($allocated % 200 -eq 0)) {  # Update every 200MB
                Show-MemoryUsage "Memory Allocation"
            }
            
            Write-Host "`rAllocated: $allocated MB / $targetMemoryMB MB" -NoNewline -ForegroundColor Yellow
        }
        
        Write-Host "`nMemory allocation complete!" -ForegroundColor Green
        Show-MemoryUsage "Peak"
        
        # Hold memory for a few seconds
        Write-Host "Holding memory allocation for 10 seconds..."
        for ($i = 10; $i -gt 0; $i--) {
            Write-Host "`rHolding memory: $i seconds remaining" -NoNewline -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
        
        # Clear memory
        Write-Host "`nReleasing memory..."
        Remove-Variable memoryBlocks
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        [System.GC]::Collect()
        
        Start-Sleep -Seconds 2  # Allow time for cleanup
        Show-MemoryUsage "After Cleanup"
        
        Write-Host "`nMemory stress test complete!" -ForegroundColor Green
        
    } catch {
        Write-Host "`n  [!] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  This could indicate insufficient RAM or a memory-related issue." -ForegroundColor Yellow
    }
    
    # === FINAL SUMMARY ===
    Write-Host "`n=== Stress Test Summary ===" -ForegroundColor Magenta
    $finalMem = Get-MemoryInfo
    Write-Host "Initial Memory Usage: $($initialMem.UsagePercent)%" -ForegroundColor White
    Write-Host "Peak Memory Target: $MemoryPercentTarget%" -ForegroundColor White
    Write-Host "Final Memory Usage: $($finalMem.UsagePercent)%" -ForegroundColor White
    Write-Host "CPU Cores Tested: $cpuCount" -ForegroundColor White
    Write-Host "`nStress test completed successfully!" -ForegroundColor Green
}
 
function Test-Keyboard {
    Write-Host "`n--- Keyboard Test ---" -ForegroundColor Yellow
    Write-Host "This is a manual, interactive test."
    Write-Host "Please press every key on the keyboard. A confirmation will appear after each key."
    Write-Host "Press 'Esc' to exit the test."
    Write-Host "---"
 
    # A simple loop to read and display key presses
    while ($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.Key -eq 'Escape') {
            Write-Host "`nKeyboard test complete."
            break
        }
        Write-Host "Key pressed: $($key.Key), Character: $($key.KeyChar)"
    }
}
 
# Main Script Execution
Get-CompletePCInventory -IncludeDetailed  
 
# Offer to run the stress test
$runStressTest = Read-Host "`nWould you like to run an optional stress test? (Y/N)"
if ($runStressTest -eq "Y" -or $runStressTest -eq "y") {
    Run-DynamicStressTest
}
 
# Offer to run the manual keyboard test
$runKeyboardTest = Read-Host "`nWould you like to run a manual keyboard test? (Y/N)"
if ($runKeyboardTest -eq "Y" -or $runKeyboardTest -eq "y") {
    Test-Keyboard
}
 
Write-Host "`nScript finished. Have a nice day!"
