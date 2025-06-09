@echo off
:: Professional System Administrator Toolkit v2.1
:: For authorized use on owned/managed systems only
setlocal enabledelayedexpansion
color 0B
title System Administrator Toolkit v2.1

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This toolkit requires administrator privileges for full functionality.
    echo Some features may be limited without admin rights.
    echo.
    pause
)

:main_menu
cls
echo =========================================================
echo           🔧 System Administrator Toolkit ︵‿︵‿︵‿︵
echo =========================================================
echo.
echo [1]   System Health Overview
echo [2]   Disk Space Analysis
echo [3]   Process ^& Memory Monitor
echo [4]   CPU ^& Temperature Info
echo [5]   Hardware Information
echo [6]   Event Log Summary
echo [7]   System File Checker
echo [8]   Disk Cleanup Utility
echo [9]   Performance Baseline
echo [10]  Security Status Check
echo [11]  Network Interface Status
echo [12]  Generate System Report
echo [13]  Windows Updates Status
echo [14]  Installed Programs List
echo [15]  Exit
echo.
set /p choice=Select an option [1-15]: 

if "%choice%"=="1" goto :system_health
if "%choice%"=="2" goto :disk_analysis
if "%choice%"=="3" goto :process_monitor
if "%choice%"=="4" goto :cpu_temp
if "%choice%"=="5" goto :hardware_info
if "%choice%"=="6" goto :event_logs
if "%choice%"=="7" goto :system_file_check
if "%choice%"=="8" goto :disk_cleanup
if "%choice%"=="9" goto :performance_baseline
if "%choice%"=="10" goto :security_status
if "%choice%"=="11" goto :network_status
if "%choice%"=="12" goto :system_report
if "%choice%"=="13" goto :update_status
if "%choice%"=="14" goto :installed_programs
if "%choice%"=="15" exit /b 0
echo Invalid selection. Please try again.
timeout /t 2 >nul
goto :main_menu

:system_health
cls
echo Gathering system health information...
echo.
echo === SYSTEM UPTIME ===
PowerShell -Command "try { $uptime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; 'Last Boot: ' + $uptime.ToString('yyyy-MM-dd HH:mm:ss'); 'Uptime: ' + (New-TimeSpan -Start $uptime).ToString('dd\.hh\:mm\:ss') } catch { 'Unable to retrieve uptime information' }"
echo.
echo === CPU USAGE ===
PowerShell -Command "try { $cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average; 'CPU Usage: ' + [math]::Round($cpu.Average, 2) + '%%' } catch { 'CPU usage unavailable' }"
echo.
echo === MEMORY USAGE ===
PowerShell -Command "try { $mem = Get-CimInstance Win32_OperatingSystem; $total = [math]::Round($mem.TotalVisibleMemorySize/1MB, 2); $free = [math]::Round($mem.FreePhysicalMemory/1MB, 2); $used = [math]::Round($total - $free, 2); 'Total RAM: ' + $total + ' GB'; 'Available RAM: ' + $free + ' GB'; 'Used RAM: ' + $used + ' GB'; 'Usage: ' + [math]::Round(($used/$total)*100, 1) + '%%' } catch { 'Memory information unavailable' }"
echo.
echo === DISK USAGE SUMMARY ===
PowerShell -Command "try { Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object { $free = [math]::Round($_.FreeSpace/1GB, 2); $total = [math]::Round($_.Size/1GB, 2); $used = $total - $free; $pct = [math]::Round(($used/$total)*100, 1); 'Drive ' + $_.DeviceID + ' - Used: ' + $used + 'GB (' + $pct + '%%) | Free: ' + $free + 'GB' } } catch { 'Disk information unavailable' }"
echo.
pause
goto :main_menu

:disk_analysis
cls
echo Analyzing disk usage...
echo.
echo === DISK SPACE OVERVIEW ===
PowerShell -Command "Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name='Size(GB)';Expression={[math]::Round($_.Used/1GB + $_.Free/1GB, 2)}}, @{Name='Used(GB)';Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name='Free(GB)';Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name='%%Free';Expression={[math]::Round(($_.Free/($_.Used + $_.Free)) * 100, 1)}} | Format-Table -AutoSize"
echo.
echo Searching for large files (this may take a moment)...
PowerShell -Command "try { $largeFIles = @(); Get-ChildItem 'C:\Users', 'C:\Windows\Temp', 'C:\Temp' -Recurse -File -ErrorAction SilentlyContinue | Where-Object {$_.Length -gt 100MB} | Sort-Object Length -Descending | Select-Object -First 10 | ForEach-Object { $largeFIles += [PSCustomObject]@{ Name = $_.Name; 'Size(MB)' = [math]::Round($_.Length/1MB, 2); Path = $_.DirectoryName } }; if ($largeFIles.Count -gt 0) { $largeFIles | Format-Table -AutoSize } else { 'No large files found in searched directories' } } catch { 'Unable to search for large files' }"
pause
goto :main_menu

:process_monitor
cls
echo === TOP PROCESSES BY CPU USAGE ===
PowerShell -Command "try { Get-Process | Where-Object {$_.CPU -gt 0} | Sort-Object CPU -Descending | Select-Object -First 10 Name, @{Name='CPU(s)';Expression={[math]::Round($_.CPU, 2)}}, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet/1MB, 2)}}, Id | Format-Table -AutoSize } catch { 'Unable to retrieve CPU usage data' }"
echo.
echo === TOP PROCESSES BY MEMORY USAGE ===
PowerShell -Command "try { Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet/1MB, 2)}}, @{Name='CPU(s)';Expression={[math]::Round($_.CPU, 2)}}, Id | Format-Table -AutoSize } catch { 'Unable to retrieve memory usage data' }"
echo.
echo === SYSTEM PERFORMANCE COUNTERS ===
PowerShell -Command "try { 'Processor Queue Length: ' + (Get-CimInstance Win32_PerfRawData_PerfOS_System).ProcessorQueueLength; 'Context Switches/sec: ' + (Get-CimInstance Win32_PerfRawData_PerfOS_System).ContextSwitchesPersec } catch { 'Performance counters unavailable' }"
pause
goto :main_menu

:cpu_temp
cls
echo === CPU INFORMATION ===
PowerShell -Command "try { Get-CimInstance Win32_Processor | Select-Object Name, @{Name='Cores';Expression={$_.NumberOfCores}}, @{Name='Logical Processors';Expression={$_.NumberOfLogicalProcessors}}, @{Name='Max Speed (MHz)';Expression={$_.MaxClockSpeed}}, @{Name='Current Speed (MHz)';Expression={$_.CurrentClockSpeed}}, @{Name='Load %';Expression={$_.LoadPercentage}} | Format-List } catch { 'CPU information unavailable' }"
echo.
echo === SYSTEM TEMPERATURE ===
PowerShell -Command "try { $temps = Get-CimInstance -ClassName MSAcpi_ThermalZoneTemperature -Namespace 'root/wmi' -ErrorAction SilentlyContinue; if ($temps) { $temps | ForEach-Object { 'Thermal Zone: ' + [math]::Round(($_.CurrentTemperature/10)-273.15,1) + '°C' } } else { 'Temperature sensors not accessible or not available' } } catch { 'Temperature information unavailable' }"
echo.
echo === POWER INFORMATION ===
PowerShell -Command "try { $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue; if ($battery) { 'Battery Status: ' + $battery.Status + ' | Charge: ' + $battery.EstimatedChargeRemaining + '%%' } else { 'No battery detected (Desktop system)' }; $power = Get-CimInstance Win32_PowerPlan -Namespace root\cimv2\power -ErrorAction SilentlyContinue; if ($power) { 'Active Power Plan: ' + ($power | Where-Object {$_.IsActive}).ElementName } } catch { 'Power information unavailable' }"
pause
goto :main_menu

:hardware_info
cls
echo === SYSTEM INFORMATION ===
PowerShell -Command "try { $comp = Get-CimInstance Win32_ComputerSystem; 'Computer: ' + $comp.Name + ' (' + $comp.Model + ')'; 'Manufacturer: ' + $comp.Manufacturer; 'Total Physical Memory: ' + [math]::Round($comp.TotalPhysicalMemory/1GB, 2) + ' GB' } catch { 'System information unavailable' }"
echo.
echo === MOTHERBOARD ===
PowerShell -Command "try { Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, Version, SerialNumber | Format-List } catch { 'Motherboard information unavailable' }"
echo.
echo === MEMORY MODULES ===
PowerShell -Command "try { Get-CimInstance Win32_PhysicalMemory | Select-Object @{Name='Slot';Expression={$_.DeviceLocator}}, @{Name='Size(GB)';Expression={[math]::Round($_.Capacity/1GB, 2)}}, @{Name='Speed(MHz)';Expression={$_.Speed}}, Manufacturer, PartNumber | Format-Table -AutoSize } catch { 'Memory information unavailable' }"
echo.
echo === STORAGE DEVICES ===
PowerShell -Command "try { Get-CimInstance Win32_DiskDrive | Select-Object @{Name='Device';Expression={$_.DeviceID}}, Model, @{Name='Size(GB)';Expression={[math]::Round($_.Size/1GB, 2)}}, InterfaceType, Status | Format-Table -AutoSize } catch { 'Storage information unavailable' }"
echo.
echo === GRAPHICS ADAPTERS ===
PowerShell -Command "try { Get-CimInstance Win32_VideoController | Where-Object {$_.Name -notlike '*Basic*'} | Select-Object Name, @{Name='VRAM(MB)';Expression={if ($_.AdapterRAM) {[math]::Round($_.AdapterRAM/1MB, 0)} else {'N/A'}}}, VideoProcessor, DriverVersion | Format-Table -AutoSize } catch { 'Graphics information unavailable' }"
pause
goto :main_menu

:event_logs
cls
echo === RECENT CRITICAL AND ERROR EVENTS ===
echo Checking System Log...
PowerShell -Command "try { Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 10 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, @{Name='Message';Expression={$_.Message.Substring(0,[math]::Min(80,$_.Message.Length))}} | Format-Table -Wrap } catch { 'System event log unavailable' }"
echo.
echo Checking Application Log...
PowerShell -Command "try { Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, ProviderName, @{Name='Message';Expression={$_.Message.Substring(0,[math]::Min(60,$_.Message.Length))}} | Format-Table -Wrap } catch { 'Application event log unavailable' }"
echo.
echo === SYSTEM STARTUP PROGRAMS ===
PowerShell -Command "try { Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location | Format-Table -AutoSize } catch { 'Startup information unavailable' }"
pause
goto :main_menu

:system_file_check
cls
echo === SYSTEM FILE CHECKER ===
echo Running System File Checker (this may take several minutes)...
echo.
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Administrative privileges required for SFC scan.
    echo Please run this toolkit as Administrator.
    pause
    goto :main_menu
)

echo Starting SFC scan...
sfc /scannow
echo.
echo === DISM HEALTH CHECK ===
echo Running DISM health check...
DISM /Online /Cleanup-Image /CheckHealth
echo.
echo System file check completed.
pause
goto :main_menu

:disk_cleanup
cls
echo === DISK CLEANUP UTILITY ===
echo [1] Run Windows Disk Cleanup Utility
echo [2] Clean Temporary Files
echo [3] Empty Recycle Bin
echo [4] Clear Browser Cache (IE/Edge)
echo [5] Clean All (Temp + Recycle + Cache)
echo [6] Return to Main Menu
echo.
set /p cleanup_choice=Choose cleanup option [1-6]: 

if "%cleanup_choice%"=="1" goto :run_cleanmgr
if "%cleanup_choice%"=="2" goto :temp_cleanup
if "%cleanup_choice%"=="3" goto :empty_recycle
if "%cleanup_choice%"=="4" goto :browser_cleanup
if "%cleanup_choice%"=="5" goto :clean_all
if "%cleanup_choice%"=="6" goto :main_menu
echo Invalid choice. Please try again.
timeout /t 2 >nul
goto :disk_cleanup

:run_cleanmgr
cls
echo Starting Windows Disk Cleanup Utility...
start /wait cleanmgr
echo Disk cleanup utility closed.
pause
goto :main_menu

:temp_cleanup
cls
echo Cleaning temporary files...
echo.
set "temp_size=0"
set "cleaned_files=0"

echo Analyzing temporary files...
for /f %%i in ('dir /s /b "%temp%\*" 2^>nul ^| find /c /v ""') do set "cleaned_files=%%i"
echo Found %cleaned_files% temporary files in user temp folder.

echo Cleaning user temp files...
del /q /f /s "%temp%\*" >nul 2>&1
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1

echo Cleaning system temp files...
del /q /f /s "C:\Windows\Temp\*" >nul 2>&1

echo Cleaning prefetch files...
del /q /f "C:\Windows\Prefetch\*" >nul 2>&1

echo Temporary files cleanup completed.
pause
goto :main_menu

:empty_recycle
cls
echo Emptying Recycle Bin...
echo.
rd /s /q "C:\$Recycle.Bin" >nul 2>&1
PowerShell -Command "try { Clear-RecycleBin -Force -Confirm:$false -ErrorAction SilentlyContinue; Write-Host 'Recycle Bin emptied successfully' } catch { Write-Host 'Recycle Bin cleanup completed' }"
pause
goto :main_menu

:browser_cleanup
cls
echo Cleaning browser cache...
echo.
echo Cleaning Internet Explorer cache...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8

echo Cleaning Edge cache...
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 2 >nul
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Code Cache" >nul 2>&1

echo Browser cache cleanup completed.
pause
goto :main_menu

:clean_all
cls
echo Performing complete cleanup...
echo.
call :temp_cleanup
call :empty_recycle  
call :browser_cleanup
echo.
echo All cleanup operations completed successfully.
pause
goto :main_menu

:performance_baseline
cls
echo === PERFORMANCE BASELINE ===
echo.
echo Gathering system performance data...
echo Please wait...
echo.

:: Use only safe, basic Windows commands - no complex PowerShell
echo === SYSTEM PERFORMANCE SNAPSHOT ===
echo Generated: %date% %time%
echo.

:: Safe CPU information
echo === CPU INFORMATION ===
wmic cpu get name,numberofcores,currentclockspeed 2>nul
if %errorlevel% neq 0 (
    echo CPU information unavailable
) else (
    echo CPU data retrieved successfully
)
echo.

:: Safe Memory information using basic commands
echo === MEMORY USAGE ===
for /f "tokens=2 delims==" %%i in ('wmic OS get TotalVisibleMemorySize /value 2^>nul ^| find "="') do set TotalMem=%%i
for /f "tokens=2 delims==" %%i in ('wmic OS get FreePhysicalMemory /value 2^>nul ^| find "="') do set FreeMem=%%i

if defined TotalMem if defined FreeMem (
    set /a TotalMemMB=%TotalMem%/1024
    set /a FreeMemMB=%FreeMem%/1024
    set /a UsedMemMB=%TotalMemMB%-%FreeMemMB%
    echo Total Memory: !TotalMemMB! MB
    echo Free Memory: !FreeMemMB! MB
    echo Used Memory: !UsedMemMB! MB
    set /a MemPercent=!UsedMemMB!*100/!TotalMemMB!
    echo Memory Usage: !MemPercent!%%
) else (
    echo Memory information unavailable
)
echo.

:: Safe Disk information
echo === DISK USAGE ===
for /f "skip=1 tokens=1,2,3,4" %%a in ('wmic logicaldisk get size,freespace,caption,volumename /format:csv 2^>nul ^| findstr /v "^$"') do (
    if not "%%b"=="" (
        echo Drive %%b: %%d
        if not "%%c"=="" if not "%%a"=="" (
            set /a DiskSizeGB=%%a/1073741824
            set /a DiskFreeGB=%%c/1073741824
            set /a DiskUsedGB=!DiskSizeGB!-!DiskFreeGB!
            echo   Size: !DiskSizeGB! GB, Free: !DiskFreeGB! GB, Used: !DiskUsedGB! GB
        )
    )
)
echo.

:: Safe Process count
echo === RUNNING PROCESSES ===
for /f %%i in ('tasklist 2^>nul ^| find /c /v ""') do (
    set /a ProcessCount=%%i-3
    echo Total Running Processes: !ProcessCount!
)
echo.

:: Safe uptime information
echo === SYSTEM UPTIME ===
for /f "tokens=2 delims==" %%i in ('wmic os get lastbootuptime /value 2^>nul ^| find "="') do (
    set BootTime=%%i
    echo Last Boot Time: !BootTime:~0,8! !BootTime:~8,6!
)
echo.

:: Safe top processes - basic version
echo === TOP PROCESSES BY MEMORY ===
echo Getting top memory-consuming processes...
tasklist /fo csv | sort /r /+5 | head -n 6 2>nul
if %errorlevel% neq 0 (
    echo Process information unavailable
)
echo.

:: Performance recommendations
echo === PERFORMANCE ANALYSIS ===
if defined MemPercent (
    if !MemPercent! gtr 85 (
        echo WARNING: Very high memory usage ^(!MemPercent!%%^)
        echo Recommendation: Close unnecessary programs
    ) else if !MemPercent! gtr 70 (
        echo CAUTION: High memory usage ^(!MemPercent!%%^)
        echo Recommendation: Monitor memory usage
    ) else (
        echo GOOD: Normal memory usage ^(!MemPercent!%%^)
    )
)

if defined ProcessCount (
    if !ProcessCount! gtr 150 (
        echo INFO: High process count ^(!ProcessCount!^)
        echo Recommendation: Consider system cleanup
    ) else (
        echo INFO: Normal process count ^(!ProcessCount!^)
    )
)
echo.

echo === PERFORMANCE BASELINE COMPLETE ===
echo All safe commands executed successfully.
echo.
echo TIP: Run this baseline periodically to monitor system performance trends.
echo.
pause
goto :main_menu

:security_status
cls
echo === SECURITY STATUS OVERVIEW ===
echo.
echo === WINDOWS DEFENDER STATUS ===
PowerShell -Command "try { $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue; if ($defender) { 'Antivirus Enabled: ' + $defender.AntivirusEnabled; 'Real-time Protection: ' + $defender.RealTimeProtectionEnabled; 'Behavior Monitor: ' + $defender.BehaviorMonitorEnabled; 'On-Access Protection: ' + $defender.OnAccessProtectionEnabled; 'Last Full Scan: ' + $defender.FullScanStartTime } else { 'Windows Defender information unavailable' } } catch { 'Windows Defender status cannot be retrieved' }"
echo.
echo === FIREWALL STATUS ===
PowerShell -Command "try { Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize } catch { netsh advfirewall show allprofiles state }"
echo.
echo === USER ACCOUNT CONTROL ===
PowerShell -Command "try { $uac = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -ErrorAction SilentlyContinue; if ($uac.EnableLUA -eq 1) { 'UAC Status: ENABLED' } else { 'UAC Status: DISABLED' } } catch { 'UAC status unavailable' }"
echo.
echo === PENDING REBOOT CHECK ===
PowerShell -Command "try { $reboot = @(); if (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue) { $reboot += 'Windows Update' }; if (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' -ErrorAction SilentlyContinue) { $reboot += 'Component Servicing' }; if ($reboot.Count -gt 0) { 'Pending Reboot Required: ' + ($reboot -join ', ') } else { 'No pending reboot required' } } catch { 'Reboot status check failed' }"
pause
goto :main_menu

:network_status
cls
echo === NETWORK CONFIGURATION ===
echo.
echo === ACTIVE NETWORK ADAPTERS ===
PowerShell -Command "try { Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object Name, InterfaceDescription, LinkSpeed, Status | Format-Table -AutoSize } catch { 'Network adapter information unavailable' }"
echo.
echo === IP CONFIGURATION ===
PowerShell -Command "try { Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne '127.0.0.1' -and $_.IPAddress -notlike '169.254.*'} | Select-Object InterfaceAlias, IPAddress, PrefixLength, @{Name='Type';Expression={$_.PrefixOrigin}} | Format-Table -AutoSize } catch { 'IP configuration unavailable' }"
echo.
echo === DNS CONFIGURATION ===
PowerShell -Command "try { Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses} | Select-Object InterfaceAlias, ServerAddresses | Format-Table -AutoSize } catch { 'DNS configuration unavailable' }"
echo.
echo === NETWORK CONNECTIVITY TEST ===
PowerShell -Command "try { $targets = @('8.8.8.8', 'google.com'); foreach ($target in $targets) { $result = Test-NetConnection -ComputerName $target -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue; if ($result) { 'Connection to ' + $target + ': SUCCESS' } else { 'Connection to ' + $target + ': FAILED' } } } catch { 'Connectivity test failed' }"
pause
goto :main_menu

:system_report
cls
echo === GENERATING COMPREHENSIVE SYSTEM REPORT ===
echo.

:: Create safe filename with timestamp
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set "report_date=%%a_%%b_%%c"
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "report_time=%%a%%b"
)
set "report_time=%report_time: =0%"
set "report_file=%USERPROFILE%\Desktop\SystemReport_%report_date%_%report_time%.txt"

echo Generating report to: %report_file%
echo Please wait...
echo.

:: Generate report using batch commands and simple PowerShell
(
echo COMPREHENSIVE SYSTEM REPORT
echo ===============================================
echo Generated: %date% %time%
echo.
echo BASIC SYSTEM INFORMATION
echo ========================
systeminfo | findstr /i "Host Name OS Name Version System Type Total Physical Memory"
echo.
echo PROCESSOR INFORMATION  
echo =====================
wmic cpu get name,numberofcores,numberoflogicalprocessors /format:list
echo.
echo MEMORY INFORMATION
echo ==================
wmic computersystem get TotalPhysicalMemory /format:list
wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /format:list
echo.
echo DISK INFORMATION
echo ================
wmic logicaldisk get size,freespace,caption,volumename /format:list
echo.
echo NETWORK ADAPTERS
echo ================
wmic path win32_networkadapter where "NetEnabled=true" get name,speed /format:list
echo.
echo RUNNING PROCESSES ^(Top 10 by Memory^)
echo =====================================
wmic process get Name,WorkingSetSize /format:csv | sort /r /+2 | head -n 11
echo.
echo INSTALLED PROGRAMS ^(Sample^)
echo ============================
wmic product get name,version,vendor /format:list | head -n 30
echo.
echo SYSTEM UPTIME
echo =============
wmic os get lastbootuptime /format:list
echo.
echo REPORT GENERATION COMPLETED
echo ===========================
echo Report saved to: %report_file%
) > "%report_file%" 2>&1

if exist "%report_file%" (
    echo Report successfully generated!
    echo Location: %report_file%
    echo.
    echo Would you like to open the report now? ^(Y/N^)
    set /p open_report=
    if /i "%open_report%"=="Y" (
        start notepad "%report_file%"
    )
) else (
    echo Error: Report generation failed.
    echo Please check if you have write permissions to the Desktop.
)

pause
goto :main_menu

:update_status
cls
echo === WINDOWS UPDATE STATUS ===
echo.
echo Checking Windows Update status...
echo.

:: Check Windows Update service status
echo Checking Windows Update Service...
sc query wuauserv | findstr "STATE"

echo.
echo Checking for pending updates...
echo This may take a moment...
echo.

:: Use simple WMIC commands instead of complex PowerShell
echo Getting recent update history...
wmic qfe list brief /format:table

echo.
echo Checking for pending reboot...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" >nul 2>&1
if %errorlevel% equ 0 (
    echo REBOOT REQUIRED: Yes - Updates are pending reboot
) else (
    echo REBOOT REQUIRED: No
)

echo.
echo Checking Windows Update settings...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions >nul 2>&1
if %errorlevel% equ 0 (
    echo Automatic Updates: Configured
) else (
    echo Automatic Updates: Not configured or disabled
)

echo.
echo === WINDOWS UPDATE RECOMMENDATIONS ===
echo - Open Settings ^> Update ^& Security ^> Windows Update to check manually
echo - Enable automatic updates for security patches  
echo - Restart system if reboot is required
echo - Run 'sfc /scannow' if update installation fails
echo.

echo For detailed update information, you can also run:
echo   - Windows Update in Settings app
echo   - PowerShell: Get-WindowsUpdate ^(if PSWindowsUpdate module installed^)
echo   - Command: wuauclt /detectnow
echo.

pause
goto :main_menu

:installed_programs
cls
echo === INSTALLED PROGRAMS ===
echo Retrieving installed programs (this may take a moment)...
echo.

PowerShell -Command "
try {
    Write-Host 'Method 1: Programs from Control Panel (Add/Remove Programs)'
    Write-Host '=========================================================='
    $programs1 = Get-CimInstance Win32_Product -ErrorAction SilentlyContinue | 
        Sort-Object Name | 
        Select-Object Name, Version, Vendor, InstallDate
    
    if ($programs1) {
        $programs1 | Select-Object -First 20 | Format-Table -AutoSize
        if ($programs1.Count -gt 20) {
            Write-Host ('... and ' + ($programs1.Count - 20) + ' more programs')
        }
        Write-Host ('Total programs found via Win32_Product: ' + $programs1.Count)
    } else {
        Write-Host 'No programs found via Win32_Product method'
    }
    
    Write-Host ''
    Write-Host 'Method 2: Programs from Registry (Uninstall Keys)'
    Write-Host '================================================='
    
    # Get programs from registry - more comprehensive
    $uninstallKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    
    $programs2 = foreach ($key in $uninstallKeys) {
        Get-ItemProperty $key -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.DisplayName -notmatch '^(KB|Update for)' } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, EstimatedSize
    }
    
    if ($programs2) {
        $programs2 | Sort-Object DisplayName | Select-Object -First 25 | Format-Table DisplayName, DisplayVersion, Publisher -AutoSize
        Write-Host ('Total programs found via Registry: ' + $programs2.Count)
    }
    
    Write-Host ''
    Write-Host 'Method 3: Microsoft Store Apps'
    Write-Host '=============================='
    try {
        $storeApps = Get-AppxPackage | Where-Object { $_.Name -notlike '*Microsoft.Windows*' -and $_.Name -notlike '*Microsoft.Xbox*' } |
            Sort-Object Name | Select-Object -First 15 Name, Version
        
        if ($storeApps) {
            $storeApps | Format-Table Name, Version -AutoSize
        } else {
            Write-Host 'No Microsoft Store apps found'
        }
    } catch {
        Write-Host 'Could not retrieve Microsoft Store apps'
    }
    
} catch {
    Write-Host 'Error retrieving installed programs: ' $_.Exception.Message -ForegroundColor Red
    Write-Host 'Try running the toolkit as Administrator for complete results'
}"

echo.
echo NOTE: Different methods may show different results
echo - Win32_Product: Traditional installed programs
echo - Registry: More comprehensive list including system components  
echo - Store Apps: Universal Windows Platform applications
echo.
pause
goto :main_menu