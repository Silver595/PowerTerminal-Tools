@echo off
title ⚙️ Windows All-in-One Toolbox
color A

:MENU
cls
echo =========================================
echo         WINDOWS ALL-IN-ONE TOOLBOX
echo =========================================
echo.
echo [1] System Info
echo [2] IP and Network Info
echo [3] Task Manager
echo [4] Notepad
echo [5] Calculator
echo [6] Command Prompt (Admin)
echo [7] Create Wi-Fi Hotspot (SSID: MyHotspot)
echo [8] Disk Cleanup
echo [9] Open Control Panel
echo [10] Open Device Manager
echo [11] Open Services
echo [12] Windows Update Check
echo [13] Kill Frozen App
echo [14] Open Website
echo [0] Exit
echo.

set /p opt=Choose an option: 

if "%opt%"=="1" systeminfo & pause & goto MENU
if "%opt%"=="2" ipconfig /all & pause & goto MENU
if "%opt%"=="3" start taskmgr & goto MENU
if "%opt%"=="4" start notepad & goto MENU
if "%opt%"=="5" start calc & goto MENU
if "%opt%"=="6" powershell -Command "Start-Process cmd -Verb RunAs" & goto MENU

if "%opt%"=="7" (
    echo Starting Hotspot: SSID = MyHotspot, Password = 12345678
    netsh wlan set hostednetwork mode=allow ssid=MyHotspot key=12345678
    netsh wlan start hostednetwork
    pause
    goto MENU
)

if "%opt%"=="8" cleanmgr & goto MENU
if "%opt%"=="9" start control & goto MENU
if "%opt%"=="10" start devmgmt.msc & goto MENU
if "%opt%"=="11" start services.msc & goto MENU

if "%opt%"=="12" (
    echo Checking for updates...
    powershell -command "UsoClient StartScan"
    echo Windows Update scan started in background.
    pause
    goto MENU
)

if "%opt%"=="13" (
    echo Enter part of the program name to kill (e.g. chrome):
    set /p appname=App Name: 
    taskkill /f /im %appname%.exe
    pause
    goto MENU
)

if "%opt%"=="14" (
    setlocal EnableDelayedExpansion
    echo Enter website (example: google.com or https://example.com):
    set /p site=Website: 
    set "url=%site%"
    
    echo !url! | findstr /i "http://" >nul
    if errorlevel 1 (
        echo !url! | findstr /i "https://" >nul
        if errorlevel 1 (
            set "url=https://!url!"
        )
    )

    start "" "!url!"
    endlocal
    goto MENU
)



if "%opt%"=="0" exit

echo Invalid option. Try again.
pause
goto MENU
