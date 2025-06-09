@echo off
title Power Plan Switcher and Optimizer
color 0A

echo ================================
echo     POWER PLAN OPTIMIZER
echo ================================
echo.
echo Available Power Plans:
powercfg /list
echo.

echo Select a Power Plan:
echo [1] High Performance
echo [2] Balanced
echo [3] Power Saver
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo Switching to High Performance...
    powercfg -setactive SCHEME_MIN
)
if "%choice%"=="2" (
    echo Switching to Balanced...
    powercfg -setactive SCHEME_BALANCED
)
if "%choice%"=="3" (
    echo Switching to Power Saver...
    powercfg -setactive SCHEME_MAX
)

echo.

:: Optional: Ask to disable sleep and hibernation
set /p disableSleep="Do you want to disable Sleep and Hibernation? (y/n): "
if /i "%disableSleep%"=="y" (
    echo Disabling sleep...
    powercfg -change -standby-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0
    powercfg -hibernate off
    echo Sleep and hibernation disabled.
)

echo.
echo Done. Your system power settings are now optimized.
pause
